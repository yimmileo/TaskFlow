import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/features/tasks/data/task_repository.dart';
import 'package:taskflow/features/tasks/domain/task.dart';
import 'package:taskflow/features/tasks/presentation/tasks_view_model.dart';

class _FakeTaskRepository implements TaskRepository {
  _FakeTaskRepository(this.tasks);

  final List<Task> tasks;
  final List<Task> savedTasks = [];
  int getTasksCalls = 0;
  Object? error;

  @override
  Future<List<Task>> getTasks() async {
    getTasksCalls++;
    if (error case final error?) throw error;
    return List.unmodifiable(tasks);
  }

  @override
  void save(Task task) {
    savedTasks.add(task);
  }
}

void main() {
  test('Task.fromJson maps API fields and applies explicit defaults', () {
    final task = Task.fromJson({
      'id': 8,
      'userId': 2,
      'title': 'Task from API',
      'completed': true,
    });

    expect(task.id, 8);
    expect(task.userId, 2);
    expect(task.title, 'Task from API');
    expect(task.isCompleted, isTrue);
    expect(task.description, 'Sin descripción (API)');
    expect(task.priority, 'Sin prioridad (API)');
  });

  test('loading and toggling uses the cached task list', () async {
    const task = Task(
      id: 8,
      title: 'Task from API',
      description: 'Sin descripción (API)',
      priority: 'Sin prioridad (API)',
      isCompleted: false,
      userId: 2,
    );
    final repository = _FakeTaskRepository([task]);
    final viewModel = TasksViewModel(repository);

    final loading = viewModel.loadTasks();
    expect(viewModel.isLoading, isTrue);
    await loading;

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.tasks, [task]);
    expect(viewModel.findTask(8), task);

    viewModel.toggleCompleted(8);

    expect(repository.getTasksCalls, 1);
    expect(repository.savedTasks.single.isCompleted, isTrue);
    expect(viewModel.findTask(8)?.isCompleted, isTrue);
  });

  test('loading failure exposes an error state and clears loading', () async {
    final repository = _FakeTaskRepository([]);
    repository.error = StateError('network unavailable');
    final viewModel = TasksViewModel(repository);

    await viewModel.loadTasks();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.errorMessage, 'No se pudieron cargar las tareas.');
    expect(viewModel.tasks, isEmpty);
  });
}
