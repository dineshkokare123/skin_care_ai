import 'package:skin_care_ai/core/env.dart';

// This file simulates a Backend/Admin Panel configuration.
// In a real app, this would be fetched from Firestore/Supabase.

class AdminConfig {
  // TODO: Replace with your actual Gemini API Key from Google AI Studio
  // Using the known working key directly for now to ensure all services work
  static final String geminiApiKey = Env.geminiApiKey;

  static const String aiSystemPrompt = """
You are a top-tier dermatologist and skincare expert. 
Your goal is to provide personalized, gentle, and science-backed skincare advice.
Always consider the user's skin type (Oily, Dry, Combination, Sensitive) and their specific concerns (Acne, Aging, Pigmentation).
Recommend routines that are sustainable. 
If asked about medical conditions, advise visiting a doctor.
  """;

  static final List<QuizQuestion> quizQuestions = [
    QuizQuestion(
      id: 'q1',
      question: "How does your skin feel 2 hours after washing?",
      options: [
        "Tight and parchey",
        "Oily all over",
        "Oily T-zone, dry cheeks",
        "Just fine/Normal"
      ],
    ),
    QuizQuestion(
      id: 'q2',
      question: "What is your primary skin concern?",
      options: [
        "Acne & Breakouts",
        "Fine Lines & Wrinkles",
        "Dark Spots & Pigmentation",
        "Redness & Sensitivity"
      ],
    ),
    QuizQuestion(
      id: 'q3',
      question: "How sensitive is your skin to new products?",
      options: [
        "Very reactive (redness/stinging)",
        "Occasionally reactive",
        "Resilient/Non-sensitive"
      ],
    ),
  ];

  static final List<BlogPost> blogPosts = [
    BlogPost(
      title: "The Truth About Retinol",
      summary: "Everything you need to know about the anti-aging gold standard.",
      imageUrl: "https://images.unsplash.com/photo-1576426863848-c21f5fc67255",
      content: "Retinol is a derivative of Vitamin A...",
    ),
    BlogPost(
      title: "Summer Skincare Switch",
      summary: "Why you need to ditch heavy creams when the heat hits.",
      imageUrl: "https://images.unsplash.com/photo-1598440947619-2c35fc9dd908",
      content: "As humidity rises, your skin produces more sebum...",
    ),
  ];

  static final List<Product> products = [
    Product(
      name: "Gentle Hydrating Cleanser",
      description: "A pH-balanced cleanser for all skin types.",
      affiliateUrl: "https://example.com/cleanser",
      imageUrl: "https://via.placeholder.com/150",
      category: "Cleanser",
    ),
    Product(
      name: "Daily SPF 50",
      description: "Invisible protection against UVA/UVB.",
      affiliateUrl: "https://example.com/spf",
      imageUrl: "https://via.placeholder.com/150",
      category: "Sunscreen",
    ),
    Product(
      name: "Hyaluronic Acid Moisturizer",
      description: "Deep hydration for plumper skin.",
      affiliateUrl: "https://example.com/moisturizer",
      imageUrl: "https://via.placeholder.com/150",
      category: "Moisturizer",
    ),
    Product(
      name: "Vitamin C Brightening Serum",
      description: "Fades dark spots and boosts glow.",
      affiliateUrl: "https://example.com/vitaminc",
      imageUrl: "https://via.placeholder.com/150",
      category: "Vitamin C Serum",
    ),
    Product(
      name: "Night Repair Retinol",
      description: "Anti-aging powerhouse for evening use.",
      affiliateUrl: "https://example.com/retinol",
      imageUrl: "https://via.placeholder.com/150",
      category: "Retinol/Treatment",
    ),
    Product(
      name: "Silk Oil Cleanser",
      description: "Melts away makeup and sunscreen.",
      affiliateUrl: "https://example.com/oilcleanser",
      imageUrl: "https://via.placeholder.com/150",
      category: "Double Cleanse",
    ),
    Product(
      name: "Liquid Glass Serum",
      description: "Achieve the ultimate glass skin look with this hydrating, high-shine serum.",
      affiliateUrl: "https://example.com/liquidglass",
      imageUrl: "https://via.placeholder.com/150",
      category: "Serum",
      price: 45.00,
    ),
  ];
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;

  QuizQuestion({required this.id, required this.question, required this.options});
}

class BlogPost {
  final String title;
  final String summary;
  final String imageUrl;
  final String content;

  BlogPost({required this.title, required this.summary, required this.imageUrl, required this.content});
}

class Product {
  final String name;
  final String description;
  final String affiliateUrl;
  final String imageUrl;
  final String category;
  final double price;

  Product({
    required this.name, 
    required this.description, 
    required this.affiliateUrl, 
    required this.imageUrl, 
    required this.category,
    this.price = 29.99,
  });
}

