use ClinicaDDBB
go

CREATE OR ALTER VIEW MedicosEspecialidades AS SELECT
    M.IDMedico,
    P.Nombres,
    P.Apellidos,
    P.DNI,
    P.Email,
    P.Telefono,
    M.Matricula,
    M.Activo,
    E.IDEspecialidad,
    E.Nombre AS Especialidad FROM dbo.Medicos M
INNER JOIN Personas P ON P.IDPersona = M.IDPersona
INNER JOIN MedicoEspecialidad ME ON ME.IDMedico = M.IDMedico
INNER JOIN Especialidades E ON E.IDEspecialidad = ME.IDEspecialidad;
GO

CREATE OR ALTER VIEW TurnosDelDia AS SELECT
    T.IDTurno,
    T.Fecha,
    T.Hora,
    ET.Nombre AS EstadoTurno,
    PP.Nombres AS PacienteNombres,
    PP.Apellidos AS PacienteApellidos,
    PP.DNI AS PacienteDNI,
    PP.Email AS PacienteEmail,
    MP.Nombres AS MedicoNombres,
    MP.Apellidos AS MedicoApellidos,
    M.Matricula,
    E.Nombre AS Especialidad,
    T.Observaciones,
    T.FechaAlta FROM Turnos T
INNER JOIN EstadoTurno ET ON ET.IDEstadoTurno = T.IDEstadoTurno
INNER JOIN Pacientes PA ON PA.IDPaciente = T.IDPaciente
INNER JOIN Personas PP ON PP.IDPersona = PA.IDPersona
INNER JOIN Medicos M ON M.IDMedico = T.IDMedico
INNER JOIN Personas MP ON MP.IDPersona = M.IDPersona
INNER JOIN Especialidades E ON E.IDEspecialidad = T.IDEspecialidad
WHERE T.Fecha = CAST(GETDATE() AS DATE);
GO

CREATE OR ALTER VIEW HistorialPaciente AS SELECT
    HC.IDHistoriaClinica,
    HC.FechaRegistro,
    PP.Nombres AS PacienteNombres,
    PP.Apellidos AS PacienteApellidos,
    PP.DNI AS PacienteDNI,
    MP.Nombres AS MedicoNombres,
    MP.Apellidos AS MedicoApellidos,
    M.Matricula,
    E.Nombre AS Especialidad,
    T.Fecha AS FechaTurno,
    T.Hora AS HoraTurno,
    HC.Diagnostico,
    HC.Tratamiento,
    HC.Observaciones
FROM dbo.HistoriaClinica HC
INNER JOIN Pacientes PA ON PA.IDPaciente = HC.IDPaciente
INNER JOIN Personas PP ON PP.IDPersona = PA.IDPersona
INNER JOIN Medicos M ON M.IDMedico = HC.IDMedico
INNER JOIN Personas MP ON MP.IDPersona = M.IDPersona
LEFT JOIN Turnos T ON T.IDTurno = HC.IDTurno
LEFT JOIN Especialidades E ON E.IDEspecialidad = T.IDEspecialidad;
GO