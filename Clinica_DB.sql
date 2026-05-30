CREATE DATABASE Clinica_DB;
GO

USE Clinica_DB;
GO

CREATE TABLE Roles (
    IDRol INT IDENTITY(1,1) NOT NULL,
    Nombre VARCHAR(50) NOT NULL,

    CONSTRAINT PK_Roles PRIMARY KEY (IDRol),
    CONSTRAINT UQ_Roles_Nombre UNIQUE (Nombre)
);
GO

CREATE TABLE Usuarios (
    IDUsuario INT IDENTITY(1,1) NOT NULL,
    Username VARCHAR(50) NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    IDRol INT NOT NULL,

    CONSTRAINT PK_Usuarios PRIMARY KEY (IDUsuario),
    CONSTRAINT UQ_Usuarios_Username UNIQUE (Username),
    CONSTRAINT FK_Usuarios_Roles FOREIGN KEY (IDRol)
        REFERENCES Roles (IDRol)
);
GO

CREATE TABLE Especialidades (
    IDEspecialidad INT IDENTITY(1,1) NOT NULL,
    Nombre VARCHAR(150) NOT NULL,
    Descripcion VARCHAR(255) NULL,

    CONSTRAINT PK_Especialidades PRIMARY KEY (IDEspecialidad),
    CONSTRAINT UQ_Especialidades_Nombre UNIQUE (Nombre)
);
GO

CREATE TABLE Pacientes (
    IDPaciente INT IDENTITY(1,1) NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    Apellido VARCHAR(50) NOT NULL,
    FechaNacimiento DATE NULL,
    DNI VARCHAR(20) NOT NULL,
    Email VARCHAR(150) NOT NULL,
    Telefono VARCHAR(30) NULL,
    Direccion VARCHAR(255) NULL,

    CONSTRAINT PK_Pacientes PRIMARY KEY (IDPaciente),
    CONSTRAINT UQ_Pacientes_DNI UNIQUE (DNI)
);
GO

CREATE TABLE Medicos (
    IDMedico INT IDENTITY(1,1) NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    Apellido VARCHAR(50) NOT NULL,
    Matricula VARCHAR(150) NOT NULL,
    Activo BIT NOT NULL CONSTRAINT DF_Medicos_Activo DEFAULT (1),
    IDUsuario INT NULL,

    CONSTRAINT PK_Medicos PRIMARY KEY (IDMedico),
    CONSTRAINT UQ_Medicos_Matricula UNIQUE (Matricula),
    CONSTRAINT UQ_Medicos_IDUsuario UNIQUE (IDUsuario),
    CONSTRAINT FK_Medicos_Usuarios FOREIGN KEY (IDUsuario)
        REFERENCES Usuarios (IDUsuario)
);
GO

CREATE TABLE MedicoEspecialidad (
    ID INT IDENTITY(1,1) NOT NULL,
    IDMedico INT NOT NULL,
    IDEspecialidad INT NOT NULL,

    CONSTRAINT PK_MedicoEspecialidad PRIMARY KEY (ID),
    CONSTRAINT UQ_MedicoEspecialidad UNIQUE (IDMedico, IDEspecialidad),
    CONSTRAINT FK_MedicoEspecialidad_Medicos FOREIGN KEY (IDMedico)
        REFERENCES Medicos (IDMedico),
    CONSTRAINT FK_MedicoEspecialidad_Especialidades FOREIGN KEY (IDEspecialidad)
        REFERENCES Especialidades (IDEspecialidad)
);
GO

CREATE TABLE EstadoTurno (
    IDEstadoTurno INT IDENTITY(1,1) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,

    CONSTRAINT PK_EstadoTurno PRIMARY KEY (IDEstadoTurno),
    CONSTRAINT UQ_EstadoTurno_Nombre UNIQUE (Nombre)
);
GO

CREATE TABLE HorariosMedicos (
    IDHorario INT IDENTITY(1,1) NOT NULL,
    IDMedico INT NOT NULL,
    DiaSemana TINYINT NOT NULL,
    HoraInicio TIME NOT NULL,
    HoraFin TIME NOT NULL,

    CONSTRAINT PK_HorariosMedicos PRIMARY KEY (IDHorario),
    CONSTRAINT FK_HorariosMedicos_Medicos FOREIGN KEY (IDMedico)
        REFERENCES Medicos (IDMedico),
    CONSTRAINT CK_HorariosMedicos_DiaSemana CHECK (DiaSemana BETWEEN 1 AND 7),
    CONSTRAINT CK_HorariosMedicos_Horas CHECK (HoraFin > HoraInicio)
);
GO

CREATE TABLE Turnos (
    IDTurno INT IDENTITY(1,1) NOT NULL,
    IDPaciente INT NOT NULL,
    IDMedico INT NOT NULL,
    IDEstadoTurno INT NOT NULL,
    Fecha DATE NOT NULL,
    Hora TIME NOT NULL,
    Observaciones VARCHAR(255) NULL,
    FechaAlta DATETIME2 NOT NULL CONSTRAINT DF_Turnos_FechaAlta DEFAULT (SYSDATETIME()),

    CONSTRAINT PK_Turnos PRIMARY KEY (IDTurno),
    CONSTRAINT FK_Turnos_Pacientes FOREIGN KEY (IDPaciente)
        REFERENCES Pacientes (IDPaciente),
    CONSTRAINT FK_Turnos_Medicos FOREIGN KEY (IDMedico)
        REFERENCES Medicos (IDMedico),
    CONSTRAINT FK_Turnos_EstadoTurno FOREIGN KEY (IDEstadoTurno)
        REFERENCES EstadoTurno (IDEstadoTurno),

    CONSTRAINT UQ_Turnos_Medico_Fecha_Hora UNIQUE (IDMedico, Fecha, Hora),
    CONSTRAINT UQ_Turnos_Paciente_Fecha_Hora UNIQUE (IDPaciente, Fecha, Hora)
);
GO

CREATE TABLE HistoriaClinica (
    IDHistoriaClinica INT IDENTITY(1,1) NOT NULL,
    IDPaciente INT NOT NULL,
    IDMedico INT NOT NULL,
    IDTurno INT NULL,
    Fecha DATE NOT NULL CONSTRAINT DF_HistoriaClinica_Fecha DEFAULT (CAST(GETDATE() AS DATE)),
    Diagnostico VARCHAR(200) NULL,
    Tratamiento VARCHAR(255) NULL,
    Observaciones VARCHAR(255) NULL,

    CONSTRAINT PK_HistoriaClinica PRIMARY KEY (IDHistoriaClinica),
    CONSTRAINT UQ_HistoriaClinica_IDTurno UNIQUE (IDTurno),
    CONSTRAINT FK_HistoriaClinica_Pacientes FOREIGN KEY (IDPaciente)
        REFERENCES Pacientes (IDPaciente),
    CONSTRAINT FK_HistoriaClinica_Medicos FOREIGN KEY (IDMedico)
        REFERENCES Medicos (IDMedico),
    CONSTRAINT FK_HistoriaClinica_Turnos FOREIGN KEY (IDTurno)
        REFERENCES Turnos (IDTurno)
);
GO

CREATE TRIGGER TR_Turnos_NoVencidos
ON Turnos
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE DATEADD(MINUTE, DATEDIFF(MINUTE, 0, i.Hora), CAST(i.Fecha AS DATETIME2)) < SYSDATETIME()
    )
    BEGIN
        RAISERROR('No se pueden cargar turnos vencidos.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

CREATE TRIGGER TR_Turnos_NoDelete
ON Turnos
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('Los turnos no pueden eliminarse. Solo se pueden cancelar o reprogramar.', 16, 1);
END;
GO

INSERT INTO Roles (Nombre) VALUES
('Administrador'),
('Recepcionista'),
('Medico');
GO

INSERT INTO EstadoTurno (Nombre) VALUES
('Nuevo'),
('Reprogramado'),
('Cancelado'),
('No Asistio'),
('Cerrado');
GO