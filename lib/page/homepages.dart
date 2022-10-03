import 'package:flutter/material.dart';
import 'package:flutter_application/helpers/apihelper.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/providers/homepageproviders.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  ScrollController _scrollController = ScrollController();

  _showSnackbar(String message, {Color bgColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bgColor ?? Colors.red,
      ),
    );
  }

  _hideSnackbar() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  _getPosts({bool refresh = true}) async {
    var provider = Provider.of<HomePageProvider>(context, listen: false);
    if (!provider.shouldRefresh) {
      _showSnackbar('That\'s it for now!');
      return;
    }
    if (refresh) _showSnackbar('Loading more...', bgColor: Colors.green);

    var postsResponse = await APIHelper.getPosts(
      limit: 20,
      page: provider.currentPage,
    );
    if (postsResponse.isSuccessful) {
      if (postsResponse.data.isNotEmpty) {
        if (refresh) {
          provider.mergePostsList(postsResponse.data, notify: false);
        } else {
          provider.setPostsList(postsResponse.data, notify: false);
        }
        provider.setCurrentPage(provider.currentPage + 1);
      } else {
        provider.setShouldRefresh(false);
      }
    } else {
      _showSnackbar(postsResponse.message);
    }
    provider.setIsHomePageProcessing(false);
    _hideSnackbar();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        if (_scrollController.offset ==
            _scrollController.position.maxScrollExtent) {
          _getPosts();
        }
      }
    });
    _getPosts(refresh: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Text('Provider REST'),
      ),
      body: Consumer<HomePageProvider>(
        builder: (_, provider, __) => provider.isHomePageProcessing
            ? Center(
                child: CircularProgressIndicator(),
              )
            : provider.postsListLength > 0
                ? ListView.builder(
                    physics: BouncingScrollPhysics(),
                    controller: _scrollController,
                    itemBuilder: (_, index) {
                      Post post = provider.getPostByIndex(index);
                      return ListTile(
                        title: Text(post.title),
                        subtitle: Text(
                          post.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                    itemCount: provider.postsListLength,
                  )
                : Center(
                    child: Text('Nothing to show here!'),
                  ),
      ),
    );
  }
}
