part of 'counter_bloc.dart';

@immutable
sealed class CounterEvent {}

class UpCount extends CounterEvent {
  final  String test;

  UpCount(this.test);
}


class FetchById extends CounterEvent {
  final  String id;

  FetchById(this.id);
}

