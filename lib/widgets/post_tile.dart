import 'package:flutter/material.dart';
import 'package:inquire_exam/providers/posts.dart';
import 'package:provider/provider.dart';

import '../screens/post_detail_screen.dart';
import '../screens/update_posts_screen.dart';

class PostTile extends StatelessWidget {
  final int id;
  final String title;
  final String body;

  const PostTile({Key? key, required this.id, required this.title, required this.body}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return ListTile(
      title: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
            PostDetailScreen.routeName,
            arguments: id,
          );
        },
        child: Text(
          title,
          style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
        ),
      ),
      leading: CircleAvatar(
        child: Text(
          id.toString(),
          style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
        ),
      ),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(UpdatePostsScreen.routeName, arguments: id);
              },
              color: Theme.of(context).secondaryHeaderColor,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                try {
                  await Provider.of<Posts>(context, listen: false).deletePosts(id);
                } catch (error) {
                  scaffold.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Deleting failed!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
              },
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
    );
  }
}
