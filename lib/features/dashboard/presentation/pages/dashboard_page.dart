// withOpacity is deprecated in newer Flutter versions but withValues is not supported in the project's target SDK range.
// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:okanehoshi/core/widgets/transaction_card.dart';
import 'package:okanehoshi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:okanehoshi/features/auth/presentation/bloc/auth_event.dart';
import 'package:okanehoshi/features/auth/presentation/bloc/auth_state.dart';
import 'package:okanehoshi/features/dashboard/domain/entities/transaction.dart';
import 'package:okanehoshi/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:okanehoshi/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:okanehoshi/features/dashboard/presentation/bloc/dashboard_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Get auth state to retrieve logged in user info
    final authState = context.watch<AuthBloc>().state;
    if (authState is! Authenticated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final currentUser = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OkaneHoshi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<DashboardBloc>().add(const FetchDashboardData());
          // Wait until state is not loading anymore
          await context
              .read<DashboardBloc>()
              .stream
              .firstWhere((state) => state is! DashboardLoading);
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardInitial || state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DashboardError) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          context.read<DashboardBloc>().add(const FetchDashboardData());
                        },
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is DashboardLoaded) {
              final data = state.dashboardData;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome & Profile Section
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                          child: Text(
                            currentUser.name.isNotEmpty ? currentUser.name[0].toUpperCase() : 'U',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selamat datang,',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                currentUser.name,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Premium Balance Card with Gradient & Glassmorphic border
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.85)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Total Saldo Anda',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: data.balance.toDouble()),
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Text(
                                  currencyFormat.format(value.toInt()),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions Section with Tactile Scale Animations
                    Row(
                      children: [
                        Expanded(
                          child: QuickActionButton(
                            label: 'Top Up',
                            icon: Icons.add_circle_outline,
                            isPrimary: true,
                            onPressed: () async {
                              final result = await context.push<bool>('/topup');
                              if ((result ?? false) && context.mounted) {
                                context.read<DashboardBloc>().add(const FetchDashboardData());
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: QuickActionButton(
                            label: 'Transfer',
                            icon: Icons.send_outlined,
                            isPrimary: false,
                            onPressed: () async {
                              final result = await context.push<bool>('/transfer');
                              if ((result ?? false) && context.mounted) {
                                context.read<DashboardBloc>().add(const FetchDashboardData());
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Recent Transactions Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transaksi Terakhir',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (data.recentTransactions.isNotEmpty)
                          TextButton(
                            onPressed: () => context.push('/transactions'),
                            child: const Text('Lihat Semua'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Recent Transactions List
                    if (data.recentTransactions.isEmpty)
                      Card(
                        elevation: 0,
                        color: theme.cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                          child: Column(
                            children: [
                              Icon(
                                  Icons.swap_horizontal_circle_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                              const SizedBox(height: 12),
                              Text(
                                'Belum ada transaksi saat ini',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.recentTransactions.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final Transaction tx = data.recentTransactions[index];
                          return TransactionCard(
                            transaction: tx,
                            currentUserId: currentUser.id,
                          );
                        },
                      ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class QuickActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  const QuickActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  State<QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<QuickActionButton> with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 100),
       lowerBound: 0,
       upperBound: 0.05,
     )..addListener(() {
         setState(() {});
       });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: Transform.scale(
        scale: _scale,
        child: widget.isPrimary
            ? ElevatedButton.icon(
                onPressed: widget.onPressed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(widget.icon),
                label: Text(widget.label),
              )
            : OutlinedButton.icon(
                onPressed: widget.onPressed,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(widget.icon),
                label: Text(widget.label),
              ),
      ),
    );
  }
}
