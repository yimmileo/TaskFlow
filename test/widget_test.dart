import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taskflow/main.dart';

void main() {
  testWidgets('shows five local tasks using reusable task cards', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const TaskFlowApp());

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

    await tester.pumpWidget(const TaskFlowApp());
    expect(find.text('Preparar la evidencia del avance'), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Preparar la evidencia del avance'), findsOneWidget);
  });
}
