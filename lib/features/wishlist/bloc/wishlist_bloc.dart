import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:block_wishlist_and_cart_app/features/home/models/home_product_data_model.dart';


/// EVENTS
abstract class WishlistEvent {}

class LoadWishlistEvent extends WishlistEvent {}

class AddToWishlistEvent extends WishlistEvent {
  final ProductDataModel product;
  AddToWishlistEvent(this.product);
}

class RemoveFromWishlistEvent extends WishlistEvent {
  final ProductDataModel product;
  RemoveFromWishlistEvent(this.product);
}


/// STATES
abstract class WishlistState {}

class WishlistInitialState extends WishlistState {}

class WishlistLoadingState extends WishlistState {}

class WishlistLoadedState extends WishlistState {
  final List<ProductDataModel> wishlistItems;
  WishlistLoadedState(this.wishlistItems);
}


/// BLOC
class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final List<ProductDataModel> _wishlist = [];  // << replaces global list

  WishlistBloc() : super(WishlistInitialState()) {
    
    on<LoadWishlistEvent>((event, emit) {
      emit(WishlistLoadingState());

      Future.delayed(const Duration(milliseconds: 300), () {
        emit(WishlistLoadedState(List.from(_wishlist)));
      });
    });

    on<AddToWishlistEvent>((event, emit) {
      if (!_wishlist.contains(event.product)) {
        _wishlist.add(event.product);
      }

      emit(WishlistLoadedState(List.from(_wishlist)));
    });

    on<RemoveFromWishlistEvent>((event, emit) {
      _wishlist.remove(event.product);

      emit(WishlistLoadedState(List.from(_wishlist)));
    });
  }
}
