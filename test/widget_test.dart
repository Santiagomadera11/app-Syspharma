import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// OJO: Cambia "syspharma" por el nombre exacto que tienes en la línea 'name:' de tu pubspec.yaml
import 'package:syspharma/main.dart'; 

void main() {
  testWidgets('La app inicia y muestra la pantalla de Login', (WidgetTester tester) async {
    // 1. CONFIGURACIÓN DE PANTALLA
    // Importante para que flutter_screenutil no falle en los tests
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3.0;

    // 2. INICIAR LA APP
    await tester.pumpWidget(const SysPharmaApp());
    await tester.pumpAndSettle();

    // 3. VERIFICACIONES
    // Busca algún texto del login. Si usaste "Log In" en el botón:
    expect(find.text('Log In'), findsWidgets);

    // Verifica que haya campos de texto (Usuario y Contraseña)
    expect(find.byType(TextField), findsAtLeastNWidgets(1));

    // 4. LIMPIEZA
    addTearDown(tester.view.resetPhysicalSize);
  });
}