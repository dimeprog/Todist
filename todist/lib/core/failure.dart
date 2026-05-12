class Failure<T> {
  final String message;
  final int? code;
  final T? data;

  Failure(this.message, {this.code, this.data});

  @override
  String toString() => message;
}
