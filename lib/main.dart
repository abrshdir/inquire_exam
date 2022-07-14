import 'package:flutter/material.dart';
import 'package:inquire_exam/providers/post.dart';
import 'package:inquire_exam/providers/post_detail.dart';
import 'package:inquire_exam/providers/posts.dart';
import 'package:inquire_exam/screens/post_detail_screen.dart';
import 'package:inquire_exam/screens/posts_screen.dart';
import 'package:inquire_exam/screens/splash_screen.dart';
import 'package:inquire_exam/screens/update_posts_screen.dart';
import 'package:provider/provider.dart';
import './providers/auth.dart';
import './screens/auth_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: Auth(),
          ),
          ChangeNotifierProvider.value(
            value: Posts(),
          ),
          // ChangeNotifierProxyProvider<Posts, PostDetail>(
          //   create: ,
          //   update: (ctx, auth, previousProducts) => Products(
          //     auth.token,
          //     auth.userId,
          //     previousProducts == null ? [] : previousProducts.items,
          //   ),
          // ),
        ],
        child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Auth>(
      builder: (ctx, auth, _) =>
          MaterialApp(
            title: 'Inquire Exam',
            theme: ThemeData(
              fontFamily: 'Lato', colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple).copyWith(secondary: Colors.deepOrange),
            ),
            home: auth.isAuth ? const PostsScreen() : FutureBuilder(
              future: auth.tryAutoLogin(),
              builder: (ctx, authResultSnapshot) =>
              authResultSnapshot.connectionState ==
                  ConnectionState.waiting
                  ? const SplashScreen()
                  : AuthScreen(),
            ),
            routes: {
              PostDetailScreen.routeName: (ctx) => const PostDetailScreen(),
              PostsScreen.routeName: (ctx) => const PostsScreen(),
              UpdatePostsScreen.routeName: (ctx) => const UpdatePostsScreen(),
            },
          ),
    );
  }
}
