import 'package:flutter/material.dart';
import 'package:inquire_exam/providers/post.dart';
import 'package:inquire_exam/providers/posts.dart';
import 'package:provider/provider.dart';

class UpdatePostsScreen extends StatefulWidget {
  static const routeName = '/edit-post';

  const UpdatePostsScreen({Key? key}) : super(key: key);

  @override
  _UpdatePostsScreenState createState() => _UpdatePostsScreenState();
}

class _UpdatePostsScreenState extends State<UpdatePostsScreen> {

  final _bodyFocusNode = FocusNode();
  final _titleFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedPost = Post(
    id: null,
    title: '',
    body: ''
  );
  var _initValues = {
    'title': '',
    'body': '',
  };

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final postId = ModalRoute.of(context)!.settings.arguments;
      if (postId != null) {
        _editedPost = Provider.of<Posts>(context, listen: false).findById(int.parse(postId.toString()));
        _initValues = {
          'title': _editedPost.title!,
          'body': _editedPost.body!,
        };
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bodyFocusNode.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedPost.id != null) {
      await Provider.of<Posts>(context, listen: false).updatePost(_editedPost.id, _editedPost);
    } else {
      try {
        await Provider.of<Posts>(context, listen: false).addPost(_editedPost);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('An error occurred!'),
            content: const Text('Something went wrong.'),
            actions: <Widget>[
              FlatButton(
                child: const Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF432355),
      appBar: AppBar(
        title: const Text('Edit Post'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValues['title']!,
                      decoration: const InputDecoration(labelText: 'Title', labelStyle: TextStyle(color: Colors.white), focusColor: Colors.white, fillColor: Colors.white),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_titleFocusNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedPost = Post(
                            title: value,
                            body: _editedPost.body,
                            id: _editedPost.id,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['body'],
                      decoration: const InputDecoration(labelText: 'Body', labelStyle: TextStyle(color: Colors.white)),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _bodyFocusNode,
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
                        _editedPost = Post(
                          title: _editedPost.title,
                          body: value,
                          id: _editedPost.id,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
