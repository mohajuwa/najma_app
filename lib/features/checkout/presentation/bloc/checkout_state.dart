part of 'checkout_bloc.dart';

abstract class CheckoutState {}

class CheckoutInitial  extends CheckoutState {}
class CheckoutLoading  extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {
  final String trackToken;
  CheckoutSuccess(this.trackToken);
}

class CheckoutError extends CheckoutState {
  final String message;
  CheckoutError(this.message);
}
