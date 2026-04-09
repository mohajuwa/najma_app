import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/network/api_client.dart';
import '../../../artists/data/datasources/artists_datasource.dart';

/// شاشة تفعيل/إيقاف مشاركة الموقع للفنان
class ArtistLocationScreen extends StatefulWidget {
  const ArtistLocationScreen({super.key});

  @override
  State<ArtistLocationScreen> createState() => _ArtistLocationScreenState();
}

class _ArtistLocationScreenState extends State<ArtistLocationScreen> {
  final _ds = ArtistsDataSource();

  bool _isEnabled = false;
  bool _isLoading = false;
  String _statusText = 'الموقع غير مُفعَّل';
  final _labelCtrl = TextEditingController();

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  // ── تفعيل الموقع ────────────────────────────────────────────────
  Future<void> _enableLocation() async {
    setState(() => _isLoading = true);
    try {
      // طلب الإذن
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever ||
          perm == LocationPermission.denied) {
        _showError('يجب السماح بالوصول للموقع من إعدادات الجهاز');
        return;
      }

      // الحصول على الموقع
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      await _ds.updateLocation(
        latitude: pos.latitude,
        longitude: pos.longitude,
        label: _labelCtrl.text.trim().isNotEmpty
            ? _labelCtrl.text.trim()
            : null,
      );

      if (mounted) {
        setState(() {
          _isEnabled = true;
          _statusText = 'موقعك مُشارَك الآن';
        });
        _showSuccess('تم تفعيل مشاركة موقعك');
      }
    } catch (e) {
      _showError('تعذر الحصول على الموقع: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── إيقاف الموقع ────────────────────────────────────────────────
  Future<void> _disableLocation() async {
    setState(() => _isLoading = true);
    try {
      await _ds.disableLocation();
      if (mounted) {
        setState(() {
          _isEnabled = false;
          _statusText = 'الموقع غير مُفعَّل';
        });
        _showSuccess('تم إيقاف مشاركة موقعك');
      }
    } catch (e) {
      _showError('حدث خطأ: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── تحديث الموقع (أثناء الفعالية) ──────────────────────────────
  Future<void> _refreshLocation() async {
    if (!_isEnabled) return;
    setState(() => _isLoading = true);
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
      await _ds.updateLocation(
        latitude: pos.latitude,
        longitude: pos.longitude,
        label: _labelCtrl.text.trim().isNotEmpty
            ? _labelCtrl.text.trim()
            : null,
      );
      if (mounted) _showSuccess('تم تحديث موقعك');
    } catch (e) {
      _showError('تعذر التحديث: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── UI ───────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NajmaColors.black,
      appBar: AppBar(
        backgroundColor: NajmaColors.black,
        elevation: 0,
        title: Text('مشاركة الموقع', style: NajmaTextStyles.heading(size: 16)),
        iconTheme: const IconThemeData(color: NajmaColors.gold),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── بطاقة الحالة ──────────────────────────────────────
            _StatusCard(
              isEnabled: _isEnabled,
              statusText: _statusText,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 24),

            // ── اسم المكان (اختياري) ──────────────────────────────
            Text('اسم المكان (اختياري)', style: NajmaTextStyles.label()),
            const SizedBox(height: 8),
            TextField(
              controller: _labelCtrl,
              style: NajmaTextStyles.body(size: 14),
              decoration: InputDecoration(
                hintText: 'مثال: قاعة الأفراح، فندق الريتز...',
                hintStyle: NajmaTextStyles.caption(color: NajmaColors.textDim),
                filled: true,
                fillColor: NajmaColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: NajmaColors.goldDim.withOpacity(0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: NajmaColors.goldDim.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: NajmaColors.gold,
                    width: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── الأزرار ───────────────────────────────────────────
            if (!_isEnabled)
              _NajmaBtn(
                label: 'شارك موقعي الآن',
                icon: Icons.location_on_rounded,
                color: NajmaColors.gold,
                isLoading: _isLoading,
                onTap: _enableLocation,
              )
            else ...[
              _NajmaBtn(
                label: 'تحديث الموقع',
                icon: Icons.refresh_rounded,
                color: NajmaColors.gold,
                isLoading: _isLoading,
                onTap: _refreshLocation,
              ),
              const SizedBox(height: 12),
              _NajmaBtn(
                label: 'إيقاف المشاركة',
                icon: Icons.location_off_rounded,
                color: NajmaColors.error,
                isLoading: _isLoading,
                onTap: _disableLocation,
              ),
            ],

            const SizedBox(height: 32),
            // ── ملاحظة ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: NajmaColors.gold.withOpacity(0.05),
                border: Border.all(color: NajmaColors.gold.withOpacity(0.15)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: NajmaColors.goldDim,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'موقعك يظهر للعملاء في صفحتك فقط عند التفعيل. '
                      'بعد انتهاء الفعالية اضغط "إيقاف المشاركة" للخصوصية.',
                      style: NajmaTextStyles.caption(
                        size: 11,
                        color: NajmaColors.textSecond,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: NajmaColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: NajmaColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ── Status Card ───────────────────────────────────────────────────
class _StatusCard extends StatelessWidget {
  final bool isEnabled;
  final String statusText;
  final bool isLoading;
  const _StatusCard({
    required this.isEnabled,
    required this.statusText,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final color = isEnabled ? NajmaColors.success : NajmaColors.textDim;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isLoading ? NajmaColors.gold : color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isLoading ? 'جارٍ التحديث...' : statusText,
            style: NajmaTextStyles.body(size: 14, color: color),
          ),
        ],
      ),
    );
  }
}

// ── Najma Button ──────────────────────────────────────────────────
class _NajmaBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _NajmaBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onTap,
        icon: Icon(icon, size: 18, color: NajmaColors.black),
        label: Text(
          label,
          style: NajmaTextStyles.body(
            size: 14,
            color: NajmaColors.black,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
