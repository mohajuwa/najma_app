part of 'checkout_bloc.dart';

abstract class CheckoutEvent {}

class SubmitOrderEvent extends CheckoutEvent {
  final int    serviceId;
  final String fanName;
  final String? fanPhone;
  final String? message;
  final String  timing;

  SubmitOrderEvent({
    required this.serviceId,
    required this.fanName,
    this.fanPhone,
    this.message,
    required this.timing,
  });
}
