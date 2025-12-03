import 'package:block_wishlist_and_cart_app/features/checkout/ui/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:block_wishlist_and_cart_app/features/cart/bloc/cart_bloc.dart';
import 'package:block_wishlist_and_cart_app/features/cart/ui/cart_tile_widget.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final CartBloc cartBloc = CartBloc();
  @override
  void initState() {
    cartBloc.add(CartInitialEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart Items'),
      ),
      body: BlocConsumer<CartBloc, CartState>(
        bloc: cartBloc,
        listener: (context, state) {
          
        },
        listenWhen: (previous, current) => current is CartActionState,
        buildWhen: (previous, current) => current is! CartActionState,
        builder: (context, state) {
          switch (state.runtimeType) {
            case CartSuccessState:
              final successState = state as CartSuccessState;
return Column(
  children: [
    Expanded(
      child: ListView.builder(
        itemCount: successState.cartItems.length,
        itemBuilder: (context, index) {
          return CartTileWidget(
            cartBloc: cartBloc,
            productDataModel: successState.cartItems[index],
          );
        },
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(12.0),
     child: SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.amber,      // soft yellow
      foregroundColor: Colors.black,      // text color
      padding: EdgeInsets.symmetric(
        vertical: 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,                        // soft shadow
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w200,
      ),
    ),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CheckoutPage()),
      );
    },
    child: Text("Proceed to Checkout"),
  ),
),

    )
  ],
);


            default:
          }
          
          return Container();
        },
      ),
    );
  }
}
