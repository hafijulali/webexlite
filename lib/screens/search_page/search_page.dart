import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webexlite/screens/search_page/bloc/search_bloc.dart';
import 'package:webexlite/screens/search_page/bloc/search_state.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is SearchLoaded) {
            return ListView.builder(
              itemCount: state.results.length,
              itemBuilder: (context, index) {
                final result = state.results[index];
                return ListTile(
                  title: Text(result.data['title'] ?? result.data['displayName'] ?? result.data['text'] ?? 'No title'),
                  subtitle: Text(result.type),
                );
              },
            );
          } else if (state is SearchError) {
            return Center(
              child: Text(state.error),
            );
          } else {
            return const Center(
              child: Text('Enter a search query to begin.'),
            );
          }
        },
      ),
    );
  }
}
