import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Login gagal: ${state.error}')),
              );
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const CircularProgressIndicator();
            }
            return ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Login dengan Google'),
              onPressed: () {
                context.read<AuthBloc>().add(LoginWithGoogleEvent());
              },
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Stateful AI - Multi Model AI By kiki.dev',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }
}
