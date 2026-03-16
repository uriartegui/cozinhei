class RecipeCategory {
  final String emoji;
  final String name;
  final List<String> subcategories;

  const RecipeCategory({
    required this.emoji,
    required this.name,
    this.subcategories = const [],
  });
}

const List<RecipeCategory> allCategories = [
  RecipeCategory(emoji: "🍳", name: "Café da Manhã", subcategories: ["Ovos", "Panquecas", "Tapioca", "Vitaminas", "Pão", "Frutas"]),
  RecipeCategory(emoji: "🍝", name: "Massas", subcategories: ["Macarrão", "Lasanha", "Nhoque", "Espaguete", "Ravioli", "Penne"]),
  RecipeCategory(emoji: "🥩", name: "Carnes", subcategories: ["Bife", "Carne Moída", "Costela", "Churrasco", "Hambúrguer", "Assado"]),
  RecipeCategory(emoji: "🍗", name: "Frango", subcategories: ["Grelhado", "Assado", "Refogado", "Ensopado", "Frito", "Recheado"]),
  RecipeCategory(emoji: "🐟", name: "Peixes", subcategories: ["Salmão", "Atum", "Tilápia", "Bacalhau", "Camarão", "Lula"]),
  RecipeCategory(emoji: "🥗", name: "Saladas", subcategories: ["Simples", "Com Proteína", "Bowl", "Caesar", "Tropical"]),
  RecipeCategory(emoji: "🥪", name: "Lanches", subcategories: ["Sanduíche", "Hambúrguer", "Wrap", "Torrada", "Hot Dog"]),
  RecipeCategory(emoji: "🍲", name: "Sopas", subcategories: ["Caldo", "Creme", "Sopa Fria", "Feijão", "Lentilha"]),
  RecipeCategory(emoji: "🍚", name: "Arroz", subcategories: ["Arroz Branco", "Risoto", "Arroz Colorido", "Carreteiro"]),
  RecipeCategory(emoji: "🍕", name: "Pizzas", subcategories: ["Tradicional", "Integral", "Especial", "Pizza Doce"]),
  RecipeCategory(emoji: "🍰", name: "Sobremesas", subcategories: ["Bolo", "Torta", "Mousse", "Sorvete", "Brigadeiro", "Brownie"]),
  RecipeCategory(emoji: "🌎", name: "Cozinhas do Mundo", subcategories: ["Brasileira", "Italiana", "Japonesa", "Mexicana", "Chinesa", "Indiana"]),
  RecipeCategory(emoji: "🥦", name: "Vegetariano", subcategories: ["Proteína Vegetal", "Legumes", "Tofu", "Vegano"]),
  RecipeCategory(emoji: "🎲", name: "Aleatório", subcategories: []),
];

const List<String> allTags = [
  "⚡ Rápido",
  "🔥 Air Fryer",
  "🥑 Saudável",
  "🌱 Vegano",
  "💪 Proteico",
  "💰 Econômico",
  "🍽️ Fácil",
  "👨‍🍳 Gourmet",
];
