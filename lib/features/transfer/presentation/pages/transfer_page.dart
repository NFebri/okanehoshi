// withOpacity is deprecated in newer Flutter versions but withValues is not supported in the project's target SDK range.
// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:okanehoshi/core/widgets/app_button.dart';
import 'package:okanehoshi/core/widgets/app_text_field.dart';
import 'package:okanehoshi/core/widgets/error_snackbar.dart';
import '../bloc/transfer_bloc.dart';
import '../bloc/transfer_event.dart';
import '../bloc/transfer_state.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountController
      ..removeListener(_onAmountChanged)
      ..dispose();
    _identifierController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    setState(() {});
  }

  String? _validateIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email atau No. HP penerima tidak boleh kosong';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nominal tidak boleh kosong';
    }
    final amount = int.tryParse(value);
    if (amount == null) {
      return 'Nominal harus berupa angka';
    }
    if (amount < 1000) {
      return 'Minimal transfer adalah Rp 1.000';
    }
    if (amount > 5000000) {
      return 'Maksimal transfer adalah Rp 5.000.000';
    }
    return null;
  }

  void _submitTransfer() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<TransferBloc>().add(
            TransferSubmitted(
              identifier: _identifierController.text.trim(),
              amount: int.parse(_amountController.text),
              note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountVal = int.tryParse(_amountController.text) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transfer Saldo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<TransferBloc, TransferState>(
        listener: (context, state) {
          if (state is TransferSuccess) {
            ErrorSnackbar.showSuccess(context, state.result.transaction.note ?? 'Transfer berhasil!');
            Navigator.of(context).pop(true);
          }
          if (state is TransferFailure && state.errors == null) {
            ErrorSnackbar.show(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is TransferLoading;
          final validationErrors = state is TransferFailure ? state.errors : null;
          final apiIdentifierError = validationErrors?['identifier']?.first;
          final apiAmountError = validationErrors?['amount']?.first;

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Instruction Card
                  Card(
                    elevation: 0,
                    color: theme.primaryColor.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: theme.primaryColor.withOpacity(0.1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: theme.primaryColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Kirim saldo secara instan dengan memasukkan email atau nomor HP tujuan. Batas nominal kirim adalah Rp 1.000 s/d Rp 5.000.000.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.primaryColor.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Recipient Email/Phone field
                  Text(
                    'Penerima',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _identifierController,
                    label: 'Email atau No. HP tujuan',
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isLoading,
                    prefixIcon: const Icon(Icons.person_outline),
                    errorText: apiIdentifierError,
                    validator: _validateIdentifier,
                  ),
                  const SizedBox(height: 24),

                  // Amount Input field
                  Text(
                    'Nominal Transfer',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _amountController,
                    label: 'Nominal',
                    keyboardType: TextInputType.number,
                    enabled: !isLoading,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Rp',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    errorText: apiAmountError,
                    validator: _validateAmount,
                  ),
                  const SizedBox(height: 8),

                  // Real-time currency format helper text
                  if (amountVal > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        _currencyFormat.format(amountVal),
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Notes / Deskripsi (Optional)
                  Text(
                    'Catatan (Opsional)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _noteController,
                    label: 'Tulis pesan atau catatan transfer...',
                    maxLines: 3,
                    maxLength: 255,
                    enabled: !isLoading,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.note_alt_outlined),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  AppButton(
                    label: 'Kirim Transfer',
                    isLoading: isLoading,
                    onPressed: _submitTransfer,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
