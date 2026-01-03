import 'package:flutter/material.dart';

class Doctor {
  final String name;
  final String specialty;
  final String rating;
  final String experience;
  final String price;
  final String imageUrl;

  Doctor({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.experience,
    required this.price,
    required this.imageUrl,
  });
}

class BookingMock {
  static List<Doctor> doctors = [
    Doctor(
      name: "Dr. Sarah Chen",
      specialty: "Cosmetic Dermatologist",
      rating: "4.9",
      experience: "12 years",
      price: "\$150",
      imageUrl: "https://i.pravatar.cc/150?u=sarah",
    ),
    Doctor(
      name: "Dr. Michael Ross",
      specialty: "Clinical Dermatologist",
      rating: "4.8",
      experience: "15 years",
      price: "\$120",
      imageUrl: "https://i.pravatar.cc/150?u=michael",
    ),
    Doctor(
      name: "Dr. Elena Rodriguez",
      specialty: "Pediatric Dermatologist",
      rating: "4.7",
      experience: "8 years",
      price: "\$100",
      imageUrl: "https://i.pravatar.cc/150?u=elena",
    ),
  ];
}
