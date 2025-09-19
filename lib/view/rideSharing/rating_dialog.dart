import 'package:flutter/material.dart';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/model/reviews/reviews_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RatingDialog extends StatefulWidget {
  final int bookingId;
  const RatingDialog({super.key, required this.bookingId});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _rating = 5;
  final TextEditingController _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Rate your trip'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final filled = index < _rating;
              return IconButton(
                onPressed: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                icon: Icon(
                  filled ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
              );
            }),
          ),
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Comment',
              hintText: 'Share your experience...',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting
              ? null
              : () async {
                  setState(() {
                    _submitting = true;
                  });
                  try {
                    final api = context.read<APIService>();
                    final repo = ReviewsRepositoryApi(api);
                    await repo.createTransportationBookingReview(
                      bookingId: widget.bookingId,
                      rating: _rating,
                      comment: _controller.text.trim().isEmpty
                          ? ' '
                          : _controller.text.trim(),
                    );
                    if (mounted) Navigator.pop(context, true);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to submit review: $e'),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                    setState(() {
                      _submitting = false;
                    });
                  }
                },
          child: _submitting
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}


