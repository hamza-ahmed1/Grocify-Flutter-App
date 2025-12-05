import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:block_wishlist_and_cart_app/data/cart_items.dart';
import 'package:block_wishlist_and_cart_app/data/wishlist_items.dart';
import 'package:block_wishlist_and_cart_app/features/home/models/home_product_data_model.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

/// BLoC for the Home screen.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FirebaseFirestore _firestore;

  /// Full unfiltered product list loaded from Firestore.
  List<ProductDataModel> _allProducts = [];

  HomeBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(HomeInitial()) {
    on<HomeInitialEvent>(_onHomeInitial);
    on<HomeProductWishlistButtonClickedEvent>(_onWishlistClicked);
    on<HomeProductCartButtonClickedEvent>(_onCartClicked);
    on<HomeWishlistButtonNavigateEvent>(_onWishlistNavigate);
    on<HomeCartButtonNavigateEvent>(_onCartNavigate);
    on<HomeCategorySelectedEvent>(_onCategorySelected);
  }

  // ---------------------------------------------------------------------------
  // Event handlers
  // ---------------------------------------------------------------------------

  Future<void> _onHomeInitial(
    HomeInitialEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoadingState());

    try {
      final snapshot = await _firestore.collection('products').get();

      final products = snapshot.docs.map((doc) {
        final data = doc.data();

        // ---- Price ----
        final rawPrice = data['Price'];
        double price = 0.0;
        if (rawPrice is num) {
          price = rawPrice.toDouble();
        } else if (rawPrice is String) {
          price = double.tryParse(rawPrice) ?? 0.0;
        }

        // ---- Category ----
        // Your Firestore field is "Collection" (singular).
        // We also support "Collections" in case you ever change it.
        String category = '';
        final collField = data['Collection'];
        final collFieldAlt = data['Collections'];
        final value = collField ?? collFieldAlt;

        if (value is String) {
          category = value.trim();
        } else if (value is List && value.isNotEmpty) {
          category = value.first.toString();
        }

        return ProductDataModel(
          id: (data['URL handle'] ?? doc.id).toString(),
          name: (data['Title'] ?? '').toString(),
          description: (data['Description'] ?? '').toString(),
          imageUrl: (data['Image URL'] ?? '').toString(),
          price: price,
          category: category,
        );
      }).toList();

      _allProducts = products;

      // Initially show all products
      emit(HomeLoadedSuccessState(
        products: products,
        selectedCategory: 'All',
      ));
    } catch (e, st) {
      // ignore: avoid_print
      print('Error loading products: $e');
      // ignore: avoid_print
      print(st);
      emit(HomeErrorState());
    }
  }

  FutureOr<void> _onWishlistClicked(
    HomeProductWishlistButtonClickedEvent event,
    Emitter<HomeState> emit,
  ) {
    wishlistItems.add(event.clickedProduct);
    emit(HomeProductItemWishlistedActionState());
  }

  FutureOr<void> _onCartClicked(
    HomeProductCartButtonClickedEvent event,
    Emitter<HomeState> emit,
  ) {
    cartItems.add(event.clickedProduct);
    emit(HomeProductItemCartedActionState());
  }

  FutureOr<void> _onWishlistNavigate(
    HomeWishlistButtonNavigateEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(HomeNavigateToWishlistPageActionState());
  }

  FutureOr<void> _onCartNavigate(
    HomeCartButtonNavigateEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(HomeNavigateToCartPageActionState());
  }

  /// Filter products by category using the cached [_allProducts] list.
  /// 'All' means show everything.
  FutureOr<void> _onCategorySelected(
    HomeCategorySelectedEvent event,
    Emitter<HomeState> emit,
  ) {
    if (_allProducts.isEmpty) return null;

    final selected = event.category.trim();
    if (selected.isEmpty || selected.toLowerCase() == 'all') {
      emit(HomeLoadedSuccessState(
        products: _allProducts,
        selectedCategory: 'All',
      ));
      return null;
    }

    final filtered = _allProducts
        .where(
          (p) => p.category.toLowerCase() == selected.toLowerCase(),
        )
        .toList();

    emit(HomeLoadedSuccessState(
      products: filtered,
      selectedCategory: selected,
    ));
  }
}
