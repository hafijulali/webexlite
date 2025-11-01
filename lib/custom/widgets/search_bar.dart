import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webexlite/init.dart';
import 'package:webexlite/screens/search_page/bloc/search_bloc.dart';
import 'package:webexlite/screens/search_page/bloc/search_event.dart';
import 'package:webexlite/screens/search_page/bloc/search_state.dart';

class SearchBarWidget extends StatefulWidget {
  final void Function() onEditingComplete;
  final TextEditingController searchTextController;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.onEditingComplete,
    required this.searchTextController,
    this.hintText = 'Search',
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    logger?.log("SearchBarWidget: Building");
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        return Container(
          width: MediaQuery.of(context).size.width / 1.5,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueGrey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: TextField(
              textAlign: TextAlign.center,
              onEditingComplete: () {
                logger?.log("SearchBarWidget: onEditingComplete triggered");
                context
                    .read<SearchBloc>()
                    .add(PerformSearch(widget.searchTextController.text));
                widget.onEditingComplete();
              },
              controller: widget.searchTextController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => widget.searchTextController.clear(),
                ),
                hintText: widget.hintText,
                border: InputBorder.none,
              ),
            ),
          ),
        );
      },
    );
  }
}
