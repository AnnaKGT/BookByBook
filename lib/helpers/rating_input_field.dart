import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingField extends StatelessWidget {
  final double initialRating;
  final Function(double) onRatingUpdate;

  const RatingField({
    super.key, 
    required this.initialRating, 
    required this.onRatingUpdate,
    });

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: initialRating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: 30,
      itemBuilder: (context, _) => 
       Icon(
        Icons.star,
        color: Colors.amber,
       ),
       onRatingUpdate: onRatingUpdate,
    );
  }
}