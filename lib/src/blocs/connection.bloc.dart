import 'dart:async';
import '../utils/utils.dart';

class ConnectionBloc {
  static ConnectionBloc get instance => ngetIt<ConnectionBloc>();
  final _controller = StreamController<ConnectionState>.broadcast();

  Stream<ConnectionState>? _stream;

  Stream<ConnectionState>? get stream => _stream;

  ConnectionBloc._() {
    _stream = _controller.stream;
    setState(ConnectionState.done);
  }

  factory ConnectionBloc() => ConnectionBloc._();

  void setState(ConnectionState s) => _controller.add(s);

  void dispose() => _controller.close();
}

enum ConnectionState { waiting, done }
