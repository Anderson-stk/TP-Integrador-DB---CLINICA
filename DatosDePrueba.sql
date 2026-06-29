USE ClinicaDDBB
GO

-- lIMPIEZA DE DATOS ANTERIORES PARA LA DEMOSTRACION. EJECUTAR HASTA LA LINEA 39 SI NO HAY DATOS CARGADOS ANTERIORMENTE.
DISABLE TRIGGER TurnosNoEliminados ON Turnos;
GO

DELETE FROM HistoriaClinica;
DELETE FROM Turnos;
DELETE FROM HorariosMedicos;
DELETE FROM MedicoEspecialidad;
DELETE FROM Usuarios;
DELETE FROM Medicos;
DELETE FROM Pacientes;
DELETE FROM Especialidades;
DELETE FROM Personas;
DELETE FROM Roles;
DELETE FROM EstadoTurno;
GO

-- Reiniciar los contadores IDENTITY para que los IDs vuelvan a arrancar en 1
-- (asi los EXEC de mas abajo, que asumen IDTurno = 1, 2, 3..., funcionan bien)
DBCC CHECKIDENT ('HistoriaClinica', RESEED, 0);
DBCC CHECKIDENT ('Turnos', RESEED, 0);
DBCC CHECKIDENT ('HorariosMedicos', RESEED, 0);
DBCC CHECKIDENT ('MedicoEspecialidad', RESEED, 0);
DBCC CHECKIDENT ('Usuarios', RESEED, 0);
DBCC CHECKIDENT ('Medicos', RESEED, 0);
DBCC CHECKIDENT ('Pacientes', RESEED, 0);
DBCC CHECKIDENT ('Especialidades', RESEED, 0);
DBCC CHECKIDENT ('Personas', RESEED, 0);
DBCC CHECKIDENT ('Roles', RESEED, 0);
DBCC CHECKIDENT ('EstadoTurno', RESEED, 0);
GO

-- Volver a habilitar el trigger (CRITICO: si no se vuelve a activar,
-- desde aca en adelante se podrian borrar turnos sin restriccion)
ENABLE TRIGGER TurnosNoEliminados ON Turnos;
GO

-- CARGA DE DATOS EN LAS TABLAS
INSERT INTO Roles (Nombre)
VALUES ('Administrador'), ('Recepcionista'), ('Medico');
GO

INSERT INTO EstadoTurno (Nombre)
VALUES ('Nuevo'), ('Reprogramado'), ('Cancelado'), ('Cerrado');
GO

INSERT INTO Especialidades (Nombre, Descripcion)
VALUES
('Clinica Medica', 'Atencion general'),
('Dentista', 'Atencion odontologica'),
('Pediatria', 'Atencion infantil'),
('Dermatologia', 'Atencion de piel'),
('Cardiologia', 'Atencion cardiovascular');
GO

INSERT INTO Personas (Nombres, Apellidos, DNI, FechaNacimiento, Email, Telefono, Direccion)
VALUES

('Carlos', 'Lopez',     '40111224', '1985-03-03', 'carlos.lopez@mail.com',     '1130000004', 'CABA'),
('Ana',    'Martinez',  '28555666', '1980-07-19', 'ana.martinez@mail.com',     '1130000005', 'CABA'),
('Roberto','Fernandez', '25444333', '1975-12-01', 'roberto.fernandez@mail.com','1130000006', 'GBA'),
('Lucia',  'Sanchez',   '32777888', '1990-09-25', 'lucia.sanchez@mail.com',    '1130000007', 'CABA'),
('Diego',  'Torres',    '29888999', '1982-02-14', 'diego.torres@mail.com',     '1130000008', 'GBA'),

('Sofia',  'Ramirez',   '35222111', '1995-06-10', 'sofia.ramirez@mail.com',    '1130000009', 'CABA'),
('Martin', 'Gutierrez', '38999000', '1998-01-30', 'martin.gutierrez@mail.com', '1130000010', 'GBA'),
('Valentina','Castro',  '36111444', '1996-04-18', 'valentina.castro@mail.com', '1130000011', 'CABA'),
('Federico','Romero',   '31555222', '1991-10-05', 'federico.romero@mail.com',  '1130000012', 'GBA'),
('Camila', 'Flores',    '34666777', '1994-08-08', 'camila.flores@mail.com',    '1130000013', 'CABA');
GO

INSERT INTO Personas (Nombres, Apellidos, DNI, FechaNacimiento, Email, Telefono, Direccion)
VALUES
('Juan',  'Perez', '30111222', '1990-05-10', 'juan.perez@mail.com',  '1130000001', 'CABA'),
('Maria', 'Gomez', '27999888', '1988-08-22', 'maria.gomez@mail.com', '1130000002', 'CABA'),
('Laura', 'Diaz',  '33111223', '1992-11-15', 'laura.diaz@mail.com',  '1130000003', 'GBA');
GO


INSERT INTO Medicos (IDPersona, Matricula)
SELECT IDPersona, 'MAT-1001' FROM Personas WHERE DNI = '40111224';   -- Carlos Lopez

INSERT INTO Medicos (IDPersona, Matricula)
SELECT IDPersona, 'MAT-1002' FROM Personas WHERE DNI = '28555666';   -- Ana Martinez

INSERT INTO Medicos (IDPersona, Matricula)
SELECT IDPersona, 'MAT-1003' FROM Personas WHERE DNI = '25444333';   -- Roberto Fernandez

INSERT INTO Medicos (IDPersona, Matricula)
SELECT IDPersona, 'MAT-1004' FROM Personas WHERE DNI = '32777888';   -- Lucia Sanchez

INSERT INTO Medicos (IDPersona, Matricula)
SELECT IDPersona, 'MAT-1005' FROM Personas WHERE DNI = '29888999';   -- Diego Torres
GO


INSERT INTO Pacientes (IDPersona, ObraSocial, GrupoSanguineo, Alergias, TelefonoEmergencia)
SELECT IDPersona, 'OSDE',  'O+', 'Ninguna',     '1140000001' FROM Personas WHERE DNI = '30111222'; -- Juan Perez

INSERT INTO Pacientes (IDPersona, ObraSocial, GrupoSanguineo, Alergias, TelefonoEmergencia)
SELECT IDPersona, 'PAMI',  'A+', 'Penicilina',  '1140000002' FROM Personas WHERE DNI = '27999888'; -- Maria Gomez

INSERT INTO Pacientes (IDPersona, ObraSocial, GrupoSanguineo, Alergias, TelefonoEmergencia)
SELECT IDPersona, 'Swiss Medical', 'B+', 'Ninguna', '1140000003' FROM Personas WHERE DNI = '33111223'; -- Laura Diaz

INSERT INTO Pacientes (IDPersona, ObraSocial, GrupoSanguineo, Alergias, TelefonoEmergencia)
SELECT IDPersona, 'IOMA', 'AB+', 'Ibuprofeno',  '1140000004' FROM Personas WHERE DNI = '35222111'; -- Sofia Ramirez

INSERT INTO Pacientes (IDPersona, ObraSocial, GrupoSanguineo, Alergias, TelefonoEmergencia)
SELECT IDPersona, 'OSDE', 'O-', 'Ninguna',      '1140000005' FROM Personas WHERE DNI = '38999000'; -- Martin Gutierrez

INSERT INTO Pacientes (IDPersona, ObraSocial, GrupoSanguineo, Alergias, TelefonoEmergencia)
SELECT IDPersona, 'PAMI', 'A-', 'Latex',        '1140000006' FROM Personas WHERE DNI = '36111444'; -- Valentina Castro

INSERT INTO Pacientes (IDPersona, ObraSocial, GrupoSanguineo, Alergias, TelefonoEmergencia)
SELECT IDPersona, 'Galeno', 'B-', 'Ninguna',    '1140000007' FROM Personas WHERE DNI = '31555222'; -- Federico Romero

INSERT INTO Pacientes (IDPersona, ObraSocial, GrupoSanguineo, Alergias, TelefonoEmergencia)
SELECT IDPersona, 'Swiss Medical', 'AB-', 'Polen', '1140000008' FROM Personas WHERE DNI = '34666777'; -- Camila Flores

INSERT INTO Pacientes (IDPersona, ObraSocial, GrupoSanguineo, Alergias, TelefonoEmergencia)
SELECT IDPersona, 'OSDE', 'O+', 'Ninguna',      '1140000009' FROM Personas WHERE DNI = '40111224'; -- Carlos Lopez (tambien paciente, doble rol)

INSERT INTO Pacientes (IDPersona, ObraSocial, GrupoSanguineo, Alergias, TelefonoEmergencia)
SELECT IDPersona, 'IOMA', 'A+', 'Aspirina',     '1140000010' FROM Personas WHERE DNI = '28555666'; -- Ana Martinez (tambien paciente)
GO


-- RELACION MEDICO - ESPECIALIDAD
INSERT INTO MedicoEspecialidad (IDMedico, IDEspecialidad)
SELECT m.IDMedico, e.IDEspecialidad
FROM Medicos m INNER JOIN Especialidades e ON e.Nombre IN ('Clinica Medica', 'Dentista')
WHERE m.Matricula = 'MAT-1001';

-- Ana Martinez (MAT-1002): Pediatria
INSERT INTO MedicoEspecialidad (IDMedico, IDEspecialidad)
SELECT m.IDMedico, e.IDEspecialidad
FROM Medicos m INNER JOIN Especialidades e ON e.Nombre = 'Pediatria'
WHERE m.Matricula = 'MAT-1002';

-- Roberto Fernandez (MAT-1003): Cardiologia
INSERT INTO MedicoEspecialidad (IDMedico, IDEspecialidad)
SELECT m.IDMedico, e.IDEspecialidad
FROM Medicos m INNER JOIN Especialidades e ON e.Nombre = 'Cardiologia'
WHERE m.Matricula = 'MAT-1003';

-- Lucia Sanchez (MAT-1004): Dermatologia
INSERT INTO MedicoEspecialidad (IDMedico, IDEspecialidad)
SELECT m.IDMedico, e.IDEspecialidad
FROM Medicos m INNER JOIN Especialidades e ON e.Nombre = 'Dermatologia'
WHERE m.Matricula = 'MAT-1004';

-- Diego Torres (MAT-1005): Clinica Medica
INSERT INTO MedicoEspecialidad (IDMedico, IDEspecialidad)
SELECT m.IDMedico, e.IDEspecialidad
FROM Medicos m INNER JOIN Especialidades e ON e.Nombre = 'Clinica Medica'
WHERE m.Matricula = 'MAT-1005';
GO

-- HORARIOS MEDICOS
-- Carlos Lopez: Lunes y Martes 08-12
INSERT INTO HorariosMedicos (IDMedico, DiaSemana, HoraInicio, HoraFin)
SELECT IDMedico, 1, '08:00', '12:00' FROM Medicos WHERE Matricula = 'MAT-1001';
INSERT INTO HorariosMedicos (IDMedico, DiaSemana, HoraInicio, HoraFin)
SELECT IDMedico, 2, '08:00', '12:00' FROM Medicos WHERE Matricula = 'MAT-1001';

-- Ana Martinez: Miercoles y Jueves 09-13
INSERT INTO HorariosMedicos (IDMedico, DiaSemana, HoraInicio, HoraFin)
SELECT IDMedico, 3, '09:00', '13:00' FROM Medicos WHERE Matricula = 'MAT-1002';
INSERT INTO HorariosMedicos (IDMedico, DiaSemana, HoraInicio, HoraFin)
SELECT IDMedico, 4, '09:00', '13:00' FROM Medicos WHERE Matricula = 'MAT-1002';

-- Roberto Fernandez: Viernes 14-18
INSERT INTO HorariosMedicos (IDMedico, DiaSemana, HoraInicio, HoraFin)
SELECT IDMedico, 5, '14:00', '18:00' FROM Medicos WHERE Matricula = 'MAT-1003';

-- Lucia Sanchez: Lunes 14-18
INSERT INTO HorariosMedicos (IDMedico, DiaSemana, HoraInicio, HoraFin)
SELECT IDMedico, 1, '14:00', '18:00' FROM Medicos WHERE Matricula = 'MAT-1004';

-- Diego Torres: Martes 08-12
INSERT INTO HorariosMedicos (IDMedico, DiaSemana, HoraInicio, HoraFin)
SELECT IDMedico, 2, '08:00', '12:00' FROM Medicos WHERE Matricula = 'MAT-1005';
GO

-- TURNOS CASOS EXITOSOS, FECHAS, 2026-07-06 Lunes      2026-07-09 Jueves, 2026-07-07 Martes     2026-07-10 Viernes, 2026-07-08 Miercoles  2026-07-13 Lunes (semana siguiente)
-- Turno 1: Juan Perez con Carlos Lopez (Clinica Medica) - Lunes 08:00 -> OK
EXEC RegistrarTurno
    @IDPaciente   = (SELECT IDPaciente FROM Pacientes PA INNER JOIN Personas P ON P.IDPersona = PA.IDPersona WHERE P.DNI = '30111222'),
    @IDMedico     = (SELECT IDMedico FROM Medicos WHERE Matricula = 'MAT-1001'),
    @IDEspecialidad = (SELECT IDEspecialidad FROM Especialidades WHERE Nombre = 'Clinica Medica'),
    @Fecha        = '2026-07-06',
    @Hora         = '08:00',
    @Observaciones = 'Control general';
GO

-- Turno 2: Maria Gomez con Carlos Lopez (Dentista) - Martes 09:00 -> OK
EXEC RegistrarTurno
    @IDPaciente   = (SELECT IDPaciente FROM Pacientes PA INNER JOIN Personas P ON P.IDPersona = PA.IDPersona WHERE P.DNI = '27999888'),
    @IDMedico     = (SELECT IDMedico FROM Medicos WHERE Matricula = 'MAT-1001'),
    @IDEspecialidad = (SELECT IDEspecialidad FROM Especialidades WHERE Nombre = 'Dentista'),
    @Fecha        = '2026-07-07',
    @Hora         = '09:00',
    @Observaciones = 'Revision dental';
GO

-- Turno 3: Sofia Ramirez con Ana Martinez (Pediatria) - Miercoles 10:00 -> OK
EXEC RegistrarTurno
    @IDPaciente   = (SELECT IDPaciente FROM Pacientes PA INNER JOIN Personas P ON P.IDPersona = PA.IDPersona WHERE P.DNI = '35222111'),
    @IDMedico     = (SELECT IDMedico FROM Medicos WHERE Matricula = 'MAT-1002'),
    @IDEspecialidad = (SELECT IDEspecialidad FROM Especialidades WHERE Nombre = 'Pediatria'),
    @Fecha        = '2026-07-08',
    @Hora         = '10:00',
    @Observaciones = 'Control pediatrico';
GO

-- Turno 4: Martin Gutierrez con Roberto Fernandez (Cardiologia) - Viernes 15:00 -> OK
EXEC RegistrarTurno
    @IDPaciente   = (SELECT IDPaciente FROM Pacientes PA INNER JOIN Personas P ON P.IDPersona = PA.IDPersona WHERE P.DNI = '38999000'),
    @IDMedico     = (SELECT IDMedico FROM Medicos WHERE Matricula = 'MAT-1003'),
    @IDEspecialidad = (SELECT IDEspecialidad FROM Especialidades WHERE Nombre = 'Cardiologia'),
    @Fecha        = '2026-07-10',
    @Hora         = '15:00',
    @Observaciones = 'Chequeo cardiologico';
GO

-- Turno 5: Valentina Castro con Lucia Sanchez (Dermatologia) - Lunes 16:00 -> OK
EXEC RegistrarTurno
    @IDPaciente   = (SELECT IDPaciente FROM Pacientes PA INNER JOIN Personas P ON P.IDPersona = PA.IDPersona WHERE P.DNI = '36111444'),
    @IDMedico     = (SELECT IDMedico FROM Medicos WHERE Matricula = 'MAT-1004'),
    @IDEspecialidad = (SELECT IDEspecialidad FROM Especialidades WHERE Nombre = 'Dermatologia'),
    @Fecha        = '2026-07-06',
    @Hora         = '16:00',
    @Observaciones = 'Consulta por lunar';
GO

-- Turno 6 (se reprograma/cancela/diagnostica en la demo):
-- Federico Romero con Diego Torres (Clinica Medica) - Martes 11:00 -> OK
EXEC RegistrarTurno
    @IDPaciente   = (SELECT IDPaciente FROM Pacientes PA INNER JOIN Personas P ON P.IDPersona = PA.IDPersona WHERE P.DNI = '31555222'),
    @IDMedico     = (SELECT IDMedico FROM Medicos WHERE Matricula = 'MAT-1005'),
    @IDEspecialidad = (SELECT IDEspecialidad FROM Especialidades WHERE Nombre = 'Clinica Medica'),
    @Fecha        = '2026-07-07',
    @Hora         = '11:00',
    @Observaciones = 'Primera consulta';
GO

-- DATOS DE PRUEBA DE ERRORES Y VALIDAACIONES 


-- ---------- ERROR 50012: TURNO EN FECHA VENCIDA ----------
BEGIN TRY
    EXEC RegistrarTurno
        @IDPaciente   = (SELECT IDPaciente FROM Pacientes PA INNER JOIN Personas P ON P.IDPersona = PA.IDPersona WHERE P.DNI = '30111222'),
        @IDMedico     = (SELECT IDMedico FROM Medicos WHERE Matricula = 'MAT-1001'),
        @IDEspecialidad = (SELECT IDEspecialidad FROM Especialidades WHERE Nombre = 'Clinica Medica'),
        @Fecha        = '2020-01-01',
        @Hora         = '08:00',
        @Observaciones = 'Turno vencido';
END TRY
BEGIN CATCH
    PRINT '--- ERROR ESPERADO (turno vencido): ' + ERROR_MESSAGE();
END CATCH
GO

-- ---------- ERROR 50017: FUERA DEL HORARIO DEL MEDICO ----------
-- Carlos Lopez solo atiende Lunes y Martes 08-12. Pedimos las 15:00.
BEGIN TRY
    EXEC RegistrarTurno
        @IDPaciente   = (SELECT IDPaciente FROM Pacientes PA INNER JOIN Personas P ON P.IDPersona = PA.IDPersona WHERE P.DNI = '30111222'),
        @IDMedico     = (SELECT IDMedico FROM Medicos WHERE Matricula = 'MAT-1001'),
        @IDEspecialidad = (SELECT IDEspecialidad FROM Especialidades WHERE Nombre = 'Clinica Medica'),
        @Fecha        = '2026-07-06',
        @Hora         = '15:00',
        @Observaciones = 'Horario invalido';
END TRY
BEGIN CATCH
    PRINT '--- ERROR ESPERADO (fuera de horario del medico): ' + ERROR_MESSAGE();
END CATCH
GO

-- ---------- ERROR 50016: MEDICO NO TIENE ESA ESPECIALIDAD ----------
-- Roberto Fernandez es Cardiologo, no Pediatra
BEGIN TRY
    EXEC RegistrarTurno
        @IDPaciente   = (SELECT IDPaciente FROM Pacientes PA INNER JOIN Personas P ON P.IDPersona = PA.IDPersona WHERE P.DNI = '38999000'),
        @IDMedico     = (SELECT IDMedico FROM Medicos WHERE Matricula = 'MAT-1003'),
        @IDEspecialidad = (SELECT IDEspecialidad FROM Especialidades WHERE Nombre = 'Pediatria'),
        @Fecha        = '2026-07-10',
        @Hora         = '15:00',
        @Observaciones = 'Especialidad incorrecta';
END TRY
BEGIN CATCH
    PRINT '--- ERROR ESPERADO (medico sin esa especialidad): ' + ERROR_MESSAGE();
END CATCH
GO

-- ---------- ERROR 50018: MEDICO YA OCUPADO EN ESA FECHA/HORA ----------
-- Carlos Lopez ya tiene el turno 1 (Lunes 06/07 08:00). Intentamos duplicar.
BEGIN TRY
    EXEC RegistrarTurno
        @IDPaciente   = (SELECT IDPaciente FROM Pacientes PA INNER JOIN Personas P ON P.IDPersona = PA.IDPersona WHERE P.DNI = '27999888'),
        @IDMedico     = (SELECT IDMedico FROM Medicos WHERE Matricula = 'MAT-1001'),
        @IDEspecialidad = (SELECT IDEspecialidad FROM Especialidades WHERE Nombre = 'Clinica Medica'),
        @Fecha        = '2026-07-06',
        @Hora         = '08:00',
        @Observaciones = 'Choque de horario medico';
END TRY
BEGIN CATCH
    PRINT '--- ERROR ESPERADO (medico ya ocupado): ' + ERROR_MESSAGE();
END CATCH
GO

-- ---------- ERROR 50019: PACIENTE YA TIENE TURNO EN ESA FECHA/HORA ----------
-- Juan Perez ya tiene el turno 1 (Lunes 06/07 08:00) con Carlos Lopez.
-- Ahora intenta sacar turno con Lucia Sanchez a la MISMA fecha y hora (08:00).
BEGIN TRY
    EXEC RegistrarTurno
        @IDPaciente   = (SELECT IDPaciente FROM Pacientes PA INNER JOIN Personas P ON P.IDPersona = PA.IDPersona WHERE P.DNI = '30111222'),
        @IDMedico     = (SELECT IDMedico FROM Medicos WHERE Matricula = 'MAT-1004'),
        @IDEspecialidad = (SELECT IDEspecialidad FROM Especialidades WHERE Nombre = 'Dermatologia'),
        @Fecha        = '2026-07-06',
        @Hora         = '08:00',
        @Observaciones = 'Ejemplo de choque de paciente';
END TRY
BEGIN CATCH
    PRINT '--- ERROR ESPERADO (paciente ya tiene turno): ' + ERROR_MESSAGE();
END CATCH
GO

-- ---------- ERROR 50011: HORA NO EN PUNTO ----------
BEGIN TRY
    EXEC RegistrarTurno
        @IDPaciente   = (SELECT IDPaciente FROM Pacientes PA INNER JOIN Personas P ON P.IDPersona = PA.IDPersona WHERE P.DNI = '30111222'),
        @IDMedico     = (SELECT IDMedico FROM Medicos WHERE Matricula = 'MAT-1001'),
        @IDEspecialidad = (SELECT IDEspecialidad FROM Especialidades WHERE Nombre = 'Clinica Medica'),
        @Fecha        = '2026-07-13',
        @Hora         = '08:30',
        @Observaciones = 'Hora no permitida, debe ser en punto';
END TRY
BEGIN CATCH
    PRINT '--- ERROR ESPERADO (hora no en punto): ' + ERROR_MESSAGE();
END CATCH
GO

-- ---------- ERROR 50013: PACIENTE INEXISTENTE ----------
BEGIN TRY
    EXEC RegistrarTurno
        @IDPaciente   = 9999,
        @IDMedico     = (SELECT IDMedico FROM Medicos WHERE Matricula = 'MAT-1001'),
        @IDEspecialidad = (SELECT IDEspecialidad FROM Especialidades WHERE Nombre = 'Clinica Medica'),
        @Fecha        = '2026-07-13',
        @Hora         = '08:00',
        @Observaciones = 'Paciente inexistente';
END TRY
BEGIN CATCH
    PRINT '--- ERROR ESPERADO (paciente inexistente): ' + ERROR_MESSAGE();
END CATCH
GO

-- ---------- ERROR 50014: MEDICO INEXISTENTE O INACTIVO ----------
BEGIN TRY
    EXEC RegistrarTurno
        @IDPaciente   = (SELECT IDPaciente FROM Pacientes PA INNER JOIN Personas P ON P.IDPersona = PA.IDPersona WHERE P.DNI = '30111222'),
        @IDMedico     = 9999,
        @IDEspecialidad = (SELECT IDEspecialidad FROM Especialidades WHERE Nombre = 'Clinica Medica'),
        @Fecha        = '2026-07-13',
        @Hora         = '08:00',
        @Observaciones = 'Medico inexistente';
END TRY
BEGIN CATCH
    PRINT '--- ERROR ESPERADO (medico inexistente/inactivo): ' + ERROR_MESSAGE();
END CATCH
GO

-- ---------- DIAGNOSTICO VALIDO SOBRE EL TURNO 2 (caso de exito, sin TRY/CATCH) ----------
EXEC RegistrarDiagnostico
    @IDTurno = 2,
    @Diagnostico = 'Caries leve',
    @Tratamiento = 'Control en 6 meses',
    @Observaciones = 'Paciente sin dolor';
GO

-- ---------- ERROR 50041: DIAGNOSTICO DUPLICADO PARA EL MISMO TURNO ----------
-- Intentamos registrar OTRO diagnostico sobre el turno 2, que ya tiene uno.
BEGIN TRY
    EXEC RegistrarDiagnostico
        @IDTurno = 2,
        @Diagnostico = 'Intento de diagnostico duplicado',
        @Tratamiento = 'N/A',
        @Observaciones = 'Esto debe fallar';
END TRY
BEGIN CATCH
    PRINT '--- ERROR ESPERADO (diagnostico duplicado): ' + ERROR_MESSAGE();
END CATCH
GO

-- ---------- ERROR 50042: DIAGNOSTICO VACIO ----------
BEGIN TRY
    EXEC RegistrarDiagnostico
        @IDTurno = 3,
        @Diagnostico = '',
        @Tratamiento = 'Ninguno',
        @Observaciones = 'Sin diagnostico';
END TRY
BEGIN CATCH
    PRINT '--- ERROR ESPERADO (diagnostico vacio): ' + ERROR_MESSAGE();
END CATCH
GO

-- ---------- ERROR 50043: DIAGNOSTICO SOBRE TURNO CANCELADO ----------
-- Cancelamos el turno 6 y luego intentamos registrarle un diagnostico
EXEC CancelarTurno @IDTurno = 6;
GO

BEGIN TRY
    EXEC RegistrarDiagnostico
        @IDTurno = 6,
        @Diagnostico = 'No deberia poder registrarse',
        @Tratamiento = 'N/A',
        @Observaciones = 'Turno cancelado';
END TRY
BEGIN CATCH
    PRINT '--- ERROR ESPERADO (diagnostico sobre turno cancelado): ' + ERROR_MESSAGE();
END CATCH
GO

-- ---------- ERROR 50023: REPROGRAMAR FUERA DE HORARIO ----------
-- Roberto Fernandez solo atiende Viernes 14-18; probamos las 20:00.
BEGIN TRY
    EXEC ReprogramarTurno
        @IDTurno = 4,
        @NuevaFecha = '2026-07-10',
        @NuevaHora  = '20:00';
END TRY
BEGIN CATCH
    PRINT '--- ERROR ESPERADO (reprogramar fuera de horario): ' + ERROR_MESSAGE();
END CATCH
GO

-- ---------- ERROR 50024: REPROGRAMAR A UN HORARIO YA OCUPADO DEL MEDICO ----------
-- Carlos Lopez ya tiene ocupado 2026-07-07 09:00 (turno 2). Intentamos
-- reprogramar el turno 1 (mismo medico) a ese horario.
BEGIN TRY
    EXEC ReprogramarTurno
        @IDTurno = 1,
        @NuevaFecha = '2026-07-07',
        @NuevaHora  = '09:00';
END TRY
BEGIN CATCH
    PRINT '--- ERROR ESPERADO (reprogramar a horario ya ocupado): ' + ERROR_MESSAGE();
END CATCH
GO


-- CASOS EXITOSOS DE REPROGRAMAR / CANCELAR (sin TRY/CATCH: estos SI deben terminar en COMMIT)
   
-- Reprogramar el turno 5 (Valentina Castro / Lucia Sanchez) a otro Lunes
EXEC ReprogramarTurno
    @IDTurno = 5,
    @NuevaFecha = '2026-07-13',
    @NuevaHora  = '17:00';
GO

-- Cancelar el turno 3 (Sofia Ramirez / Ana Martinez)
EXEC CancelarTurno @IDTurno = 3;
GO

-- Registrar diagnostico exitoso sobre el turno 4 (Martin Gutierrez / Roberto Fernandez)
EXEC RegistrarDiagnostico
    @IDTurno = 4,
    @Diagnostico = 'Soplo cardiaco leve, requiere seguimiento',
    @Tratamiento = 'Ecocardiograma de control en 3 meses',
    @Observaciones = 'Paciente asintomatico';
GO


-- VERIFICACIONES 

SELECT * FROM MedicosEspecialidades ORDER BY Especialidad;
GO

SELECT * FROM TurnosDelDia;  
GO

SELECT * FROM HistorialPaciente ORDER BY FechaRegistro DESC;
GO

SELECT T.IDTurno, T.Fecha, T.Hora, ET.Nombre AS Estado, P.Nombres, P.Apellidos
FROM Turnos T
INNER JOIN EstadoTurno ET ON ET.IDEstadoTurno = T.IDEstadoTurno
INNER JOIN Pacientes PA ON PA.IDPaciente = T.IDPaciente
INNER JOIN Personas P ON P.IDPersona = PA.IDPersona
ORDER BY T.Fecha, T.Hora;
GO


-- ULTIMO PASO: TRIGGER INSTEAD OF DELETE

BEGIN TRY
    DELETE FROM Turnos WHERE IDTurno = 1;
END TRY
BEGIN CATCH
    PRINT '--- ERROR ESPERADO (no se pueden eliminar turnos): ' + ERROR_MESSAGE();
END CATCH
GO
