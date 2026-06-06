import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:okanehoshi/core/widgets/app_button.dart';
import 'package:okanehoshi/core/widgets/app_text_field.dart';
import 'package:okanehoshi/core/widgets/error_snackbar.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            RegisterSubmitted(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              phone: _phoneController.text.trim(),
              password: _passwordController.text,
              passwordConfirmation: _passwordConfirmController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure && (state.errors == null || state.errors!.isEmpty)) {
            ErrorSnackbar.show(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          String? nameError;
          String? emailError;
          String? phoneError;
          String? passwordError;
          String? passwordConfirmError;
          if (state is AuthFailure) {
            nameError = state.errors?['name']?.firstOrNull;
            emailError = state.errors?['email']?.firstOrNull;
            phoneError = state.errors?['phone']?.firstOrNull;
            passwordError = state.errors?['password']?.firstOrNull;
            passwordConfirmError = state.errors?['password_confirmation']?.firstOrNull;
          }

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Buat Akun Baru',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lengkapi data di bawah untuk mulai menggunakan aplikasi',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),

                      // Nama Input
                      AppTextField(
                        controller: _nameController,
                        label: 'Nama Lengkap',
                        hint: 'Masukkan nama lengkap',
                        prefixIcon: const Icon(Icons.person_outline),
                        errorText: nameError,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Input
                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'nama@email.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        errorText: emailError,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // No HP Input
                      AppTextField(
                        controller: _phoneController,
                        label: 'Nomor HP',
                        hint: '081234567890',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined),
                        errorText: phoneError,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nomor HP tidak boleh kosong';
                          }
                          if (!RegExp(r'^[0-9]{9,15}$').hasMatch(value.trim())) {
                            return 'Nomor HP tidak valid (9-15 digit angka)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Input
                      AppTextField(
                        controller: _passwordController,
                        label: 'Sandi',
                        hint: 'Minimal 8 karakter',
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        errorText: passwordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Sandi tidak boleh kosong';
                          }
                          if (value.length < 8) {
                            return 'Sandi minimal harus 8 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Confirm Input
                      AppTextField(
                        controller: _passwordConfirmController,
                        label: 'Konfirmasi Sandi',
                        hint: 'Ulangi sandi Anda',
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        errorText: passwordConfirmError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Konfirmasi sandi tidak boleh kosong';
                          }
                          if (value != _passwordController.text) {
                            return 'Konfirmasi sandi tidak sesuai';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      AppButton(
                        label: 'Daftar',
                        isLoading: isLoading,
                        onPressed: _onSubmit,
                      ),
                      const SizedBox(height: 24),

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Sudah punya akun? '),
                          GestureDetector(
                            onTap: () {
                              context.pop();
                            },
                            child: Text(
                              'Masuk Sekarang',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
