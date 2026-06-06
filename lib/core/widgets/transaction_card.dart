import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:okanehoshi/features/dashboard/domain/entities/transaction.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final int currentUserId;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final isIncoming = transaction.type == 'topup' ||
        (transaction.type == 'transfer' && transaction.receiver?.id == currentUserId);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isIncoming ? Colors.green[600] : Colors.red[600];
    final iconBg = isIncoming
        ? (isDark ? Colors.green[900]?.withAlpha(50) : Colors.green[50])
        : (isDark ? Colors.red[900]?.withAlpha(50) : Colors.red[50]);

    final amountSign = isIncoming ? '+' : '-';
    final amountColor = isIncoming ? Colors.green[700] : Colors.red[700];

    String title = '';
    if (transaction.type == 'topup') {
      title = 'Top Up Saldo';
    } else if (transaction.type == 'transfer') {
      if (transaction.sender?.id == currentUserId) {
        title = 'Transfer ke ${transaction.receiver?.name ?? "Penerima"}';
      } else {
        title = 'Menerima dari ${transaction.sender?.name ?? "Pengirim"}';
      }
    }

    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(transaction.createdAt);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconBg,
          shape: BoxShape.circle,
        ),
        child: Icon(
          transaction.type == 'topup'
              ? Icons.account_balance_wallet_outlined
              : (isIncoming ? Icons.call_received_outlined : Icons.call_made_outlined),
          color: iconColor,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formattedDate,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          if (transaction.note != null && transaction.note!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Catatan: ${transaction.note}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
      trailing: Text(
        '$amountSign ${currencyFormat.format(transaction.amount)}',
        style: TextStyle(
          color: amountColor,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}
