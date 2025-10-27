import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
//3.1 Importar librería de Timer
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true; // Estado inicial
  bool _isLoading = false; // Estado de carga para el botón

  // Cerebro de la lógica de las animaciones
  StateMachineController?
      controller; // El ? sirve para verificar que la variable no sea nulo
  // SMI: State Machine Input
  SMIBool? isChecking; // Activa la movilidad de los ojos
  SMIBool? isHandsUp; // Se tapa los ojos
  SMITrigger? trigSuccess; // Se emociona
  SMITrigger? trigFail; // Se pone triste

  //2.1 Seguimiento de la cabeza
  SMINumber? numLook; // Sigue el cursor

  // 1.1 FocusNode (Nodo donde esta el foco)
  final emailFocus = FocusNode();
  final passFocus = FocusNode();

  //3.2 Timer para detemrinar cuando dejó de escribir
  Timer? _typingDebounce;

  //4.1 Controllers
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  // 4.2 Errores para mostrar en la UI (solo el primer error relevante)
  String? emailError;
  String? passError;

  // 4.3 Validar los campos
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String pass) {
    // mínimo 8, una mayúscula, una minúscula, un dígito y un especial
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }

  // 4.3.1 Validación dinámica - devuelve el PRIMER error aplicable o null
  String? _validateEmail(String email) {
    if (email.isEmpty) return null; // No mostrar error si está vacío
    if (!isValidEmail(email)) return 'Email inválido';
    return null;
  }

  String? _validatePassword(String pass) {
    if (pass.isEmpty) return null; // No mostrar nada si está vacío
    if (pass.length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(pass)) return 'Falta una mayúscula';
    if (!RegExp(r'[a-z]').hasMatch(pass)) return 'Falta una minúscula';
    if (!RegExp(r'\d').hasMatch(pass)) return 'Falta un dígito';
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(pass))
      return 'Falta un carácter especial';
    return null;
  }

  // 4.3.2 Actualizar errores en vivo
  void _updateEmailError() {
    setState(() {
      emailError = _validateEmail(emailCtrl.text.trim());
    });
  }

  void _updatePasswordError() {
    setState(() {
      passError = _validatePassword(passCtrl.text.trim());
    });
  }

  // 4.4 Validar al presionar el botón (FIX: doble tap)
  Future<void> _onLogin() async {
    if (_isLoading) return; // Evitar spam del botón

    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();

    // Validar campos (ahora muestra error aunque esté vacío al enviar)
    final eError = email.isEmpty
        ? 'El email es requerido'
        : (isValidEmail(email) ? null : 'Email inválido');
    final pError = pass.isEmpty
        ? 'La contraseña es requerida'
        : (isValidPassword(pass) ? null : _validatePassword(pass));

    // Actualizar UI con errores
    setState(() {
      emailError = eError;
      passError = pError;
      _isLoading = true; // Activar estado de carga
    });

    // 1. Cerrar teclado y normalizar estado de la animación
    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    isChecking?.change(false);
    isHandsUp?.change(false);
    numLook?.value = 50.0; // Mirar al frente

    // 2. Esperar un frame para que la State Machine procese los cambios
    await Future.delayed(const Duration(milliseconds: 50));

    // 3. Simular delay de red (~1s)
    await Future.delayed(const Duration(milliseconds: 1000));

    // 4. Disparar el trigger correspondiente
    if (eError == null && pError == null) {
      trigSuccess?.fire();
    } else {
      trigFail?.fire();
    }

    // 5. Desactivar estado de carga
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 2) Listeners (Oyentes, escuchadores)
  @override
  void initState() {
    super.initState();

    // Listener de validación en vivo para email
    emailCtrl.addListener(_updateEmailError);

    // Listener de validación en vivo para password
    passCtrl.addListener(_updatePasswordError);

    emailFocus.addListener(() {
      if (emailFocus.hasFocus) {
        isHandsUp?.change(false); // Manos abajo en email
        // 2.2 Seguir el cursor en email
        numLook?.value = 50.0;
        isHandsUp?.change(false); // Manos abajo en email
      }
    });
    passFocus.addListener(() {
      isHandsUp?.change(passFocus.hasFocus); // Manos arriba en password
    });
  }

  @override
  Widget build(BuildContext context) {
    // Para obtener el tamaño de la pantalla del disp.
    // MediaQuery = Consulta de las propiedades de la pantalla
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      // Evita nudge o cámaras frontales para móviles
      body: SafeArea(
        child: Padding(
          // Eje X/horizontal/derecha izquierda
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 200,
                child: RiveAnimation.asset(
                  'assets/animated_login_character.riv',
                  // Para vincular las animaciones con el estado de la maquina
                  stateMachines: ["Login Machine"],
                  // Al iniciarse
                  onInit: (artboard) {
                    controller = StateMachineController.fromArtboard(
                      artboard,
                      "Login Machine",
                    );
                    // Verificar que inició bien
                    if (controller == null) return;
                    artboard.addController(
                      controller!,
                    ); // El ! es para decirle que no es nulo
                    isChecking = controller!.findSMI('isChecking');
                    isHandsUp = controller!.findSMI('isHandsUp');
                    trigSuccess = controller!.findSMI('trigSuccess');
                    trigFail = controller!.findSMI('trigFail');
                    // 2.3 Enlazar el seguimiento de la cabeza
                    numLook = controller!.findSMI('numLook');
                  },
                ),
              ),
              // Espacio entre el oso y el texto Emial
              const SizedBox(height: 10),
              // Campo de texto del Email
              TextField(
                focusNode: emailFocus, // Asiganas el focusNode al TextField
                //4.8 Controllers
                controller: emailCtrl,
                onChanged: (value) {
                  //2.4 Seguir el cursor en email
                  //"Esta escribiendo en email"
                  isChecking!.change(true);

                  //Ajustar el seguimiento de la cabeza
                  final look = (value.length / 80.0 * 100.0).clamp(0.0, 100.0);
                  numLook?.value = look;

                  //3.3 Debounce: si vuelve a escribir, reinicia el timer
                  if (_typingDebounce?.isActive ?? false)
                    _typingDebounce?.cancel();
                  _typingDebounce = Timer(const Duration(seconds: 3), () {
                    if (!mounted) {
                      return;
                    }
                    // "Dejó de escribir en email"
                    isChecking?.change(false);
                  });
                  // Si es nulo no intenta cargar la animación
                  if (isChecking == null) return;
                  // Activa el seguimiento de los ojos
                  isChecking!.change(true);
                },
                // Para que aparezca el @ en móviles UI/UX
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  errorText: emailError, // Mostrar el error
                  hintText: "Email",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    // Esquinas redondeadas
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              // Campo de texto de la contraseña
              TextField(
                focusNode: passFocus, // Asiganas el focusNode al TextField
                //4.9 Controllers
                controller: passCtrl,
                onChanged: (value) {
                  if (isChecking != null) {
                    // Tapar los ojos al escribir el Email
                    // isChecking!.change(false);
                  }
                  // Si es nulo no intenta cargar la animación
                  if (isHandsUp == null) return;
                  // Activa el seguimiento de los ojos
                  isHandsUp!.change(true);
                },
                // Para ocultar el texto
                obscureText: _isObscure,
                // Para que aparezca el @ en móviles UI/UX
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  errorText: passError, // Mostrar el error
                  hintText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                  border: OutlineInputBorder(
                    // Esquinas redondeadas
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Texto "Olvidé contraseña"
              SizedBox(
                width: size.width,
                child: const Text(
                  "Forgot your password?",
                  // Alinear a la derecha
                  textAlign: TextAlign.right,
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
              // Botón de login
              const SizedBox(height: 10),
              // Botón estilo Android con estado de carga
              MaterialButton(
                minWidth: size.width,
                height: 50,
                color: _isLoading ? Colors.blue.shade300 : Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onPressed: _isLoading
                    ? null
                    : _onLogin, // Deshabilitar si está cargando
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text("Login",
                        style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
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
                          // En negritas
                          fontWeight: FontWeight.bold,
                          // Subrayado
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 4) Liberación de recursos / limpieza de focos
  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    emailFocus.dispose();
    passFocus.dispose();
    _typingDebounce?.cancel();
    super.dispose();
  }
}
