import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:block_wishlist_and_cart_app/features/cart/bloc/cart_bloc.dart';
import 'package:block_wishlist_and_cart_app/features/wishlist/bloc/wishlist_bloc.dart';

class Wishlist extends StatelessWidget {
  Wishlist({super.key});

  final WishlistBloc wishlistBloc = WishlistBloc();
  final CartBloc cartBloc = CartBloc();

  @override
  Widget build(BuildContext context) {
    wishlistBloc.add(LoadWishlistEvent());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Wishlist",
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      body: BlocBuilder<WishlistBloc, WishlistState>(
        bloc: wishlistBloc,
        builder: (context, state) {
          if (state is WishlistLoadingState || state is WishlistInitialState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WishlistLoadedState) {
            if (state.wishlistItems.isEmpty) {
              return const Center(
                child: Text(
                  "Your wishlist is empty",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.wishlistItems.length,
              itemBuilder: (context, index) {
                final product = state.wishlistItems[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product.imageUrl,
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// Product Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${product.price} PKR",
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Buttons
                        Column(
                          children: [
                            // Remove icon
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                wishlistBloc.add(RemoveFromWishlistEvent(product));
                              },
                            ),

                            // Move to cart button
                            ElevatedButton(
                              onPressed: () {
                                // 1. Add item to cart
                                cartBloc.add(AddToCartEvent(product));

                                // 2. Remove from wishlist
                                wishlistBloc.add(RemoveFromWishlistEvent(product));

                                // 3. Show confirmation
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Moved to cart"),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              ),
                              child: const Text(
                                "Move to Cart",
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const Center(child: Text("Something went wrong!"));
        },
      ),
    );
  }
}
