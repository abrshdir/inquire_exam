import 'package:flutter/material.dart';
import 'package:inquire_exam/providers/post_detail.dart';
import 'package:provider/provider.dart';

import '../providers/posts.dart';

class PostDetailScreen extends StatefulWidget {
  static const routeName = '/post-detail';

  const PostDetailScreen({Key? key}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController controller = TextEditingController();

  late bool _isLoading;

  late int globalPostId = 0;

  final _form = GlobalKey<FormState>();
  final _commentFocusNode = FocusNode();

  var _newComment = Comments(
    postId: 0.toString(),
    body: '',
  );

  Future<void> _saveForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Posts>(context, listen: false).addComment(_newComment);
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('An error occurred!'),
          content: const Text('Something went wrong.'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
    // Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: const Color(0xFFB271DA),
        appBar: AppBar(
          title: const Text('Your Post'),
          leading: IconButton(
            /// Changed Here
            color: Colors.white,
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView(
          shrinkWrap: true,
          children: [
            FutureBuilder(
                future: _refreshPosts(context),
                builder: (ctx, snapshot) {
                  return Consumer<Posts>(
                      builder: (ctx, postsData, _) => SizedBox(
                            height: size.height * 0.65,
                            child: Column(
                              children: [
                                Container(
                                  color: Colors.purple,
                                  child: Padding(
                                    padding: const EdgeInsets.all(18.0),
                                    child: Text(postsData.postDetails.title.toString(), style: const TextStyle(color: Colors.white, fontSize: 15)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(postsData.postDetails.body.toString(), style: const TextStyle(color: Colors.white, fontSize: 15)),
                                ),
                                const Divider(),
                                const Text(
                                  'Comments',
                                  style: TextStyle(color: Colors.black, fontSize: 20),
                                ),
                                postsData.postDetails.comments == null
                                    ? const SizedBox()
                                    : Expanded(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: postsData.postDetails.comments!.length,
                                          itemBuilder: (_, i) => Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                                color: Colors.purple,
                                                child: ListTile(
                                                    title: Text(postsData.postDetails.comments![i].body.toString(), style: const TextStyle(color: Colors.white, fontSize: 15)))),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ));
                }),
            Container(
              color: Colors.white,
              width: 100,
              child: Form(
                key: _form,
                child: Container(
                  color: Colors.purple,
                  width: size.width * 0.7,
                  child: TextFormField(
                    initialValue: '',
                    decoration: const InputDecoration(labelText: 'Your Comment here', labelStyle: TextStyle(color: Colors.grey, fontSize: 21)),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    focusNode: _commentFocusNode,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a body.';
                      }
                      if (value.length < 10) {
                        return 'Should be at least 10 characters long.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _newComment = Comments(
                        postId: globalPostId.toString(),
                        body: value,
                      );
                    },
                  ),
                ),
              ),
            ),
            ElevatedButton(
              child: const Text("Send Comment"),
              onPressed: _saveForm
            ),
          ],
        ));
  }
}
