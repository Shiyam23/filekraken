Stream<List<T>> accumulate<T>(Stream<T> stream) async*{
  List<T> list = [];
  await for (T result in stream) {
    list.add(result);
    yield list;
  }
}