import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskflow/main.dart';

void main() {
  testWidgets('shows five local tasks using reusable task cards', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    appRouter.go('/');
    await tester.pumpWidget(const TaskFlowApp());
    await tester.pumpAndSettle();

    expect(find.text('Mis tareas'), findsOneWidget);
    expect(find.byType(TaskCard), findsNWidgets(demoTasks.length));
    expect(find.text('Definir las funciones de TaskFlow'), findsOneWidget);
    expect(
      find.text('Alta · Organizar los requisitos del proyecto'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(demoTasks.length));
  });

  testWidgets('the task list scrolls to the final task', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    appRouter.go('/');
    await tester.pumpWidget(const TaskFlowApp());
    await tester.pumpAndSettle();
    expect(find.text('Preparar la evidencia del avance'), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Preparar la evidencia del avance'), findsOneWidget);
  });

  testWidgets('opens tasks by id and returns to the list', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    appRouter.go('/');
    await tester.pumpWidget(const TaskFlowApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Diseñar la pantalla de tareas'));
    await tester.pumpAndSettle();

    expect(appRouter.state.uri.path, '/task/2');
    expect(find.text('Diseñar la pantalla de tareas'), findsOneWidget);
    expect(
      find.text('Definir la estructura visual de cada tarjeta'),
      findsOneWidget,
    );
    expect(find.text('Prioridad: Alta'), findsOneWidget);
    expect(find.text('Estado: pendiente'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, '/');

    await tester.tap(find.text('Definir las funciones de TaskFlow'));
    await tester.pumpAndSettle();

    expect(appRouter.state.uri.path, '/task/1');
    expect(find.text('Estado: completada'), findsOneWidget);

    await tester.tap(find.text('Volver al listado'));
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, '/');

    await tester.tap(find.text('Crear el listado local'));
    await tester.pumpAndSettle();

    expect(appRouter.state.uri.path, '/task/3');
    expect(find.text('Mostrar tareas con ListView.builder'), findsOneWidget);

    appRouter.go('/task/not-a-number');
    await tester.pumpAndSettle();
    expect(find.text('No se encontró la tarea solicitada.'), findsOneWidget);

    await tester.tap(find.text('Volver al listado'));
    await tester.pumpAndSettle();
    expect(appRouter.state.uri.path, '/');
    expect(find.byType(TaskCard), findsNWidgets(demoTasks.length));

    appRouter.go('/task/999');
    await tester.pumpAndSettle();
    expect(find.text('No se encontró la tarea solicitada.'), findsOneWidget);

    appRouter.go('/missing');
    await tester.pumpAndSettle();
    expect(find.text('No se encontró la tarea solicitada.'), findsOneWidget);
  });
}
