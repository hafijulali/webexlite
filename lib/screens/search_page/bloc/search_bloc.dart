
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
        logger?.log('SearchBloc: API search response: $response');
        if (response['items'] != null) {
          final results = (response['items'] as List<Map<String, dynamic>>).map((item) {
            try {
              return SearchResult.fromJson(item);
            } catch (e, st) {
              logger?.error(
                'SearchBloc: Error parsing API search result',
                stackTrace: st,
                extra: {'json_data': item, 'query': event.query},
                tags: {'parsing_context': 'api_search_result'},
              );
              return null;
            }
          }).whereType<SearchResult>().toList();
          logger?.log('SearchBloc: Mapped results count: ${results.length}');
          // Save search query to history
          await searchDatabase?.put(event.query, true);
          final recentSearches =
              searchDatabase?.keys.cast<String>().toList() ?? [];
          logger?.log(
              'SearchBloc: Emitting SearchLoaded with results and recent searches.');
          emit(SearchLoaded(results: results, recentSearches: recentSearches));
        } else {
          logger?.log(
              'SearchBloc: API search response has no items. Emitting SearchError.');
          emit(SearchError(response['message'] ?? 'Failed to perform search.'));
        }
      } catch (e) {
      logger?.log('SearchBloc: Error during API call: $e');
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
