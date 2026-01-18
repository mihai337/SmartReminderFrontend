abstract interface class TaskObservable {
  void registerObserver(TaskObserver o);
  void removeObserver(TaskObserver o);
  void notifyObservers();
}

abstract interface class TaskObserver{
  void update();
}