import 'package:equatable/equatable.dart';

/// Domain entity representing a customer review for a product.
class Review extends Equatable {
  final double rating;
  final String comment;
  final DateTime? date;
  final String reviewerName;
  final String? reviewerEmail;

  const Review({
    required this.rating,
    required this.comment,
    this.date,
    required this.reviewerName,
    this.reviewerEmail,
  });

  @override
  List<Object?> get props => [
    rating,
    comment,
    date,
    reviewerName,
    reviewerEmail,
  ];
}
