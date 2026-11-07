import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const TaskFlowApp());
}

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const TaskListScreen()),
    GoRoute(
      path: '/task/:id',
      builder: (context, state) {
        final taskId = int.tryParse(state.pathParameters['id'] ?? '');
        if (taskId == null) {
          return const TaskNotFoundScreen();
        }
        return TaskDetailScreen(taskId: taskId);
      },
    ),
  ],
  errorBuilder: (context, state) => const TaskNotFoundScreen(),
);

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'TaskFlow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.isCompleted,
  });

  final int id;
  final String title;
  final String description;
  final String priority;
  final bool isCompleted;
}

const demoTasks = [
  Task(
    id: 1,
    title: 'Definir las funciones de TaskFlow',
    description: 'Organizar los requisitos del proyecto',
    priority: 'Alta',
    isCompleted: true,
  ),
  Task(
    id: 2,
    title: 'Diseñar la pantalla de tareas',
    description: 'Definir la estructura visual de cada tarjeta',
    priority: 'Alta',
    isCompleted: false,
  ),
  Task(
    id: 3,
    title: 'Crear el listado local',
    description: 'Mostrar tareas con ListView.builder',
    priority: 'Alta',
    isCompleted: false,
  ),
  Task(
    id: 4,
    title: 'Probar estados y desplazamiento',
    description: 'Verificar tareas pendientes y completadas',
    priority: 'Media',
    isCompleted: false,
  ),
  Task(
    id: 5,
    title: 'Preparar la evidencia del avance',
    description: 'Capturar la lista y revisar el código',
    priority: 'Baja',
    isCompleted: false,
  ),
];

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, this.onTap});

  final Task task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: task.isCompleted ? Colors.green : null,
        ),
        title: Text(task.title),
        subtitle: Text('${task.priority} · ${task.description}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis tareas')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: demoTasks.length,
        itemBuilder: (context, index) {
          final task = demoTasks[index];
          return TaskCard(
            task: task,
            onTap: () => context.push('/task/${task.id}'),
          );
        },
      ),
    );
  }
}

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context) {
    final matchingTasks = demoTasks.where((task) => task.id == taskId);
    if (matchingTasks.isEmpty) {
      return const TaskNotFoundScreen();
    }
    final task = matchingTasks.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de tarea')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text(task.description),
          const SizedBox(height: 16),
          Chip(label: Text('Prioridad: ${task.priority}')),
          const SizedBox(height: 12),
          Text(task.isCompleted ? 'Estado: completada' : 'Estado: pendiente'),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Volver al listado'),
          ),
        ],
      ),
    );
  }
}

class TaskNotFoundScreen extends StatelessWidget {
  const TaskNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de tarea')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No se encontró la tarea solicitada.'),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver al listado'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
