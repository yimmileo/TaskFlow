import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskflow/main.dart';

void main() {
  testWidgets('shows the TaskFlow welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());

    expect(find.text('TaskFlow'), findsOneWidget);
    expect(find.text('¡Hola, YIMMI LEONEL BARBERAN MOREIRA!'), findsOneWidget);
    expect(find.text('Tareas pendientes: 3'), findsOneWidget);
    expect(find.text('Completadas hoy: 0 de 5'), findsOneWidget);
    expect(
      find.text('Cada pequeño paso te acerca a tus objetivos.'),
      findsOneWidget,
    );
  });

  testWidgets('adds tasks and completes them toward the daily goal', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TaskFlowApp());

    await tester.tap(find.text('Agregar tarea'));
    await tester.pump();

    expect(find.text('Tareas pendientes: 4'), findsOneWidget);

    await tester.tap(find.text('Completar una tarea'));
    await tester.pump();

    expect(find.text('Tareas pendientes: 3'), findsOneWidget);
    expect(find.text('Completadas hoy: 1 de 5'), findsOneWidget);
  });

  testWidgets('disables completion at zero and shows the empty status', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TaskFlowApp());

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Completar una tarea'));
      await tester.pump();
    }

    expect(find.text('Tareas pendientes: 0'), findsOneWidget);
    expect(find.text('Completadas hoy: 3 de 5'), findsOneWidget);
    expect(
      find.text('¡Excelente! No tienes tareas pendientes.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<OutlinedButton>(
            find.ancestor(
              of: find.text('Completar una tarea'),
              matching: find.byType(OutlinedButton),
            ),
          )
          .onPressed,
      isNull,
    );
  });
}
