import 'package:equatable/equatable.dart';
import 'recipe_match.dart';

class HistoryEntry extends Equatable {
  final String id;
  final RecipeMatch match;
  final List<String> userIngredients;
  final String source; // 'match' | 'ai'
  final DateTime createdAt;

  const HistoryEntry({
    required this.id,
    required this.match,
    required this.userIngredients,
    required this.source,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id];
}
