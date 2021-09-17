import 'package:equatable/equatable.dart';
import 'models.dart';

class HttpResult extends Equatable {
  /// The status of the transaction. Whether
  ///
  /// [HttpStatus.success] for when the transaction completes successfully,
  ///
  /// [HttpStatus.error] for when the transaction completes with an error,
  ///
  /// [HttpStatus.cancelled] for when the user cancelled
  final HttpStatus status;

  /// Raw response from Http. Can be null
  final Map? rawResponse;

  /// Human readable message
  final String? message;

  /// BankCard object returned if save card is set to [true]
  final BankCard? card;

  HttpResult({required this.status, this.rawResponse, this.message, this.card});

  @override
  String toString() {
    return 'HttpResult{status: $status, rawResponse: $rawResponse, message: $message}';
  }

  @override
  List<Object?> get props => [status, rawResponse, message, card];
}

enum HttpStatus { success, error, cancelled, left }
