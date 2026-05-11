import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stateful_ai/widget/button/rounded_button.dart';
import 'package:stateful_ai/widget/logo/logo_widget.dart';
import 'package:stateful_ai/widget/svg/svg_ui.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  LogoWidget(),
                  Column(
                    children: [
                      RoundedButton(
                        icon: const SvgUI('ic_google.svg'),
                        label: 'Login dengan Google',
                        onPressed: () {
                          context.read<AuthBloc>().add(LoginWithGoogleEvent());
                        },
                      ),
                      const SizedBox(height: 12),
                      RoundedButton(
                        icon: SvgUI(
                          Theme.of(context).brightness == Brightness.dark
                              ? 'ic_apple.svg'
                              : 'ic_apple_white.svg',
                        ),
                        label: 'Login dengan Apple',
                        invertOnDark: true,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
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
