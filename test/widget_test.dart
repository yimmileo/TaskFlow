import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:taskflow/app/taskflow_app.dart';
import 'package:taskflow/features/tasks/data/local_task_repository.dart';
import 'package:taskflow/features/tasks/presentation/tasks_view_model.dart';

Widget createTestApp() {
  return ChangeNotifierProvider(
    create: (_) => TasksViewModel(LocalTaskRepository()),
    child: const TaskFlowApp(),
  );
}

void main() {
  setUp(() => appRouter.go('/'));

  testWidgets('shows five local tasks', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Mis tareas'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(5));
    expect(find.text('Definir las funciones de TaskFlow'), findsOneWidget);
    expect(
      find.text('Alta · Organizar los requisitos del proyecto'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('the task list scrolls to the final task', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    expect(find.text('Preparar la evidencia del avance'), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Preparar la evidencia del avance'), findsOneWidget);
  });

  testWidgets('completion updates detail and list through shared view model', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Diseñar la pantalla de tareas'));
    await tester.pumpAndSettle();

    expect(appRouter.state.uri.path, '/task/2');
    expect(find.text('Prioridad: Alta'), findsOneWidget);
    expect(find.text('Estado: pendiente'), findsOneWidget);
    expect(find.text('Usuario: 1'), findsOneWidget);

    await tester.tap(find.text('Marcar como completada'));
    await tester.pumpAndSettle();

    expect(find.text('Estado: completada'), findsOneWidget);
    expect(find.text('Marcar como pendiente'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(appRouter.state.uri.path, '/');
    final taskTile = find.ancestor(
      of: find.text('Diseñar la pantalla de tareas'),
      matching: find.byType(ListTile),
    );
    expect(
      find.descendant(of: taskTile, matching: find.byIcon(Icons.check_circle)),
      findsOneWidget,
    );

    await tester.tap(find.text('Diseñar la pantalla de tareas'));
    await tester.pumpAndSettle();
    expect(find.text('Estado: completada'), findsOneWidget);
  });

  testWidgets('shows a message for invalid or unknown task routes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    appRouter.go('/task/not-a-number');
    await tester.pumpAndSettle();
    expect(find.text('No se encontró esta tarea.'), findsOneWidget);

    appRouter.go('/task/999');
    await tester.pumpAndSettle();
    expect(find.text('No se encontró esta tarea.'), findsOneWidget);

    appRouter.go('/missing');
    await tester.pumpAndSettle();
    expect(find.text('No se encontró esta tarea.'), findsOneWidget);
  });
}
