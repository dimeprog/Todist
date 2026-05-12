class ResponseData<T> {
  final String message;
  final int? code;
  final T data;
  final Map<String, dynamic>? extra;
  const ResponseData({
    this.code,
    this.message = '',
    required this.data,
    this.extra,
  });
}
