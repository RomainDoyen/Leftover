import 'package:equatable/equatable.dart';

class ShoppingItem extends Equatable {
  final String id;
  final String name;
  final String category;
  final bool checked;
  final String? recipeId;
  final String? recipeName;

  const ShoppingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.checked,
    this.recipeId,
    this.recipeName,
  });

  ShoppingItem copyWith({bool? checked}) => ShoppingItem(
    id: id,
    name: name,
    category: category,
    checked: checked ?? this.checked,
    recipeId: recipeId,
    recipeName: recipeName,
  );

  @override
  List<Object?> get props => [id, name, checked];
}
