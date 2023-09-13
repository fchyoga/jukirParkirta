import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:jukirparkirta/data/repository/payment_repository.dart';

class PaymentBloc extends Cubit<PaymentState> {
  PaymentRepository _paymentRepository = PaymentRepository();

  PaymentBloc() : super(PaymentInitial());

  Future<void> paymentJukir(String inv, String isCardUsed, String? cardNumber) async {
    emit(LoadingState(true));
    final response =
    await _paymentRepository.paymentJukir(inv, isCardUsed, cardNumber);
    emit(LoadingState(false));
    if (response.success) {
      emit(PaymentSuccessState());
    } else {
      emit(ErrorState(error: response.message));
    }
  }

}

abstract class PaymentState {
  const PaymentState();
}

class PaymentInitial extends PaymentState {
}


class PaymentSuccessState extends PaymentState {
}

class ErrorState extends PaymentState {
  final String error;
  const ErrorState({required this.error});

}

class LoadingState extends PaymentState {
  final show;
  LoadingState(this.show);
}


