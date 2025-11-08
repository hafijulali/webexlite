
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webexapis/routes/search/model.dart';
import 'package:webexapis/webexapis.dart';
import 'package:webexlite/init.dart';

import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final WebexApis webexApis;

  SearchBloc({required this.webexApis}) : super(SearchInitial()) {
    on<PerformSearch>((event, emit) async {
      emit(SearchLoading());
      try {
        final response = await webexApis.search(query: event.query);
        logger?.debug('API search response: $response', source: 'SearchBloc');
        if (response['items'] != null) {
          final results = (response['items'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((item) {
            try {
              return SearchResult.fromJson(item);
            } catch (e, st) {
logger?.error(
                'Error parsing search result',
                source: 'SearchBloc',
              );
              return null;
            }
          }).whereType<SearchResult>().toList() ?? [];
          logger?.debug('Mapped results count: ${results.length}', source: 'SearchBloc');
      
          await searchDatabase?.put(event.query, true);
          final recentSearches =
              searchDatabase?.keys.cast<String>().toList() ?? [];
logger?.debug(
            'Failed to load recent searches from cache',
            source: 'SearchBloc');
          emit(SearchLoaded(results: results, recentSearches: recentSearches));
        } else {
          logger?.debug(
              'API search response has no items. Emitting SearchError.', source: 'SearchBloc');
          emit(SearchError(response['message'] ?? 'Failed to perform search.'));
        }
      } catch (e) {
      logger?.error('Error during API call: $e', source: 'SearchBloc');
        emit(SearchError(e.toString()));
      }
    });

    on<LoadRecentSearches>((event, emit) async {
      final recentSearches = searchDatabase?.keys.cast<String>().toList() ?? [];
      emit(SearchLoaded(recentSearches: recentSearches));
    });

    on<ClearRecentSearches>((event, emit) async {
      await searchDatabase?.clear();
      emit(const SearchLoaded(recentSearches: []));
    });
  }
}
