import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/datasources/order_deliverable_datasource.dart';
import '../../domain/entities/order_deliverable_entity.dart';

/// شاشة المحتوى المُسلَّم — تعمل لكلا الطرفين:
/// - الفنان  : يرفع ملفات فيديو/صوت
/// - العميل  : يشوف ويحمّل ويشارك
class OrderDeliverablesScreen extends StatefulWidget {
  final int    orderId;
  final String orderTitle; // اسم الخدمة أو الفنان للعرض

  const OrderDeliverablesScreen({
    super.key,
    required this.orderId,
    required this.orderTitle,
  });

  @override
  State<OrderDeliverablesScreen> createState() =>
      _OrderDeliverablesScreenState();
}

class _OrderDeliverablesScreenState
    extends State<OrderDeliverablesScreen> {
  final _ds = OrderDeliverableDataSource();

  List<OrderDeliverableEntity> _items  = [];
  bool   _isLoading  = false;
  bool   _isUploading= false;
  String? _uploadMsg;
  double _uploadProgress = 0;

  bool get _isArtist => LocalStorage.getRole() == 'artist';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await _ds.getDeliverables(widget.orderId);
      if (mounted) setState(() => _items = data);
    } catch (e) {
      _showError('تعذر التحميل');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── رفع ملف (للفنان فقط) ──────────────────────────────────────
  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mov', 'mp3', 'm4a', 'wav'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null) return;

    // رسالة مصاحبة (اختياري)
    final msg = await _showMessageDialog();

    setState(() {
      _isUploading    = true;
      _uploadMsg      = 'جارٍ الرفع...';
      _uploadProgress = 0;
    });

    try {
      final deliverable = await _ds.upload(
        orderId:  widget.orderId,
        filePath: file.path!,
        message:  msg,
      );
      if (mounted) {
        setState(() => _items.insert(0, deliverable));
        _showSuccess('تم الرفع وإشعار العميل 🎵');
      }
    } catch (e) {
      _showError('فشل الرفع: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadMsg   = null;
        });
      }
    }
  }

  // ── تحميل الملف (للعميل) ──────────────────────────────────────
  Future<void> _download(OrderDeliverableEntity item) async {
    try {
      _showInfo('جارٍ التحميل...');
      final dir  = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/${item.originalName}';

      await Dio().download(item.url, path);
      if (mounted) {
        _showSuccess('تم الحفظ في جهازك');
        await OpenFilex.open(path);
      }
    } catch (e) {
      _showError('فشل التحميل: $e');
    }
  }

  // ── مشاركة الملف ─────────────────────────────────────────────
  Future<void> _share(OrderDeliverableEntity item) async {
    try {
      _showInfo('جارٍ التحضير...');
      final dir  = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/${item.originalName}';

      if (!File(path).existsSync()) {
        await Dio().download(item.url, path);
      }
      await Share.shareXFiles(
        [XFile(path)],
        text: 'محتوى من تطبيق نجمة 🎵',
      );
    } catch (e) {
      _showError('فشل المشاركة: $e');
    }
  }

  // ── حذف (للفنان) ──────────────────────────────────────────────
  Future<void> _delete(OrderDeliverableEntity item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: NajmaColors.surface,
        title: Text('حذف الملف؟',
            style: NajmaTextStyles.heading(size: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء',
                style: NajmaTextStyles.body(
                    color: NajmaColors.textDim)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف',
                style: NajmaTextStyles.body(
                    color: NajmaColors.error)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _ds.deleteDeliverable(widget.orderId, item.id);
      if (mounted) {
        setState(() => _items.removeWhere((x) => x.id == item.id));
      }
    } catch (e) {
      _showError('فشل الحذف');
    }
  }

  // ── Dialog رسالة ──────────────────────────────────────────────
  Future<String?> _showMessageDialog() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: NajmaColors.surface,
        title: Text('رسالة للعميل (اختياري)',
            style: NajmaTextStyles.heading(size: 15)),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          style: NajmaTextStyles.body(size: 14),
          decoration: InputDecoration(
            hintText: 'تمنياتي لكم بمناسبة رائعة...',
            hintStyle: NajmaTextStyles.caption(
                color: NajmaColors.textDim),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('تخطّ',
                style: NajmaTextStyles.body(
                    color: NajmaColors.textDim)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: NajmaColors.gold),
            onPressed: () =>
                Navigator.pop(context, ctrl.text.trim()),
            child: Text('إرسال',
                style: NajmaTextStyles.body(
                    color: NajmaColors.black)),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NajmaColors.black,
      appBar: AppBar(
        backgroundColor: NajmaColors.black,
        elevation: 0,
        title: Text(widget.orderTitle,
            style: NajmaTextStyles.heading(size: 16)),
        iconTheme: const IconThemeData(color: NajmaColors.gold),
        actions: [
          if (_isArtist)
            IconButton(
              icon: const Icon(Icons.upload_rounded,
                  color: NajmaColors.gold),
              onPressed: _isUploading ? null : _pickAndUpload,
              tooltip: 'رفع ملف',
            ),
        ],
      ),
      body: Column(children: [
        // ── شريط الرفع ──────────────────────────────────────────
        if (_isUploading)
          Container(
            color: NajmaColors.surface,
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 10),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.cloud_upload_rounded,
                    color: NajmaColors.gold, size: 16),
                const SizedBox(width: 8),
                Text(_uploadMsg ?? 'جارٍ الرفع...',
                    style: NajmaTextStyles.caption(
                        color: NajmaColors.gold)),
              ]),
              const SizedBox(height: 6),
              const LinearProgressIndicator(
                  color: NajmaColors.gold),
            ]),
          ),

        // ── القائمة ──────────────────────────────────────────────
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: NajmaColors.gold))
              : _items.isEmpty
                  ? _EmptyState(isArtist: _isArtist,
                        onUpload: _pickAndUpload)
                  : RefreshIndicator(
                      color: NajmaColors.gold,
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) => _DeliverableCard(
                          item:     _items[i],
                          isArtist: _isArtist,
                          onDownload: () => _download(_items[i]),
                          onShare:    () => _share(_items[i]),
                          onDelete:   () => _delete(_items[i]),
                        ),
                      ),
                    ),
        ),
      ]),

      // ── FAB للفنان ───────────────────────────────────────────
      floatingActionButton: _isArtist
          ? FloatingActionButton.extended(
              onPressed: _isUploading ? null : _pickAndUpload,
              backgroundColor: NajmaColors.gold,
              icon: const Icon(Icons.add_rounded,
                  color: NajmaColors.black),
              label: Text('رفع ملف',
                  style: NajmaTextStyles.body(
                      color: NajmaColors.black,
                      size: 13)
                      .copyWith(fontWeight: FontWeight.w700)),
            )
          : null,
    );
  }

  void _showSuccess(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: NajmaColors.success,
        duration: const Duration(seconds: 2),
      ));

  void _showError(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: NajmaColors.error,
      ));

  void _showInfo(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 1),
      ));
}

// ── Deliverable Card ──────────────────────────────────────────────
class _DeliverableCard extends StatelessWidget {
  final OrderDeliverableEntity item;
  final bool       isArtist;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _DeliverableCard({
    required this.item,
    required this.isArtist,
    required this.onDownload,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isVideo = item.isVideo;
    final color   = isVideo
        ? const Color(0xFF7C5CBF)
        : NajmaColors.gold;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NajmaColors.surface,
        border: Border.all(
            color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            // أيقونة النوع
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                border: Border.all(
                    color: color.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isVideo
                    ? Icons.videocam_rounded
                    : Icons.music_note_rounded,
                color: color, size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.originalName,
                    style: NajmaTextStyles.body(size: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(children: [
                    if (item.fileSizeFmt != null)
                      Text(item.fileSizeFmt!,
                          style: NajmaTextStyles.caption(
                              size: 10,
                              color: NajmaColors.textDim)),
                    if (item.duration != null) ...[
                      Text('  ·  ',
                          style: NajmaTextStyles.caption(
                              color: NajmaColors.textDim)),
                      Text(item.duration!,
                          style: NajmaTextStyles.caption(
                              size: 10,
                              color: NajmaColors.textDim)),
                    ],
                  ]),
                ],
              ),
            ),
            // أزرار الإجراء
            Row(mainAxisSize: MainAxisSize.min, children: [
              _ActionBtn(
                icon:    Icons.download_rounded,
                color:   NajmaColors.gold,
                tooltip: 'حفظ في الجهاز',
                onTap:   onDownload,
              ),
              _ActionBtn(
                icon:    Icons.share_rounded,
                color:   NajmaColors.gold,
                tooltip: 'مشاركة',
                onTap:   onShare,
              ),
              if (isArtist)
                _ActionBtn(
                  icon:    Icons.delete_outline_rounded,
                  color:   NajmaColors.error,
                  tooltip: 'حذف',
                  onTap:   onDelete,
                ),
            ]),
          ]),

          // رسالة الفنان
          if (item.message != null &&
              item.message!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: NajmaColors.gold.withOpacity(0.05),
                border: Border.all(
                    color: NajmaColors.gold.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.format_quote_rounded,
                      color: NajmaColors.goldDim, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.message!,
                      style: NajmaTextStyles.caption(
                          size: 12,
                          color: NajmaColors.textSecond),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // وقت الرفع
          if (item.createdAt != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                _formatDate(item.createdAt!),
                style: NajmaTextStyles.caption(
                    size: 10, color: NajmaColors.textDim),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}  '
           '${d.hour.toString().padLeft(2, '0')}:'
           '${d.minute.toString().padLeft(2, '0')}';
  }
}

// ── Action Button ─────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color    color;
  final String   tooltip;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon:    Icon(icon, color: color, size: 20),
        onPressed: onTap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isArtist;
  final VoidCallback onUpload;
  const _EmptyState({required this.isArtist, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.music_off_rounded,
              color: NajmaColors.textDim, size: 56),
          const SizedBox(height: 16),
          Text(
            isArtist
                ? 'لم ترفع أي ملف بعد\nشارك مع عميلك فيديو أو تسجيل صوتي'
                : 'لم يُرفع أي محتوى بعد',
            textAlign: TextAlign.center,
            style: NajmaTextStyles.body(
                color: NajmaColors.textDim, size: 14),
          ),
          if (isArtist) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.upload_rounded,
                  color: NajmaColors.black),
              label: Text('ارفع أول ملف',
                  style: NajmaTextStyles.body(
                      color: NajmaColors.black)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: NajmaColors.gold,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12)),
            ),
          ],
        ],
      ),
    );
  }
}
