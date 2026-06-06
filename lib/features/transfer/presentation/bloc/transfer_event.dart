abstract class TransferEvent {
  const TransferEvent();
}

class TransferSubmitted extends TransferEvent {
  final String identifier;
  final int amount;
  final String? note;

  const TransferSubmitted({
    required this.identifier,
    required this.amount,
    this.note,
  });
}
