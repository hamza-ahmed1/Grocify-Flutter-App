import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:block_wishlist_and_cart_app/data/cart_items.dart';

// ============ EVENTS ============

abstract class CheckoutEvent {}

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

// ============ STATES ============

abstract class CheckoutState {}

class CheckoutInitialState extends CheckoutState {}

class CheckoutLoadingState extends CheckoutState {}

class CheckoutSuccessState extends CheckoutState {
  final String orderId;

  CheckoutSuccessState({required this.orderId});
}

class CheckoutFailureState extends CheckoutState {
  final String message;

  CheckoutFailureState(this.message);
}

// ============ BLOC ============

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CheckoutBloc() : super(CheckoutInitialState()) {
    on<SubmitCheckoutEvent>(_onSubmitCheckout);
  }

  Future<void> _onSubmitCheckout(
    SubmitCheckoutEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    try {
      emit(CheckoutLoadingState());

      final user = _auth.currentUser;
      if (user == null) {
        emit(CheckoutFailureState('You must be logged in to place an order.'));
        return;
      }

      if (event.paymentMethod != 'COD') {
        emit(CheckoutFailureState('Only Cash on Delivery is available right now.'));
        return;
      }

      if (cartItems.isEmpty) {
        emit(CheckoutFailureState('Your cart is empty.'));
        return;
      }

      // Calculate total
      double total = 0;
      for (final item in cartItems) {
        total += item.price; // later you can multiply by quantity
      }

      // Map cart items into plain maps for Firestore
      final List<Map<String, dynamic>> orderItems = cartItems.map((item) {
        return {
          'id': item.id,
          'name': item.name,
          'description': item.description,
          'price': item.price,
          'imageUrl': item.imageUrl,
          'qty': 1, // TODO: hook up real quantities later
        };
      }).toList();

      // Create order document under users/{uid}/orders
      final orderRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .add({
        'createdAt': FieldValue.serverTimestamp(),
        'totalAmount': total,
        'paymentMethod': event.paymentMethod,
        'name': event.name,
        'phone': event.phone,
        'address1': event.address1,
        'address2': event.address2,
        'items': orderItems,
      });

      // Optionally keep user doc's cart array empty / in sync
      await _firestore.collection('users').doc(user.uid).update({
        'cart': [],
      });

      // Clear in-memory cart as well
      cartItems.clear();

      emit(CheckoutSuccessState(orderId: orderRef.id));
    } catch (e) {
      emit(
        CheckoutFailureState('Failed to place order. Please try again.'),
      );
    }
  }
}
