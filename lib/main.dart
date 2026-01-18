import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'features/authentication/data/auth_service.dart';
import 'features/authentication/presentation/cubit/auth_cubit.dart';
// Import your ChatCubit and ChatPage/Service locations
import 'features/chat/presentation/cubit/chat_cubit.dart'; 
import 'core/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiBlocProvider ensures all cubits are available globally
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(AuthService()),
        ),
        BlocProvider<ChatCubit>(
          create: (_) => ChatCubit(), // Your new ChatCubit
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashPage(),
      ),
    );
  }
}