import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/validators.dart';
import '../../state/auth_controller.dart';
import '../widgets/retro_auth_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    final success = await auth.register(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
    );
    if (mounted) {
      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.errorMessage ?? 'Erro ao cadastrar.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = context.watch<AuthController>().isBusy;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Criar conta',
          style: TextStyle(fontFamily: 'monospace'),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/Hatsune miku home.jpg',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        RetroAuthField(
                          controller: _emailController,
                          hint: 'E-mail',
                          hintColor: const Color(0xFF57B8FF),
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 8),
                        RetroAuthField(
                          controller: _nameController,
                          hint: 'Nome',
                          hintColor: const Color(0xFF57B8FF),
                          validator: (v) =>
                              Validators.required(v, label: 'Nome'),
                        ),
                        const SizedBox(height: 8),
                        RetroAuthField(
                          controller: _passwordController,
                          hint: 'Senha',
                          hintColor: const Color(0xFF00CFCF),
                          obscureText: _obscurePassword,
                          validator: Validators.password,
                          suffixIcon: GestureDetector(
                            onTap: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        RetroAuthButton(
                          label: 'Criar conta',
                          onPressed: _submit,
                          isLoading: isBusy,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
