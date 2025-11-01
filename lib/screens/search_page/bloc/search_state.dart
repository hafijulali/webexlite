import 'package:equatable/equatable.dart';
import 'package:webexapis/routes/search/model.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<SearchResult> results;
  final List<String> recentSearches;

  const SearchLoaded({this.results = const [], this.recentSearches = const []});

  @override
  List<Object> get props => [results, recentSearches];
}

class SearchError extends SearchState {
  final String error;

  const SearchError(this.error);

  @override
  List<Object> get props => [error];
}
