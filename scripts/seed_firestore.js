// scripts/seed_firestore.js
//
// Usage:
//   1. Download your Firebase service account key from:
//      Firebase Console > Project Settings > Service Accounts > Generate new private key
//   2. Save it as  scripts/serviceAccountKey.json  OR  <project-root>/serviceAccountKey.json
//   3. Run from the scripts/ folder:  node seed_firestore.js
//
// This script seeds the Firestore `recipes` collection.

const admin = require('firebase-admin');
const path  = require('path');
const fs    = require('fs');

// Look for the service account key next to this script, then one level up (project root).
const candidates = [
  path.join(__dirname, 'serviceAccountKey.json'),
  path.join(__dirname, '..', 'serviceAccountKey.json'),
];
const keyPath = candidates.find(fs.existsSync);
if (!keyPath) {
  console.error(
    '❌  serviceAccountKey.json not found.\n' +
    '    Place it in scripts/ or at the project root, then re-run.'
  );
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(require(keyPath)),
});

const db = admin.firestore();

const recipes = [
  {
    name: 'Quiche Lorraine',
    imageUrl: 'https://placehold.co/400x300/FF784E/FFFFFF?text=Quiche+Lorraine',
    cookTimeMinutes: 45,
    servings: { min: 2, max: 4 },
    difficulty: 'intermédiaire',
    tags: ['french', 'savory', 'oven'],
    ingredients: [
      { name: 'oignon', amount: '1 demi', category: 'produce', aliases: ['onion'] },
      { name: 'lardons', amount: '150g', category: 'proteins', aliases: ['bacon', 'pancetta'] },
      { name: 'pâte à tarte', amount: '1', category: 'pastry', aliases: ['pie crust', 'shortcrust'] },
      { name: 'crème fraîche', amount: '200ml', category: 'dairy', aliases: ['cream', 'heavy cream'] },
      { name: 'fromage râpé', amount: '100g', category: 'dairy', aliases: ['cheese', 'gruyere', 'emmental', 'fromage frais', 'cream cheese'] },
    ],
    steps: [
      { order: 1, title: 'Préchauffage & fond de tarte', description: 'Préchauffez le four à 200°C. Étalez la pâte dans un moule. Faites cuire à blanc 8 min.', durationMinutes: 10 },
      { order: 2, title: 'La préparation', description: 'Battez 4 œufs avec la crème. Incorporez lardons et oignon émincé. Assaisonnez avec muscade.', durationMinutes: 10 },
      { order: 3, title: 'Cuisson', description: "Versez dans le fond de tarte. Parsemez de fromage. Enfournez 15-18 min jusqu'à dorure.", durationMinutes: 18 },
    ],
  },
  {
    name: 'Poêlée Frigo Express',
    imageUrl: null,
    cookTimeMinutes: 20,
    servings: { min: 2, max: 3 },
    difficulty: 'facile',
    tags: ['asian', 'quick', 'wok'],
    ingredients: [
      { name: 'sauce soja', amount: '3 cuil.', category: 'pantry', aliases: ['soy sauce', 'shoyu'] },
      { name: 'oignon', amount: '1', category: 'produce', aliases: ['onion'] },
      { name: 'ail', amount: '2 gousses', category: 'produce', aliases: ['garlic'] },
      { name: 'huile de sésame', amount: '1 cuil.', category: 'pantry', aliases: ['sesame oil'] },
    ],
    steps: [
      { order: 1, title: 'Préparation', description: 'Émincer oignon et ail. Préparer la sauce soja avec une cuillère de sucre.', durationMinutes: 5 },
      { order: 2, title: 'Cuisson wok', description: "Chauffer l'huile à feu vif. Faire revenir oignon 2 min, ajouter ail, puis sauce soja.", durationMinutes: 10 },
      { order: 3, title: 'Service', description: 'Servir immédiatement sur riz blanc ou nouilles.', durationMinutes: 2 },
    ],
  },
  {
    name: 'Toast Umami Fondu',
    imageUrl: null,
    cookTimeMinutes: 15,
    servings: { min: 1, max: 2 },
    difficulty: 'facile',
    tags: ['comfort', 'quick', 'toast'],
    ingredients: [
      { name: 'fromage frais', amount: '100g', category: 'dairy', aliases: ['cream cheese', 'philadelphia', 'fromage', 'cheese'] },
      { name: 'sauce soja', amount: '2 cuil.', category: 'pantry', aliases: ['soy sauce'] },
      { name: 'pain', amount: '2 tranches', category: 'pantry', aliases: ['bread', 'toast'] },
    ],
    steps: [
      { order: 1, title: 'Mélange', description: 'Mélanger fromage frais et sauce soja. Tartiner généreusement sur le pain.', durationMinutes: 3 },
      { order: 2, title: 'Gratinage', description: "Passer au grill 5-7 min jusqu'à dorure. Servir chaud.", durationMinutes: 7 },
    ],
  },
  {
    name: 'Omelette aux Herbes',
    imageUrl: null,
    cookTimeMinutes: 10,
    servings: { min: 1, max: 2 },
    difficulty: 'facile',
    tags: ['french', 'quick', 'breakfast'],
    ingredients: [
      { name: 'œufs', amount: '3', category: 'proteins', aliases: ['oeufs', 'oeuf', 'egg', 'eggs'] },
      { name: 'beurre', amount: '20g', category: 'dairy', aliases: ['butter'] },
      { name: 'ciboulette', amount: '1 bouquet', category: 'produce', aliases: ['chives', 'herbes', 'persil', 'herbs'] },
    ],
    steps: [
      { order: 1, title: 'Battre les œufs', description: "Casser les œufs dans un bol, saler, poivrer et fouetter vigoureusement.", durationMinutes: 2 },
      { order: 2, title: 'Cuisson', description: "Faire fondre le beurre à feu moyen. Verser les œufs. Remuer en pliant jusqu'à prise.", durationMinutes: 4 },
      { order: 3, title: 'Finition', description: 'Parsemer de ciboulette ciselée. Plier et servir immédiatement.', durationMinutes: 1 },
    ],
  },
  {
    name: 'Soupe Tomate Maison',
    imageUrl: null,
    cookTimeMinutes: 25,
    servings: { min: 2, max: 4 },
    difficulty: 'facile',
    tags: ['french', 'soup', 'comfort'],
    ingredients: [
      { name: 'tomates', amount: '4', category: 'produce', aliases: ['tomate', 'tomato', 'tomatoes'] },
      { name: 'oignon', amount: '1', category: 'produce', aliases: ['onion'] },
      { name: 'ail', amount: '2 gousses', category: 'produce', aliases: ['garlic'] },
      { name: 'bouillon', amount: '500ml', category: 'pantry', aliases: ['bouillon de légumes', 'broth', 'stock'] },
    ],
    steps: [
      { order: 1, title: 'Faire revenir', description: "Faire revenir oignon et ail émincés dans un filet d'huile 3 min.", durationMinutes: 5 },
      { order: 2, title: 'Mijoter', description: 'Ajouter les tomates en morceaux et le bouillon. Cuire à feu moyen 15 min.', durationMinutes: 15 },
      { order: 3, title: 'Mixer', description: "Mixer le tout jusqu'à texture lisse. Rectifier l'assaisonnement.", durationMinutes: 3 },
    ],
  },
  {
    name: 'Pâtes Carbonara Express',
    imageUrl: null,
    cookTimeMinutes: 20,
    servings: { min: 2, max: 3 },
    difficulty: 'intermédiaire',
    tags: ['italian', 'pasta', 'quick'],
    ingredients: [
      { name: 'pâtes', amount: '200g', category: 'pantry', aliases: ['spaghetti', 'pasta', 'tagliatelles', 'linguine'] },
      { name: 'lardons', amount: '150g', category: 'proteins', aliases: ['bacon', 'pancetta', 'guanciale'] },
      { name: 'œufs', amount: '2', category: 'proteins', aliases: ['oeufs', 'oeuf', 'egg', 'eggs'] },
      { name: 'parmesan', amount: '50g', category: 'dairy', aliases: ['fromage', 'pecorino', 'cheese', 'fromage râpé'] },
    ],
    steps: [
      { order: 1, title: 'Cuire les pâtes', description: "Cuire les pâtes al dente dans de l'eau bien salée. Réserver l'eau de cuisson.", durationMinutes: 10 },
      { order: 2, title: 'Lardons', description: "Faire revenir les lardons à sec dans une poêle jusqu'à légère dorure.", durationMinutes: 5 },
      { order: 3, title: 'Mélange & service', description: "Hors du feu, mélanger œufs battus + parmesan + pâtes + lardons. Ajouter un peu d'eau de cuisson. Servir immédiatement.", durationMinutes: 3 },
    ],
  },
  {
    name: 'Riz Sauté aux Légumes',
    imageUrl: null,
    cookTimeMinutes: 15,
    servings: { min: 2, max: 3 },
    difficulty: 'facile',
    tags: ['asian', 'quick', 'rice'],
    ingredients: [
      { name: 'riz cuit', amount: '300g', category: 'pantry', aliases: ['riz', 'rice', 'riz blanc'] },
      { name: 'carottes', amount: '2', category: 'produce', aliases: ['carotte', 'carrot', 'carrots'] },
      { name: 'petits pois', amount: '100g', category: 'produce', aliases: ['peas', 'pois'] },
      { name: 'sauce soja', amount: '2 cuil.', category: 'pantry', aliases: ['soy sauce', 'shoyu'] },
      { name: 'œufs', amount: '2', category: 'proteins', aliases: ['oeufs', 'oeuf', 'egg', 'eggs'] },
    ],
    steps: [
      { order: 1, title: 'Préparer les légumes', description: 'Couper les carottes en petits dés. Égoutter les petits pois.', durationMinutes: 3 },
      { order: 2, title: 'Cuisson', description: 'Faire sauter les légumes 3 min à feu vif. Ajouter le riz froid et mélanger.', durationMinutes: 5 },
      { order: 3, title: 'Finition', description: 'Pousser le riz sur le côté, brouiller les œufs. Incorporer au riz. Arroser de sauce soja.', durationMinutes: 4 },
    ],
  },
  {
    name: 'Pasta Aglio e Olio',
    imageUrl: null,
    cookTimeMinutes: 20,
    servings: { min: 2, max: 4 },
    difficulty: 'facile',
    tags: ['italian', 'pasta', 'quick'],
    ingredients: [
      { name: 'pâtes', amount: '300g', category: 'pantry', aliases: ['pasta', 'spaghetti', 'tagliatelle', 'linguine'] },
      { name: 'ail', amount: '4 gousses', category: 'produce', aliases: ['garlic'] },
      { name: "huile d'olive", amount: '4 cuil.', category: 'pantry', aliases: ['olive oil'] },
      { name: 'piment', amount: '1 pincée', category: 'pantry', aliases: ['chili', 'red pepper flakes', 'piment rouge'] },
    ],
    steps: [
      { order: 1, title: 'Cuisson des pâtes', description: "Cuire les pâtes al dente dans de l'eau salée. Réserver une tasse d'eau de cuisson.", durationMinutes: 10 },
      { order: 2, title: 'Infusion ail-huile', description: "Dans une poêle, chauffer l'huile et faire revenir l'ail émincé avec le piment à feu doux, 3 min.", durationMinutes: 5 },
      { order: 3, title: 'Assemblage', description: "Incorporer les pâtes dans la poêle avec un peu d'eau de cuisson. Mélanger vigoureusement.", durationMinutes: 3 },
    ],
  },
];

async function seed() {
  console.log(`\n🔑  Using credentials: ${keyPath}`);
  console.log(`📦  Seeding ${recipes.length} recipes to Firestore...\n`);
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
  if (err.code === 5 || (err.message && err.message.includes('NOT_FOUND'))) {
    console.error(
      '❌  Seeding failed: Firestore database not found.\n\n' +
      '    → Go to https://console.firebase.google.com\n' +
      '    → Build > Firestore Database > Create database\n' +
      '    → Choose "Start in test mode", region europe-west1\n' +
      '    → Then re-run this script.\n'
    );
  } else {
    console.error('❌  Seeding failed:', err.message);
  }
  process.exit(1);
});
