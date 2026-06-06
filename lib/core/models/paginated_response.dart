class PaginatedResponse<T> {
  final bool success;
  final String? message;
  final List<T> data;
  final PaginationMeta meta;

  PaginatedResponse({
    required this.success,
    this.message,
    required this.data,
    required this.meta,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final success = json['success'] as bool? ?? false;
    final message = json['message'] as String?;

    final rawData = json['data'] as List? ?? [];
    final data = rawData.map((e) => fromJsonT(e)).toList();

    final rawMeta = json['meta'] as Map<String, dynamic>?;
    PaginationMeta meta;
    if (rawMeta != null) {
      meta = PaginationMeta.fromJson(rawMeta);
    } else {
      meta = PaginationMeta(
        currentPage: json['current_page'] as int? ?? 1,
        lastPage: json['last_page'] as int? ?? 1,
        perPage: json['per_page'] is String
            ? int.tryParse(json['per_page'] as String) ?? 10
            : json['per_page'] as int? ?? 10,
        total: json['total'] as int? ?? 0,
      );
    }

    return PaginatedResponse<T>(
      success: success,
      message: message,
      data: data,
      meta: meta,
    );
  }
}

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] is String
          ? int.tryParse(json['per_page'] as String) ?? 10
          : json['per_page'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
    );
  }
}
