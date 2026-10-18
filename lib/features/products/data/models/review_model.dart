import 'package:shopsphere/features/products/domain/entities/review.dart';

/// Data Transfer Object for [Review] entity.
class ReviewModel extends Review {
  const ReviewModel({
    required super.rating,
    required super.comment,
    super.date,
    required super.reviewerName,
    super.reviewerEmail,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['date'] is String) {
      parsedDate = DateTime.tryParse(json['date'] as String);
    }

    return ReviewModel(
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] as String? ?? '',
      date: parsedDate,
      reviewerName: json['reviewerName'] as String? ?? 'Verified Buyer',
      reviewerEmail: json['reviewerEmail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
      if (date != null) 'date': date!.toIso8601String(),
      'reviewerName': reviewerName,
      if (reviewerEmail != null) 'reviewerEmail': reviewerEmail,
    };
  }

  factory ReviewModel.fromEntity(Review entity) {
    return ReviewModel(
      rating: entity.rating,
      comment: entity.comment,
      date: entity.date,
      reviewerName: entity.reviewerName,
      reviewerEmail: entity.reviewerEmail,
    );
  }
}
