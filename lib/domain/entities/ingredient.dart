import 'package:equatable/equatable.dart';

class Ingredient extends Equatable {
  final String name;
  final String amount;
  final String category; // proteins | dairy | produce | pantry | pastry
  final List<String> aliases;

  const Ingredient({
    required this.name,
    required this.amount,
    required this.category,
    this.aliases = const [],
  });

  @override
  List<Object?> get props => [name, amount, category, aliases];
}
