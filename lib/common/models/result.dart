class Result<T, E> {
  factory Result.failure(E value) {
    return Result._(failure: value);
  }

  factory Result.success(T value) {
    return Result._(success: value);
  }

  const Result._({this.success, this.failure});
  final T? success;
  final E? failure;

  bool get isSuccess => success != null;
  bool get isFailure => failure != null;

  void when({
    required void Function(T) onSuccess,
    required void Function(E) onFailure,
  }) {
    if (success != null) {
      onSuccess(success as T);
    } else {
      onFailure(failure as E);
    }
  }
}
