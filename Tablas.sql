USE master
GO

Create DATABASE ClinicaDDBB
GO

use ClinicaDDBB;
GO

CREATE TABLE Roles (
	IDRol INT IDENTITY(1,1) PRIMARY KEY,
	Nombre VARCHAR(50) NOT NULL UNIQUE
);
GO

CREATE TABLE Personas (
	IDPersona INT IDENTITY(1,1) PRIMARY KEY,
	Nombres VARCHAR(80) NOT NULL,
	Apellidos VARCHAR(80) NOT NULL,
	DNI VARCHAR(20) NOT NULL UNIQUE,
	FechaNacimiento DATE NULL,
	Email VARCHAR(150) NOT NULL UNIQUE,
	Telefono VARCHAR(30) NULL,
	Direccion VARCHAR(255) NULL,

	CONSTRAINT CK_Personas_Email CHECK (Email LIKE '%_@_%._%')
);
GO

CREATE TABLE Usuarios (
	IDUsuario INT IDENTITY(1,1) PRIMARY KEY,
	IDPersona INT NOT NULL UNIQUE,
	Username VARCHAR(50) NOT NULL UNIQUE,
	PasswordHash VARCHAR(255) NOT NULL,
	IDRol INT NOT NULL,
	Activo BIT NOT NULL DEFAULT(1),

	CONSTRAINT FK_Usuarios_Personas FOREIGN KEY (IDPersona) REFERENCES Personas(IDPersona),
	CONSTRAINT FK_Usuarios_Roles FOREIGN KEY (IDRol) REFERENCES Roles(IDRol)
);
GO

CREATE TABLE Especialidades (
	IDEspecialidad INT IDENTITY(1,1) PRIMARY KEY,
	Nombre VARCHAR(150) NOT NULL UNIQUE,
	Descripcion VARCHAR(150) NULL,
	Activo BIT NOT NULL DEFAULT(1)
);
GO

CREATE TABLE Pacientes (
	IDPaciente INT IDENTITY(1,1) PRIMARY KEY,
	IDPersona INT NOT NULL UNIQUE,
	ObraSocial VARCHAR(100) NULL,
	GrupoSanguineo VARCHAR(5) NULL,
	Alergias VARCHAR(255) NULL,
	TelefonoEmergencia VARCHAR(30) NULL,

	CONSTRAINT FK_Pacientes_Personas FOREIGN KEY (IDPersona) REFERENCES Personas(IDPersona)
);
GO

CREATE TABLE Medicos (
	IDMedico INT IDENTITY(1,1) PRIMARY KEY,
	IDPersona INT NOT NULL UNIQUE,
	Matricula VARCHAR(150) NOT NULL UNIQUE,
	Activo BIT NOT NULL DEFAULT(1),

	CONSTRAINT FK_Medicos_Personas FOREIGN KEY (IDPersona)REFERENCES Personas(IDPersona)
);
GO

CREATE TABLE MedicoEspecialidad (
	IDMedicoEspecialidad INT IDENTITY(1,1) PRIMARY KEY,
	IDMedico INT NOT NULL,
	IDEspecialidad INT NOT NULL,

	CONSTRAINT FK_MedicoEspecialidad_Medicos FOREIGN KEY (IDMedico) REFERENCES Medicos(IDMedico),
	CONSTRAINT FK_MedicoEspecialidad_Especialidades FOREIGN KEY (IDEspecialidad) REFERENCES Especialidades(IDEspecialidad),
	CONSTRAINT UQ_MedicoEspecialidad UNIQUE (IDMedico, IDEspecialidad)
);
GO

CREATE TABLE EstadoTurno (
	IDEstadoTurno INT IDENTITY(1,1) PRIMARY KEY,
	Nombre VARCHAR(100) NOT NULL UNIQUE
);
GO

CREATE TABLE HorariosMedicos (
	IDHorario INT IDENTITY(1,1) PRIMARY KEY,
	IDMedico INT NOT NULL,
	DiaSemana TINYINT NOT NULL,
	HoraInicio TIME NOT NULL,
	HoraFin TIME NOT NULL,

	CONSTRAINT FK_HorariosMedicos_Medicos FOREIGN KEY (IDMedico) REFERENCES Medicos(IDMedico),
	CONSTRAINT CK_HorariosMedicos_DiaSemana CHECK (DiaSemana BETWEEN 1 AND 7),
	CONSTRAINT CK_HorariosMedicos_Horas CHECK (HoraFin > HoraInicio),
	CONSTRAINT CK_HorariosMedicos_HorasCompletas 
		CHECK (
			DATEPART(MINUTE, HoraInicio) = 0
			AND DATEPART(SECOND, HoraInicio) = 0
			AND DATEPART(MINUTE, HoraFin) = 0
			AND DATEPART(SECOND, HoraFin) = 0
		)
);
GO

CREATE TABLE Turnos (
	IDTurno INT IDENTITY(1,1) PRIMARY KEY,
	IDPaciente INT NOT NULL,
	IDMedico INT NOT NULL,
	IDEspecialidad INT NOT NULL,
	IDEstadoTurno INT NOT NULL,
	Fecha DATE NOT NULL,
	Hora TIME NOT NULL,
	Observaciones VARCHAR(255) NULL,
	FechaAlta DATETIME2 NOT NULL DEFAULT (SYSDATETIME()),

	CONSTRAINT FK_Turnos_Pacientes FOREIGN KEY (IDPaciente) REFERENCES Pacientes(IDPaciente),
	CONSTRAINT FK_Turnos_Medicos FOREIGN KEY (IDMedico) REFERENCES Medicos(IDMedico),
	CONSTRAINT FK_Turnos_Especialidades FOREIGN KEY (IDEspecialidad) REFERENCES Especialidades(IDEspecialidad),
	CONSTRAINT FK_Turnos_EstadoTurno FOREIGN KEY (IDEstadoTurno) REFERENCES EstadoTurno(IDEstadoTurno),
	CONSTRAINT UQ_Turnos_Medico_Fecha_Hora UNIQUE (IDMedico, Fecha, Hora),
	CONSTRAINT UQ_Turnos_Paciente_Fecha_Hora UNIQUE (IDPaciente, Fecha, Hora),
	CONSTRAINT CK_Turnos_HoraEnPunto CHECK (DATEPART(MINUTE, Hora) = 0 AND DATEPART(SECOND, Hora) = 0)
);
GO

CREATE TABLE HistoriaClinica (
	IDHistoriaClinica INT IDENTITY(1,1) PRIMARY KEY,
	IDPaciente INT NOT NULL,
	IDMedico INT NOT NULL,
	IDTurno INT NOT NULL UNIQUE,
	FechaRegistro DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),
	Diagnostico VARCHAR(200) NULL,
	Tratamiento VARCHAR(255) NULL,
	Observaciones VARCHAR(255) NULL,

	CONSTRAINT FK_HistoriaClinica_Pacientes FOREIGN KEY (IDPaciente) REFERENCES Pacientes(IDPaciente),
	CONSTRAINT FK_HistoriaClinica_Medicos FOREIGN KEY (IDMedico) REFERENCES Medicos(IDMedico),
	CONSTRAINT FK_HistoriaClinica_Turnos FOREIGN KEY (IDTurno) REFERENCES Turnos(IDTurno)
);
