import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  StateMachineController? controller;
  SMIBool? isChecking;
  SMIBool? isHandsUp;
  SMITrigger? trigSuccess;
  SMITrigger? trigFail;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      //Evita nudge o cámaras frontales en moviles
      body: SafeArea(
          child: Padding(
        //Eje
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'assets/animated_login_character.riv',
                  stateMachines: ["Login Machine"],
                  onInit: (artboart) {
                    controller = StateMachineController.fromArtboard(
                      artboart,
                      "Login Machine",
                    );
                    if (controller == null) return;
                    artboart.addController(controller!);
                    isChecking = controller!.findSMI('isChecking');
                    isHandsUp = controller!.findSMI('isHandsUp');
                    trigSuccess = controller!.findSMI('trigSuccess');
                    trigFail = controller!.findSMI('trigFail');
                  },
                )),
            //Espacio entre el oso y el texto email
            const SizedBox(height: 10),
            TextField(
              onChanged: (value) {
                if (isHandsUp != null) {
                  isHandsUp!.change(false);
                }
                if (isChecking == null) return;
                isChecking!.change(true);
              },
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  hintText: "Email",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    //ESQUINAS RODEADAS
                    borderRadius: BorderRadius.circular(12),
                  )),
            ),
            const SizedBox(height: 10),
            TextField(
              onChanged: (value) {
                if (isChecking != null) {
                  isChecking!.change(false);
                }
                if (isHandsUp == null) return;
                isHandsUp!.change(true);
              },
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                  hintText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    //ESQUINAS RODEADAS
                    borderRadius: BorderRadius.circular(12),
                  )),
            ),
            SizedBox(
              width: size.width,
              child: const Text(
                "Forgot your password?",
                //Alinear a la derecha
                textAlign: TextAlign.right,
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(height: 10),
            MaterialButton(
              minWidth: size.width,
              height: 50,
              color: Colors.purple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onPressed: () {},
              child: Text(
                "Login",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Register",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline),
                      ))
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
