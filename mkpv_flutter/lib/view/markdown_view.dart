import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_mkpv/view/markdown_view_model.dart';

class MarkdownView extends StatefulWidget {
  const MarkdownView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MarkdownViewState();
  }
}

class MarkdownViewState extends State<MarkdownView>
    with WidgetsBindingObserver {
  final MarkdownViewModel viewModel = MarkdownViewModel();
  @override
  void initState() {
    super.initState();
    viewModel.init();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
  }

  FloatingActionButton _floatingActionButton() {
    return FloatingActionButton(
      mini: true,
      onPressed: viewModel.onTapMode,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ValueListenableBuilder<bool>(
          valueListenable: viewModel.darkModeNotifier,
          builder: (_, isDark, __) {
            if (isDark) return const Icon(Icons.dark_mode);
            return const Icon(Icons.light_mode);
          },
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: viewModel.loadingNotifier,
      builder: (_, isLoading, __) {
        if (isLoading) return const SizedBox();
        return ValueListenableBuilder<bool>(
          valueListenable: viewModel.darkModeNotifier,
          builder: (_, isDark, __) {
            return Scaffold(
              backgroundColor: viewModel.background,
              floatingActionButton: _floatingActionButton(),
              body: ValueListenableBuilder<String>(
                valueListenable: viewModel.markdownNotofier,
                builder: (_, markdown, __) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: kToolbarHeight * 5),
                    child: Html(
                      anchorKey: viewModel.anchorKey,
                      style: viewModel.style,
                      data: markdown,
                      customRenders: {
                        tableMatcher(): tableRender(),
                      },
                      // onLinkTap: viewModel.onTapLink,
                      // onAnchorTap:viewModel.onAnchorTap,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
