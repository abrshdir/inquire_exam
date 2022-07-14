import 'package:flutter/material.dart';
import 'package:inquire_exam/providers/posts.dart';
import 'package:inquire_exam/screens/update_posts_screen.dart';
import 'package:inquire_exam/widgets/app_drawer.dart';
import 'package:inquire_exam/widgets/post_tile.dart';
import 'package:provider/provider.dart';

class PostsScreen extends StatefulWidget {

  static const routeName = '/posts-screen';

  const PostsScreen({Key? key}) : super(key: key);

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {

  Future<void> _refreshPosts(BuildContext context) async {
    await Provider.of<Posts>(context, listen: false)
        .fetchAndSetPosts();
  }

  @override
  Widget build(BuildContext context) {
    // final postsData = Provider.of<Posts>(context);
    print('rebuilding...');
    return Scaffold(
      backgroundColor: const Color(0xFF432355),
      appBar: AppBar(
        title: const Text('Posts'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(UpdatePostsScreen.routeName);
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: _refreshPosts(context),
        builder: (ctx, snapshot) =>
        snapshot.connectionState == ConnectionState.waiting
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : RefreshIndicator(
          onRefresh: () => _refreshPosts(context),
          child: Consumer<Posts>(
            builder: (ctx, postsData, _) => Padding(
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: postsData.posts.length,
                itemBuilder: (_, i) => Column(
                  children: [
                    PostTile(
                      id: postsData.posts[i].id!,
                      title: postsData.posts[i].title!,
                      body: postsData.posts[i].body!,
                    ),
                    const Divider(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
