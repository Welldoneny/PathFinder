sealed class MyResult<T> {
  const MyResult();
}

final class Ok<T> extends MyResult<T> {
  const Ok(this.value);
  final T value;
}

final class Error<T> extends MyResult<T> {
  const Error(this.error);
  final Exception error;
}