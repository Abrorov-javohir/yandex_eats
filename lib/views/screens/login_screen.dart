import 'package:dars75_yandexmap_restaurant/services/auth_firebase.dart';
import 'package:dars75_yandexmap_restaurant/utils/helpers.dart';
import 'package:dars75_yandexmap_restaurant/views/screens/restaurants_screen.dart';
import 'package:dars75_yandexmap_restaurant/views/screens/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firebaseAuthService = FirebaseAuthService();

  void submit() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      try {
        await firebaseAuthService.login(
          emailController.text,
          passwordController.text,
        );
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return const RestaurantsScreen();
        }));
      } on FirebaseAuthException catch (error) {
        Helpers.showErrorDialog(context, error.message ?? "Xatolik");
      } catch (e) {
        Helpers.showErrorDialog(context, "Tizimda xatolik");
      }
    } else {
      Helpers.showErrorDialog(context, "Iltimos, email va parolni kiriting");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                height: 300,
                width: 300,
                "https://marketplace.canva.com/EAFpeiTrl4c/1/0/1600w/canva-abstract-chef-cooking-restaurant-free-logo-9Gfim1S8fHg.jpg",
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Email",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Parol",
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("LOGIN"),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                    return const RegisterScreen();
                  }));
                },
                child: const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
