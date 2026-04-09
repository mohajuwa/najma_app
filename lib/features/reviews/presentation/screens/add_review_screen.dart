import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/reviews_bloc.dart';
import '../bloc/reviews_event.dart';
import '../bloc/reviews_state.dart';
import '../widgets/star_rating_widget.dart';

class AddReviewScreen extends StatefulWidget {
  final int    artistId;
  final String artistName;

  const AddReviewScreen({
    super.key,
    required this.artistId,
    required this.artistName,
  });

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  int    _rating  = 0;
  final  _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext ctx) {
    if (_rating == 0) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('اختر عدد النجوم أولاً')),
      );
      return;
    }
    ctx.read<ReviewsBloc>().add(
      SubmitReviewEvent(
        widget.artistId,
        _rating,
        _commentCtrl.text.trim().isEmpty ? null : _commentCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReviewsBloc, ReviewsState>(
      listener: (ctx, state) {
        if (state is ReviewSubmitted) {
          Navigator.of(ctx).pop(true);
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: NajmaColors.gold,
            ),
          );
        } else if (state is ReviewSubmitError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade800,
            ),
          );
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: NajmaColors.black,
          appBar: AppBar(
            backgroundColor: NajmaColors.black,
            elevation: 0,
            title: Text(
              'تقييم ${widget.artistName}',
              style: NajmaTextStyles.heading(size: 16),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: NajmaColors.gold, size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: BlocBuilder<ReviewsBloc, ReviewsState>(
            buildWhen: (_, s) => s is ReviewsSubmitting || s is ReviewsLoaded || s is ReviewsInitial,
            builder: (ctx, state) {
              final loading = state is ReviewsSubmitting;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // أيقونة الفنان
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: NajmaColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: NajmaColors.gold.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(Icons.mic, color: NajmaColors.gold, size: 32),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'كيف كانت تجربتك مع\n${widget.artistName}؟',
                      style: NajmaTextStyles.heading(size: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // نجوم التقييم
                    StarRatingWidget(
                      rating: _rating.toDouble(),
                      size: 42,
                      interactive: true,
                      onChanged: (v) => setState(() => _rating = v),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _ratingLabel(_rating),
                      style: NajmaTextStyles.caption(
                        size: 13,
                        color: NajmaColors.gold,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // حقل التعليق
                    Container(
                      decoration: BoxDecoration(
                        color: NajmaColors.surface,
                        border: Border.all(
                          color: NajmaColors.goldDim.withOpacity(0.25),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _commentCtrl,
                        maxLines: 4,
                        maxLength: 500,
                        style: NajmaTextStyles.body(size: 14),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          hintText: 'اكتب تعليقك هنا (اختياري)...',
                          hintStyle: NajmaTextStyles.body(
                            size: 13,
                            color: NajmaColors.textDim,
                          ),
                          counterStyle: NajmaTextStyles.caption(
                            size: 10,
                            color: NajmaColors.textDim,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // زر الإرسال
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: loading
                          ? Container(
                              decoration: BoxDecoration(
                                color: NajmaColors.gold.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: NajmaColors.black,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () => _submit(ctx),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: NajmaColors.gold,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    'إرسال التقييم',
                                    style: NajmaTextStyles.body(
                                      size: 15,
                                      color: NajmaColors.black,
                                    ).copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _ratingLabel(int r) {
    switch (r) {
      case 1: return 'سيء جداً';
      case 2: return 'سيء';
      case 3: return 'مقبول';
      case 4: return 'جيد';
      case 5: return 'ممتاز! ✨';
      default: return 'اختر تقييمك';
    }
  }
}
