import '../domain/task.dart';
import 'task_repository.dart';

class LocalTaskRepository implements TaskRepository {
  final List<Task> _tasks = [
    const Task(
      id: 1,
      title: 'Definir las funciones de TaskFlow',
      description: 'Organizar los requisitos del proyecto',
      priority: 'Alta',
      isCompleted: true,
      userId: 1,
    ),
    const Task(
      id: 2,
      title: 'Diseñar la pantalla de tareas',
      description: 'Definir la estructura visual de cada tarjeta',
      priority: 'Alta',
      isCompleted: false,
      userId: 1,
    ),
    const Task(
      id: 3,
      title: 'Crear el listado local',
      description: 'Mostrar tareas con ListView.builder',
      priority: 'Alta',
      isCompleted: false,
      userId: 1,
    ),
    const Task(
      id: 4,
      title: 'Probar estados y desplazamiento',
      description: 'Verificar tareas pendientes y completadas',
      priority: 'Media',
      isCompleted: false,
      userId: 1,
    ),
    const Task(
      id: 5,
      title: 'Preparar la evidencia del avance',
      description: 'Capturar la lista y revisar el código',
      priority: 'Baja',
      isCompleted: false,
      userId: 1,
    ),
  ];

  @override
  List<Task> getTasks() => List.unmodifiable(_tasks);

  @override
  void save(Task task) {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index == -1) {
      throw StateError('Cannot save task ${task.id}: task was not found.');
    }
    _tasks[index] = task;
  }
}
