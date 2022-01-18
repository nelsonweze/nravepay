import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import '../utils/utils.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc() : super(TransactionState()) {
    on((event, emit) async {
      if (event is UpdateState) {
        emit(event.state);
      }
      if (event is UpdateLoading) {
        emit(state.copyWith(loadingState: event.status));
      }
    });
  }
  static TransactionBloc get instance => ngetIt<TransactionBloc>();
}

enum LoadingState { active, done }
enum AuthMode { initial, pin, otp, avsSecure }

class TransactionState {
  final AuthMode auth;
  final ValueChanged<dynamic>? callback;
  final LoadingState loadingState;
  final data;

  TransactionState(
      {this.auth = AuthMode.initial,
      this.callback,
      this.data,
      this.loadingState = LoadingState.done});

  TransactionState copyWith(
      {final AuthMode? auth,
      final ValueChanged<dynamic>? callback,
      final LoadingState? loadingState,
      final data}) {
    return TransactionState(
        auth: auth ?? this.auth,
        callback: callback ?? this.callback,
        loadingState: loadingState ?? this.loadingState,
        data: data ?? this.data);
  }
}

abstract class TransactionEvent {}

class UpdateState extends TransactionEvent {
  final TransactionState state;
  UpdateState({required this.state});
}

class UpdateLoading extends TransactionEvent {
  final LoadingState status;
  UpdateLoading({required this.status});
}
