abstract class TopUpEvent {
  const TopUpEvent();
}

class TopUpSubmitted extends TopUpEvent {
  final int amount;

  const TopUpSubmitted(this.amount);
}
