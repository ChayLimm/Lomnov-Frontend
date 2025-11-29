String formatCurrency(double value) {
  final s = value.toStringAsFixed(2);
  final parts = s.split('.');
  final intPart = parts.first;
  final buf = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    buf.write(intPart[i]);
    final posFromEnd = intPart.length - i - 1;
    if (posFromEnd > 0 && posFromEnd % 3 == 0) buf.write(',');
  }
  final formattedInt = buf.toString();
  return '\$ $formattedInt.${parts[1]}';
}

String formatMonth(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[dt.month - 1]} ${dt.year}';
}
