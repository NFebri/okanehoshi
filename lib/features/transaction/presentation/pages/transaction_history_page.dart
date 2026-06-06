// withOpacity is deprecated in newer Flutter versions but withValues is not supported in the project's target SDK range.
// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:okanehoshi/core/widgets/transaction_card.dart';
import 'package:okanehoshi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:okanehoshi/features/auth/presentation/bloc/auth_state.dart';
import 'package:okanehoshi/features/dashboard/domain/entities/transaction.dart';
import '../bloc/transaction_history_bloc.dart';
import '../bloc/transaction_history_event.dart';
import '../bloc/transaction_history_state.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final _scrollController = ScrollController();

  String? _selectedType; // null = Semua, 'topup', 'transfer'

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<TransactionHistoryBloc>().add(const LoadMoreTransactionHistory());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _selectType(String? type) {
    if (_selectedType == type) return;
    setState(() {
      _selectedType = type;
    });
    context.read<TransactionHistoryBloc>().add(
          FetchTransactionHistory(type: type),
        );
  }

  Future<void> _onRefresh() async {
    context.read<TransactionHistoryBloc>().add(
          FetchTransactionHistory(type: _selectedType, isRefresh: true),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      return const Scaffold(
        body: Center(
          child: Text('Harap login terlebih dahulu.'),
        ),
      );
    }
    final currentUser = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Filter Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip(context, label: 'Semua', type: null),
                const SizedBox(width: 8),
                _buildFilterChip(context, label: 'Top Up', type: 'topup'),
                const SizedBox(width: 8),
                _buildFilterChip(context, label: 'Transfer', type: 'transfer'),
              ],
            ),
          ),

          // Main List Content
          Expanded(
            child: BlocBuilder<TransactionHistoryBloc, TransactionHistoryState>(
              builder: (context, state) {
                if (state is TransactionHistoryInitial || state is TransactionHistoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TransactionHistoryFailure) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<TransactionHistoryBloc>().add(
                                    FetchTransactionHistory(type: _selectedType),
                                  );
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is TransactionHistorySuccess) {
                  final transactions = state.transactions;

                  if (transactions.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.swap_horizontal_circle_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada transaksi saat ini',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Semua riwayat pengiriman dan pengisian saldo akan muncul di sini.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: transactions.length + (state.hasReachedMax ? 0 : 1),
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        if (index >= transactions.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        }

                        final Transaction tx = transactions[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: TransactionCard(
                            transaction: tx,
                            currentUserId: currentUser.id,
                          ),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, {required String label, required String? type}) {
    final theme = Theme.of(context);
    final isSelected = _selectedType == type;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _selectType(type),
      selectedColor: theme.primaryColor.withOpacity(0.15),
      labelStyle: TextStyle(
        color: isSelected ? theme.primaryColor : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
