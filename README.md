# taskflow

TaskFlow es una aplicación Flutter para consultar y organizar tareas académicas
con datos locales. Permite navegar desde un listado hacia el detalle de cada
tarea y muestra su prioridad, estado y usuario.

## Ejecutar el proyecto

```bash
flutter pub get
flutter run
```

Para verificar el código y las pruebas:

```bash
dart format lib test
flutter analyze
flutter test
```

## Alcance de TaskFlow

**Problema:** las actividades académicas están dispersas y una persona necesita
saber cuáles están pendientes.

**Usuario objetivo:** estudiante que planifica entregas semanales.

### Historias de usuario y criterios de aceptación

1. Como estudiante, quiero listar mis tareas para ver qué debo hacer.
   **Criterio:** la lista muestra título, prioridad y estado de cada tarea.
2. Como estudiante, quiero abrir una tarea para leer su descripción.
   **Criterio:** al tocar una tarjeta aparece el detalle de la tarea elegida.
3. Como estudiante, quiero crear una tarea para registrar un pendiente.
   **Criterio:** el formulario guarda una tarea válida y la lista la muestra.
4. Como estudiante, quiero editar una tarea para corregir sus datos.
   **Criterio:** los cambios guardados aparecen en lista y detalle.
5. Como estudiante, quiero eliminar una tarea terminada para limpiar la lista.
   **Criterio:** después de confirmar, la tarea desaparece de la lista.

### Modelo de datos

`Task`: `id` (entero único), `title` (texto), `description` (texto),
`priority` (Alta, Media o Baja), `isCompleted` (booleano) y `userId`
(entero que identifica al usuario de prueba).

La clase compartida se encuentra en
`lib/features/tasks/domain/task.dart`, con constructor desde JSON (`fromJson`)
y `copyWith` para crear una versión actualizada de una tarea.

### Arquitectura

TaskFlow separa responsabilidades con MVVM:

- **Model:** `Task` representa los datos de una tarea.
- **View:** la lista y el detalle presentan las tareas y reciben acciones.
- **ViewModel:** `TasksViewModel` expone las tareas y alterna su estado.
- **Repository:** `TaskRepository` define el contrato y
  `LocalTaskRepository` mantiene los datos de ejemplo en memoria.
- **Provider:** comparte el mismo ViewModel entre la lista y el detalle.

Al cambiar el estado desde el detalle, el repositorio local actualiza la tarea
y el ViewModel notifica a ambas pantallas. Los cambios se pierden al reiniciar
la aplicación; todavía no hay persistencia en disco ni solicitudes a la API.

### Pantallas previstas

- **Lista:** tarjetas de tareas y acción futura para crear.
- **Detalle:** información completa y acciones futuras de editar o eliminar.
- **Formulario:** campos de título, descripción y prioridad.

### Requisitos no funcionales

- Los textos de navegación deben ser claros y comprensibles.
- Un id inexistente debe mostrar un mensaje entendible.
- La prioridad debe limitarse a Alta, Media o Baja.
- Los datos locales deben permitir probar navegación sin conexión.

### Contrato de API previsto

```text
GET    /tasks        listar tareas
GET    /tasks/:id    consultar detalle
POST   /tasks        crear tarea
PATCH  /tasks/:id    actualizar tarea
DELETE /tasks/:id    eliminar tarea
```

Estos endpoints describen el alcance futuro. Esta versión todavía usa datos
locales y no realiza solicitudes HTTP.
