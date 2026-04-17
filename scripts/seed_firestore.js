// scripts/seed_firestore.js
//
// Usage:
//   1. Download your Firebase service account key from:
//      Firebase Console > Project Settings > Service Accounts > Generate new private key
//   2. Save it as scripts/serviceAccountKey.json
//   3. Run: GOOGLE_APPLICATION_CREDENTIALS=./serviceAccountKey.json npm run seed
//
// This script seeds the Firestore `recipes` collection.

const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

const db = admin.firestore();

const recipes = [
  {
    name: 'Quiche Lorraine',
    imageUrl: 'https://placehold.co/400x300/FF784E/FFFFFF?text=Quiche+Lorraine',
    cookTimeMinutes: 45,
    servings: { min: 2, max: 4 },
    difficulty: 'intermediate',
    tags: ['french', 'savory', 'oven'],
    ingredients: [
      { name: 'oignon', amount: '1 demi', category: 'produce', aliases: ['onion'] },
      { name: 'lardons', amount: '150g', category: 'proteins', aliases: ['bacon', 'pancetta'] },
      { name: 'pâte à tarte', amount: '1', category: 'pastry', aliases: ['pie crust', 'shortcrust'] },
      { name: 'crème fraîche', amount: '200ml', category: 'dairy', aliases: ['cream', 'heavy cream'] },
      { name: 'fromage râpé', amount: '100g', category: 'dairy', aliases: ['cheese', 'gruyere', 'emmental', 'fromage frais', 'cream cheese'] },
    ],
    steps: [
      {
        order: 1,
        title: 'Préchauffage & fond de tarte',
        description: 'Préchauffez le four à 200°C. Étalez la pâte dans un moule. Faites cuire à blanc 8 min.',
        durationMinutes: 10,
      },
      {
        order: 2,
        title: 'La préparation',
        description: "Battez 4 œufs avec la crème. Incorporez lardons et oignon émincé. Assaisonnez avec muscade.",
        durationMinutes: 10,
      },
      {
        order: 3,
        title: 'Cuisson',
        description: "Versez dans le fond de tarte. Parsemez de fromage. Enfournez 15-18 min jusqu'à dorure.",
        durationMinutes: 18,
      },
    ],
  },
  {
    name: 'Kitchen Sink Stir-fry',
    imageUrl: null,
    cookTimeMinutes: 20,
    servings: { min: 2, max: 3 },
    difficulty: 'easy',
    tags: ['asian', 'quick', 'wok'],
    ingredients: [
      { name: 'sauce soja', amount: '3 cuil.', category: 'pantry', aliases: ['soy sauce', 'shoyu'] },
      { name: 'oignon', amount: '1', category: 'produce', aliases: ['onion'] },
      { name: 'ail', amount: '2 gousses', category: 'produce', aliases: ['garlic'] },
      { name: 'huile de sésame', amount: '1 cuil.', category: 'pantry', aliases: ['sesame oil'] },
    ],
    steps: [
      {
        order: 1,
        title: 'Préparation',
        description: 'Émincer oignon et ail. Préparer la sauce soja avec une cuillère de sucre.',
        durationMinutes: 5,
      },
      {
        order: 2,
        title: 'Cuisson wok',
        description: "Chauffer l'huile à feu vif. Faire revenir oignon 2 min, ajouter ail, puis sauce soja.",
        durationMinutes: 10,
      },
      {
        order: 3,
        title: 'Service',
        description: 'Servir immédiatement sur riz blanc ou nouilles.',
        durationMinutes: 2,
      },
    ],
  },
  {
    name: 'Umami Leftover Melt',
    imageUrl: null,
    cookTimeMinutes: 15,
    servings: { min: 1, max: 2 },
    difficulty: 'easy',
    tags: ['comfort', 'quick', 'toast'],
    ingredients: [
      { name: 'fromage frais', amount: '100g', category: 'dairy', aliases: ['cream cheese', 'philadelphia', 'fromage', 'cheese'] },
      { name: 'sauce soja', amount: '2 cuil.', category: 'pantry', aliases: ['soy sauce'] },
      { name: 'pain', amount: '2 tranches', category: 'pantry', aliases: ['bread', 'toast'] },
    ],
    steps: [
      {
        order: 1,
        title: 'Mélange',
        description: 'Mélanger fromage frais et sauce soja. Tartiner généreusement sur le pain.',
        durationMinutes: 3,
      },
      {
        order: 2,
        title: 'Gratinage',
        description: "Passer au grill 5-7 min jusqu'à dorure. Servir chaud.",
        durationMinutes: 7,
      },
    ],
  },
  {
    name: 'Omelette Basque',
    imageUrl: null,
    cookTimeMinutes: 15,
    servings: { min: 2, max: 2 },
    difficulty: 'easy',
    tags: ['eggs', 'quick', 'pan'],
    ingredients: [
      { name: 'oeufs', amount: '4', category: 'proteins', aliases: ['eggs', 'oeuf'] },
      { name: 'poivron', amount: '1', category: 'produce', aliases: ['bell pepper', 'capsicum'] },
      { name: 'oignon', amount: '1', category: 'produce', aliases: ['onion'] },
      { name: 'jambon', amount: '100g', category: 'proteins', aliases: ['ham', 'jambon blanc'] },
    ],
    steps: [
      {
        order: 1,
        title: 'Sauté de légumes',
        description: 'Faire revenir oignon et poivron émincés dans un filet d\'huile, 5 min à feu moyen.',
        durationMinutes: 6,
      },
      {
        order: 2,
        title: 'Omelette',
        description: 'Battre les œufs avec sel et poivre. Verser sur les légumes. Ajouter le jambon. Cuire 4 min à feu doux en couvrant.',
        durationMinutes: 5,
      },
    ],
  },
  {
    name: 'Pasta Aglio e Olio',
    imageUrl: null,
    cookTimeMinutes: 20,
    servings: { min: 2, max: 4 },
    difficulty: 'easy',
    tags: ['italian', 'pasta', 'quick'],
    ingredients: [
      { name: 'pâtes', amount: '300g', category: 'pantry', aliases: ['pasta', 'spaghetti', 'tagliatelle', 'linguine'] },
      { name: 'ail', amount: '4 gousses', category: 'produce', aliases: ['garlic'] },
      { name: 'huile d\'olive', amount: '4 cuil.', category: 'pantry', aliases: ['olive oil'] },
      { name: 'piment', amount: '1 pincée', category: 'pantry', aliases: ['chili', 'red pepper flakes', 'piment rouge'] },
    ],
    steps: [
      {
        order: 1,
        title: 'Cuisson des pâtes',
        description: 'Cuire les pâtes al dente dans de l\'eau salée. Réserver une tasse d\'eau de cuisson.',
        durationMinutes: 10,
      },
      {
        order: 2,
        title: 'Infusion ail-huile',
        description: 'Dans une poêle, chauffer l\'huile et faire revenir l\'ail émincé avec le piment à feu doux, 3 min.',
        durationMinutes: 5,
      },
      {
        order: 3,
        title: 'Assemblage',
        description: 'Incorporer les pâtes dans la poêle avec un peu d\'eau de cuisson. Mélanger vigoureusement.',
        durationMinutes: 3,
      },
    ],
  },
];

async function seed() {
  console.log(`Seeding ${recipes.length} recipes to Firestore...`);
  const batch = db.batch();

  for (const recipe of recipes) {
    const ref = db.collection('recipes').doc();
    batch.set(ref, {
      ...recipe,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`  → ${recipe.name}`);
  }

  await batch.commit();
  console.log(`✅ Seeded ${recipes.length} recipes successfully.`);
  process.exit(0);
}

seed().catch((err) => {
  console.error('❌ Seeding failed:', err.message);
  process.exit(1);
});
