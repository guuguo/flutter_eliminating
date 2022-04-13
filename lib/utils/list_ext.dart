extension ListExt on Iterable {
  List<T> separated<T>(ItemBuilder<T> separateBuilder) {
    List<T> newList = [];
    var i = 0;
    this.forEach((element) {
      newList.add(element);
      if (i != this.length - 1) {
        newList.add(separateBuilder(i));
        i++;
      }
    });
    return newList;
  }
}
extension ListTExt<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T toElement(int index, E e)) {
    final list = this.toList();
    return list.asMap().keys.map((i) => toElement(i, list[i]));
  }

  Future<R> foldIndexedFuture<R>(R initialValue, Future<R> Function(int index, R previous, E element) combine) async  {
    var result = initialValue;
    var index = 0;
    for (var element in this) {
      result =await combine(index++, result, element);
    }
    return result;
  }
}

typedef ItemBuilder<T> =T Function(int index);