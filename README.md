# ClinicaDDBB

Base de datos relacional para la gestión de una clínica médica.

## Descripción

Este repositorio contiene el diseño y la implementación de una base de datos para una clínica médica. El sistema permite administrar pacientes, médicos, especialidades, horarios de atención, turnos médicos y historia clínica, manteniendo la información organizada y evitando inconsistencias en la asignación de turnos.

El modelo fue normalizado utilizando una tabla **Personas** para centralizar los datos comunes de pacientes, médicos y usuarios del sistema, reduciendo redundancia y mejorando el mantenimiento.

## Funcionalidades principales

- Registro de personas, pacientes, médicos y usuarios.
- Asociación de médicos con una o más especialidades.
- Administración de horarios de atención por médico y día de la semana.
- Alta, reprogramación y cancelación de turnos.
- Control de duplicados por médico y paciente.
- Validación de turnos vencidos.
- Registro de historia clínica por turno atendido.
- Manejo de estados de turno: Nuevo, Reprogramado, Cancelado, No Asistió y Cerrado.
- Vistas para consulta rápida de turnos, médicos por especialidad e historial de pacientes.
- Triggers y procedimientos almacenados con validaciones de negocio.

## Estructura de la base

### Tablas principales

- `Roles`
- `Personas`
- `Usuarios`
- `Especialidades`
- `Pacientes`
- `Medicos`
- `MedicoEspecialidad`
- `EstadoTurno`
- `HorariosMedicos`
- `Turnos`
- `HistoriaClinica`

### Objetos de base de datos

- **Vistas**
  - `MedicosEspecialidades`
  - `TurnosDelDia`
  - `HistorialPaciente`

- **Triggers**
  - `TurnosValidar`
  - `TurnosNoEliminados`

- **Procedimientos almacenados**
  - `RegistrarTurno`
  - `ReprogramarTurno`
  - `CancelarTurno`
  - `RegistrarDiagnostico`

## Requisitos

- Microsoft SQL Server.
- SQL Server Management Studio o una herramienta compatible.

## Cómo ejecutar el proyecto

1. Ejecutar primero el script de creación de base de datos.
2. Cargar las tablas en este orden:
   - `Roles`
   - `Personas`
   - `Usuarios`
   - `Especialidades`
   - `Pacientes`
   - `Medicos`
   - `MedicoEspecialidad`
   - `EstadoTurno`
   - `HorariosMedicos`
   - `Turnos`
   - `HistoriaClinica`
3. Ejecutar las vistas.
4. Ejecutar los triggers.
5. Ejecutar los procedimientos almacenados.
6. Cargar datos de prueba si se desea probar la lógica completa.

## Reglas de negocio destacadas

- No se pueden registrar turnos vencidos.
- No puede existir más de un turno para el mismo médico, fecha y hora.
- No puede existir más de un turno para el mismo paciente, fecha y hora.
- Un turno solo puede asignarse si el médico tiene disponibilidad.
- Un turno no puede eliminarse físicamente; solo puede reprogramarse o cancelarse.
- El diagnóstico solo puede registrarse una vez por turno.

“Gracias por visitar este repositorio. Espero que este proyecto te sea útil.”
