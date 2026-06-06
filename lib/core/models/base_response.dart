class BaseResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, List<String>>? errors;

  BaseResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final success = json['success'] as bool? ?? false;
    final message = json['message'] as String?;
    final rawData = json['data'];

    T? data;
    if (rawData != null) {
      try {
        data = fromJsonT(rawData);
      } catch (_) {
        data = null;
      }
    }

    Map<String, List<String>>? errors;
    if (json.containsKey('errors') && json['errors'] is Map) {
      final rawErrors = json['errors'] as Map<String, dynamic>;
      errors = rawErrors.map((key, value) {
        if (value is List) {
          return MapEntry(key, List<String>.from(value));
        } else {
          return MapEntry(key, [value.toString()]);
        }
      });
    }

    return BaseResponse<T>(
      success: success,
      message: message,
      data: data,
      errors: errors,
    );
  }
}
