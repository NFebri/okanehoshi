// withOpacity is deprecated in newer Flutter versions but withValues is not supported in the project's target SDK range.
// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:okanehoshi/core/widgets/app_button.dart';
import 'package:okanehoshi/core/widgets/app_text_field.dart';
import 'package:okanehoshi/core/widgets/error_snackbar.dart';
import '../bloc/top_up_bloc.dart';
import '../bloc/top_up_event.dart';
import '../bloc/top_up_state.dart';

class TopupPage extends StatefulWidget {
  const TopupPage({super.key});

  @override
  State<TopupPage> createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final List<int> _presetAmounts = [50000, 100000, 200000, 500000];

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
    super.dispose();
  }

  void _onAmountChanged() {
    setState(() {});
  }

  void _selectPreset(int amount) {
    _amountController.text = amount.toString();
    _amountController.selection = TextSelection.fromPosition(
      TextPosition(offset: _amountController.text.length),
    );
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nominal tidak boleh kosong';
    }
    final amount = int.tryParse(value);
    if (amount == null) {
      return 'Nominal harus berupa angka';
    }
    if (amount < 10000) {
      return 'Minimal top up adalah Rp 10.000';
    }
    if (amount > 10000000) {
      return 'Maksimal top up adalah Rp 10.000.000';
    }
    return null;
  }

  void _submitTopUp() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = int.parse(_amountController.text);
      context.read<TopUpBloc>().add(TopUpSubmitted(amount));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountVal = int.tryParse(_amountController.text) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Top Up Saldo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<TopUpBloc, TopUpState>(
        listener: (context, state) {
          if (state is TopUpSuccess) {
            ErrorSnackbar.showSuccess(context, state.result.transaction.note ?? 'Top up berhasil!');
            Navigator.of(context).pop(true);
          }
          if (state is TopUpFailure && state.errors == null) {
            ErrorSnackbar.show(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is TopUpLoading;
          final validationErrors = state is TopUpFailure ? state.errors : null;
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
                              'Silakan masukkan nominal pengisian saldo. Minimal Rp 10.000 dan maksimal Rp 10.000.000.',
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

                  // Amount Input field
                  Text(
                    'Nominal Top Up',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _amountController,
                    label: 'Nominal',
                    hint: '0',
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

                  // Preset Amount Chips
                  Text(
                    'Pilih Nominal Cepat',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _presetAmounts.map((amount) {
                      final isSelected = amountVal == amount;
                      return ChoiceChip(
                        label: Text(
                          _currencyFormat.format(amount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : theme.primaryColor,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: theme.primaryColor,
                        backgroundColor: theme.primaryColor.withOpacity(0.05),
                        disabledColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : theme.primaryColor.withOpacity(0.2),
                          ),
                        ),
                        onSelected: isLoading
                            ? null
                            : (selected) {
                                if (selected) {
                                  _selectPreset(amount);
                                }
                              },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 48),

                  // Submit Button
                  AppButton(
                    label: 'Top Up Sekarang',
                    isLoading: isLoading,
                    onPressed: _submitTopUp,
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
