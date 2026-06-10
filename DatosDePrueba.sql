USE ClinicaDDBB
GO

SELECT * FROM Especialidades
SELECT * FROM EstadoTurno
SELECT * FROM HistoriaClinica
SELECT * FROM HorariosMedicos
SELECT * FROM MedicoEspecialidad
SELECT * FROM Medicos
SELECT * FROM Pacientes
SELECT * FROM Personas
SELECT * FROM Roles
SELECT * FROM Turnos
SELECT * FROM Usuarios

-- ROLES
INSERT INTO Roles (Nombre)
VALUES ('Administrador'), ('Recepcionista'), ('Medico');
GO

-- PERSONAS
INSERT INTO Personas (Nombres, Apellidos, DNI, FechaNacimiento, Email, Telefono, Direccion)
VALUES
('Juan', 'Perez', '30111222', '1990-05-10', 'juan.perez@mail.com', '1130000001', 'CABA'),
('Maria', 'Gomez', '27999888', '1988-08-22', 'maria.gomez@mail.com', '1130000002', 'CABA'),
('Laura', 'Diaz', '33111223', '1992-11-15', 'laura.diaz@mail.com', '1130000003', 'GBA'),
('Carlos', 'Lopez', '40111224', '1985-03-03', 'carlos.lopez@mail.com', '1130000004', 'CABA');
GO

-- PACIENTES
INSERT INTO Pacientes (IDPersona, ObraSocial, GrupoSanguineo, Alergias, TelefonoEmergencia)
SELECT IDPersona, 'OSDE', 'O+', 'Ninguna', '1140000001'
FROM Personas
WHERE DNI = '30111222';


-- USUARIOS
INSERT INTO Pacientes (IDPersona, ObraSocial, GrupoSanguineo, Alergias, TelefonoEmergencia)
SELECT IDPersona, 'PAMI', 'A+', 'Penicilina', '1140000002'
FROM Personas
WHERE DNI = '27999888';
GO

--MEDICOS
INSERT INTO Medicos (IDPersona, Matricula)
SELECT IDPersona, 'MAT-1001'
FROM Personas
WHERE DNI = '40111224';
GO

-- ESPECIALIDADES
INSERT INTO Especialidades (Nombre, Descripcion)
VALUES
('Clinica Medica', 'Atencion general'),
('Dentista', 'Atencion odontologica'),
('Pediatria', 'Atencion infantil');
GO

-- RELACION MEDIO Y ESPECIALIDADES
INSERT INTO MedicoEspecialidad (IDMedico, IDEspecialidad)
SELECT m.IDMedico, e.IDEspecialidad
FROM Medicos m
INNER JOIN Especialidades e
    ON e.Nombre IN ('Clinica Medica', 'Dentista')
WHERE m.Matricula = 'MAT-1001';
GO


--HORARIOS MEDICOS
INSERT INTO HorariosMedicos (IDMedico, DiaSemana, HoraInicio, HoraFin)
SELECT IDMedico, 1, '08:00', '12:00'
FROM Medicos
WHERE Matricula = 'MAT-1001';

INSERT INTO HorariosMedicos (IDMedico, DiaSemana, HoraInicio, HoraFin)
SELECT IDMedico, 2, '08:00', '12:00'
FROM Medicos
WHERE Matricula = 'MAT-1001';
GO

-- INSERTAR TURNO
INSERT INTO EstadoTurno (Nombre)
VALUES 
('Nuevo'),
('Reprogramado'),
('Cancelado'),
('Cerrado');
GO



--- PROCEDIMIENTO REGISTRAR TURNO
EXEC RegistrarTurno
    @IDPaciente = 1,
    @IDMedico = 1,
    @IDEspecialidad = 1,
    @Fecha = '2026-06-15',
    @Hora = '08:00',
    @Observaciones = 'Control general';

-- REPROGRAMAR TURNO
EXEC ReprogramarTurno
    @IDTurno = 1,
    @NuevaFecha = '2026-06-16',
    @NuevaHora = '09:00';

-- CANCELAR TURNO
EXEC CancelarTurno
    @IDTurno = 1;


-- REGISTRAR DIAGNOSTICO
EXEC RegistrarDiagnostico
    @IDTurno = 1,
    @Diagnostico = 'Control de rutina',
    @Tratamiento = 'Ninguno',
    @Observaciones = 'Paciente estable';




--- PRUEBAS DE ERROR / TURNO VENCIDO
EXEC RegistrarTurno
    @IDPaciente = 1,
    @IDMedico = 1,
    @IDEspecialidad = 1,
    @Fecha = '2020-01-01',
    @Hora = '08:00',
    @Observaciones = 'Turno vencido';


-- TURNO FUERA DEL HORARIO MEDICO
EXEC RegistrarTurno
    @IDPaciente = 1,
    @IDMedico = 1,
    @IDEspecialidad = 1,
    @Fecha = '2026-06-15',
    @Hora = '15:00',
    @Observaciones = 'Horario invalido';

-- DIAGNOSTICO VACIO
EXEC RegistrarDiagnostico
    @IDTurno = 1,
    @Diagnostico = '',
    @Tratamiento = 'Ninguno',
    @Observaciones = 'Sin diagnostico';


-- ELIMINAR TURNO , DEJA ACTIVO = 1
DELETE FROM Turnos WHERE IDTurno = 1;
