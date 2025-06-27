import 'package:flutter/material.dart';
import 'package:nearby_toilet_finder/constants/colors.dart';

class ReviewFeedbackSection extends StatefulWidget {
  final bool isUserLoggedIn;
  final VoidCallback? onRequireLogin;
  final Function(double rating, String reviewText)? onSubmit;

  const ReviewFeedbackSection({
    super.key,
    required this.isUserLoggedIn,
    this.onRequireLogin,
    this.onSubmit,
  });

  @override
  State<ReviewFeedbackSection> createState() => _ReviewFeedbackSectionState();
}

class _ReviewFeedbackSectionState extends State<ReviewFeedbackSection> {
  double _rating = 0.0;
  final TextEditingController _controller = TextEditingController();

  void _submitFeedback() {
    if (!widget.isUserLoggedIn) {
      widget.onRequireLogin?.call();
      return;
    }

    if (_rating > 0 && _controller.text.isNotEmpty) {
      widget.onSubmit?.call(_rating, _controller.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thank you for your feedback!")),
      );
      setState(() {
        _rating = 0;
        _controller.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide rating and comment.")),
      );
    }
  }

  Widget _buildStar(int index) {
    return IconButton(
      icon: Icon(
        index <= _rating ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 30,
      ),
      onPressed: () => setState(() => _rating = index.toDouble()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Leave a Review",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(children: List.generate(5, (index) => _buildStar(index + 1))),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Write your feedback...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _submitFeedback,
          icon: const Icon(Icons.send),
          label: const Text("Submit"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navyBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
