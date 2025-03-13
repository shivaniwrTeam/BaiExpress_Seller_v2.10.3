extension ListExt<T> on List<T> {
  void addOrRemove(T element) {
    if (contains(element)) {
      remove(element);
    } else {
      add(element);
    }
  }

  void clearAndAddAll(List<T> elements) {
    clear();
    addAll(elements);
  }

  void clearAndAdd(T elements) {
    clear();
    add(elements);
  }

  bool containesAll(List<T> element) {
    int _has = 0;

    for (var i = 0; i < element.length; i++) {
      if (contains(element[i])) {
        _has++;
      }
    }

    return _has == element.length;
  }

  bool isFirst(T element) {
    return first == element;
  }

  bool isSingleElementAndIs(T element) {
    if (length == 1) {
      return first == element;
    }
    return false;
  }

  List<B> condition<B>(List<B> Function(List<T> list) cdt) {
    return cdt.call(this);
  }

  dynamic sum(num Function(T e) fn) {
    dynamic joinner;
    for (var value in this) {
      dynamic valFromFn = fn.call(value);
      if (joinner == null) {
        joinner = valFromFn;
      } else {
        joinner += valFromFn;
      }
    }
    return joinner;
  }
}
