import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class PerformSearch extends SearchEvent {
  final String query;

  const PerformSearch(this.query);

  @override
  List<Object> get props => [query];
}

class LoadRecentSearches extends SearchEvent {
  const LoadRecentSearches();
}

class ClearRecentSearches extends SearchEvent {
  const ClearRecentSearches();
}
