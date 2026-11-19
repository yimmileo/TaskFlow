# taskflow

TaskFlow es una aplicación Flutter para consultar y organizar tareas académicas.
Carga tareas de una API REST, permite navegar desde el listado hacia su detalle
y conserva en memoria los cambios de estado mientras la aplicación está abierta.

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
- **ViewModel:** `TasksViewModel` carga las tareas de forma asíncrona, expone
  estados de carga y error, y alterna el estado de una tarea.
- **Repository:** `TaskRepository` define el contrato y
  `RemoteTaskRepository` obtiene datos del servicio; `LocalTaskRepository`
  conserva las cinco tareas locales para pruebas y uso alternativo.
- **Provider:** comparte el mismo ViewModel entre la lista y el detalle.

El recorrido remoto es Service → Repository → ViewModel → Views. Al cambiar el
estado desde el detalle, la copia en memoria se actualiza y ambas pantallas se
notifican. Ese cambio no se guarda en el servidor y se pierde al reiniciar.

### Pantallas previstas

- **Lista:** tarjetas de tareas y acción futura para crear.
- **Detalle:** información completa y acciones futuras de editar o eliminar.
- **Formulario:** campos de título, descripción y prioridad.

### Requisitos no funcionales

- Los textos de navegación deben ser claros y comprensibles.
- Un id inexistente debe mostrar un mensaje entendible.
- La prioridad debe limitarse a Alta, Media o Baja.
- Los datos locales deben permitir probar navegación sin conexión.

### API de tareas

```text
GET https://jsonplaceholder.typicode.com/todos?userId=2
```

TaskFlow utiliza Dio por HTTPS para consultar los todos del usuario `2`.
La respuesta proporciona `userId`, `id`, `title` y `completed`; el modelo los
convierte a sus tipos Dart, usando `completed` como `isCompleted`. Esta API no
incluye `description` ni `priority`, así que la app muestra los valores de
ejemplo **“Sin descripción (API)”** y **“Sin prioridad (API)”**.

Completar o reabrir una tarea solo cambia la copia en memoria de TaskFlow:
JSONPlaceholder no persiste esta modificación. Las operaciones de crear,
editar y eliminar quedan para una API posterior.

### Estados de carga de la lista

La lista distingue entre carga, datos, respuesta vacía y error. Durante una
petición muestra un indicador; si la API devuelve una lista vacía, muestra
“Todavía no hay tareas para mostrar” y el botón **Actualizar**. Si la petición
falla, muestra un mensaje y el botón **Reintentar**. Con tareas disponibles se
puede actualizar desde el icono de la barra o deslizando la lista hacia abajo.

Para comprobar los estados manualmente:

- **Datos y carga:** inicia la app con internet y observa el indicador antes de
  que aparezcan las tareas de `userId=2`.
- **Vacío:** cambia temporalmente `TaskApiService.userId` a `9999`, reinicia la
  app y comprueba el mensaje y el botón **Actualizar**; luego restaura `2`.
- **Error y recuperación:** sin conexión, pulsa **Actualizar**; al volver a
  conectarte, pulsa **Reintentar** y confirma que la lista aparece sin reiniciar.

Las pruebas de widgets reproducen las respuestas pendientes, vacías y fallidas
con un repositorio controlado; así no dependen de la conexión a internet.
