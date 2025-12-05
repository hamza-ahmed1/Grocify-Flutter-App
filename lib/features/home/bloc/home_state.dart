part of 'home_bloc.dart';

@immutable
abstract class HomeState {}

/// Marker base class for states that should be handled in `BlocConsumer.listener`
/// and NOT trigger a rebuild (navigation, snackbars, etc.).
abstract class HomeActionState extends HomeState {}

class HomeInitial extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeLoadedSuccessState extends HomeState {
  final List<ProductDataModel> products;

  /// The currently selected category.
  /// 'All' means no filter (show everything).
  final String selectedCategory;

  HomeLoadedSuccessState({
    required this.products,
    required this.selectedCategory,
  });
}

class HomeErrorState extends HomeState {}

class HomeNavigateToWishlistPageActionState extends HomeActionState {}

class HomeNavigateToCartPageActionState extends HomeActionState {}

class HomeProductItemWishlistedActionState extends HomeActionState {}

class HomeProductItemCartedActionState extends HomeActionState {}
