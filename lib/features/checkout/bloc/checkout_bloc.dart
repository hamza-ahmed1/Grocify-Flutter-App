import 'package:flutter_bloc/flutter_bloc.dart';

class CheckoutEvent {}

class SubmitCheckoutEvent extends CheckoutEvent {
  final String name;
  final String phone;
  final String address1;
  final String address2;
  final String paymentMethod;

  SubmitCheckoutEvent(
    this.name,
    this.phone,
    this.address1,
    this.address2,
    this.paymentMethod,
  );
}

class CheckoutState {}

class CheckoutInitialState extends CheckoutState {}

class CheckoutLoadingState extends CheckoutState {}

class CheckoutSuccessState extends CheckoutState {
  final String paymentMethod;
  CheckoutSuccessState(this.paymentMethod);
}

class CheckoutFailureState extends CheckoutState {
  final String message;
  CheckoutFailureState(this.message);
}

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc() : super(CheckoutInitialState()) {
    on<SubmitCheckoutEvent>((event, emit) async {
      // ----------- VALIDATION LOGIC -------------
      if (event.name.trim().isEmpty ||
          event.phone.trim().isEmpty ||
          event.address1.trim().isEmpty ||
          event.address2.trim().isEmpty ||
          event.paymentMethod.trim().isEmpty) 
      {
        emit(CheckoutFailureState("Please fill all fields"));
        return;
      }

      emit(CheckoutLoadingState());

      await Future.delayed(Duration(seconds: 2));

      // Only COD allowed for now
      if (event.paymentMethod == "COD") {
        emit(CheckoutSuccessState(event.paymentMethod));
      } else {
        emit(CheckoutFailureState("Online payment coming soon"));
      }
    });
  }
}
