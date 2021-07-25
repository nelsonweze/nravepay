import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/utils.dart';

class TransactionBloc {
  static TransactionBloc get instance => ngetIt<TransactionBloc>();
  final _controller = StreamController<TransactionState>.broadcast();

  Stream<TransactionState>? _stream;

  Stream<TransactionState>? get stream => _stream;

  TransactionBloc._() {
    _stream = _controller.stream;
    setState(TransactionState._defaults());
  }

  factory TransactionBloc() => TransactionBloc._();

  void setState(TransactionState s) => _controller.add(s);

  void dispose() => _controller.close();
}

class TransactionState {
  final State state;
  final ValueChanged<dynamic>? callback;
  final data;

  TransactionState({required this.state, this.callback, this.data});

  TransactionState._defaults()
      : state = State.initial,
        data = null,
        callback = null;
}

enum State { initial, pin, otp, avsSecure }
