import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:taskflow/app/taskflow_app.dart';
import 'package:taskflow/features/tasks/data/local_task_repository.dart';
import 'package:taskflow/features/tasks/data/task_repository.dart';
import 'package:taskflow/features/tasks/domain/task.dart';
import 'package:taskflow/features/tasks/presentation/tasks_view_model.dart';

class _PendingTaskRepository implements TaskRepository {
  final List<Completer<List<Task>>> requests = [];

  @override
  Future<List<Task>> getTasks() {
    final request = Completer<List<Task>>();
    requests.add(request);
    return request.future;
  }

  @override
  void save(Task task) {}
}

Widget createTestApp({TaskRepository? repository}) {
  return ChangeNotifierProvider(
    create: (_) =>
        TasksViewModel(repository ?? LocalTaskRepository())..loadTasks(),
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
    expect(find.text('Prioridad: Alta'), findsNWidgets(3));
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

  testWidgets('shows loading, empty response, and refreshes successfully', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _PendingTaskRepository();

    await tester.pumpWidget(createTestApp(repository: repository));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(repository.requests, hasLength(1));

    repository.requests[0].complete([]);
    await tester.pumpAndSettle();

    expect(find.text('Todavía no hay tareas para mostrar.'), findsOneWidget);
    expect(find.text('Actualizar'), findsOneWidget);
    expect(find.text('Reintentar'), findsNothing);

    await tester.tap(find.text('Actualizar'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(repository.requests, hasLength(2));

    repository.requests[1].complete([
      const Task(
        id: 20,
        title: 'Tarea remota de prueba',
        description: 'Sin descripción (API)',
        priority: 'Sin prioridad (API)',
        isCompleted: false,
        userId: 2,
      ),
    ]);
    await tester.pumpAndSettle();

    expect(find.text('Tarea remota de prueba'), findsOneWidget);
    expect(find.text('Actualizar'), findsNothing);
  });

  testWidgets('shows an error and retry loads tasks without restarting', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _PendingTaskRepository();

    await tester.pumpWidget(createTestApp(repository: repository));
    await tester.pump();
    repository.requests[0].completeError(StateError('network unavailable'));
    await tester.pumpAndSettle();

    expect(find.text('No se pudieron cargar las tareas.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('Actualizar'), findsNothing);

    await tester.tap(find.text('Reintentar'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(repository.requests, hasLength(2));

    repository.requests[1].complete([
      const Task(
        id: 21,
        title: 'Tarea recuperada',
        description: 'Sin descripción (API)',
        priority: 'Sin prioridad (API)',
        isCompleted: false,
        userId: 2,
      ),
    ]);
    await tester.pumpAndSettle();

    expect(find.text('Tarea recuperada'), findsOneWidget);
    expect(find.text('No se pudieron cargar las tareas.'), findsNothing);
  });

  testWidgets('the toolbar refresh button requests updated tasks', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _PendingTaskRepository();

    await tester.pumpWidget(createTestApp(repository: repository));
    await tester.pump();
    repository.requests[0].complete([
      const Task(
        id: 22,
        title: 'Tarea antes de actualizar',
        description: 'Sin descripción (API)',
        priority: 'Sin prioridad (API)',
        isCompleted: false,
        userId: 2,
      ),
    ]);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Actualizar tareas'));
    await tester.pump();

    expect(repository.requests, hasLength(2));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    repository.requests[1].complete([]);
    await tester.pumpAndSettle();
    expect(find.text('Todavía no hay tareas para mostrar.'), findsOneWidget);
  });
}
