use ClinicaDDBB
go

CREATE OR ALTER PROCEDURE RegistrarTurno
    @IDPaciente INT,
    @IDMedico INT,
    @IDEspecialidad INT,
    @Fecha DATE,
    @Hora TIME,
    @Observaciones VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET DATEFIRST 1;

    BEGIN TRY
        BEGIN TRAN;

        IF @IDPaciente IS NULL OR @IDMedico IS NULL OR @IDEspecialidad IS NULL OR @Fecha IS NULL OR @Hora IS NULL
            THROW 50010, 'Debe completar todos los datos obligatorios del turno.', 1;

        IF DATEPART(MINUTE, @Hora) <> 0 OR DATEPART(SECOND, @Hora) <> 0
            THROW 50011, 'Los turnos deben cargarse en horas completas.', 1;

        IF DATEADD(MINUTE, DATEDIFF(MINUTE, 0, @Hora), CAST(@Fecha AS DATETIME2)) < SYSDATETIME()
            THROW 50012, 'No se pueden registrar turnos vencidos.', 1;

        IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE IDPaciente = @IDPaciente)
            THROW 50013, 'El paciente no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM Medicos WHERE IDMedico = @IDMedico AND Activo = 1)
            THROW 50014, 'El medico no existe o se encuentra inactivo.', 1;

        IF NOT EXISTS (SELECT 1 FROM Especialidades WHERE IDEspecialidad = @IDEspecialidad AND Activo = 1)
            THROW 50015, 'La especialidad no existe o se encuentra inactiva.', 1;

        IF NOT EXISTS (
            SELECT 1
            FROM MedicoEspecialidad
            WHERE IDMedico = @IDMedico
              AND IDEspecialidad = @IDEspecialidad
        )
            THROW 50016, 'El medico no esta asociado a la especialidad seleccionada.', 1;

        IF NOT EXISTS (
            SELECT 1
            FROM HorariosMedicos HM
            WHERE HM.IDMedico = @IDMedico
              AND HM.DiaSemana = DATEPART(WEEKDAY, @Fecha)ok
              AND @Hora >= HM.HoraInicio
              AND @Hora < HM.HoraFin
        )
            THROW 50017, 'El medico no tiene disponibilidad en la fecha y hora seleccionadas.', 1;

        IF EXISTS (
            SELECT 1
            FROM Turnos
            WHERE IDMedico = @IDMedico
              AND Fecha = @Fecha
              AND Hora = @Hora
        )
            THROW 50018, 'Ya existe un turno para ese medico en la misma fecha y hora.', 1;

        IF EXISTS (
            SELECT 1
            FROM Turnos
            WHERE IDPaciente = @IDPaciente
              AND Fecha = @Fecha
              AND Hora = @Hora
        )
            THROW 50019, 'Ya existe un turno para ese paciente en la misma fecha y hora.', 1;

        DECLARE @IDEstadoNuevo INT;

        SELECT @IDEstadoNuevo = IDEstadoTurno
        FROM EstadoTurno
        WHERE Nombre = 'Nuevo';

        IF @IDEstadoNuevo IS NULL
            THROW 50026, 'No existe el estado Nuevo.', 1;

        INSERT INTO Turnos (
            IDPaciente,
            IDMedico,
            IDEspecialidad,
            IDEstadoTurno,
            Fecha,
            Hora,
            Observaciones
        )
        VALUES (
            @IDPaciente,
            @IDMedico,
            @IDEspecialidad,
            @IDEstadoNuevo,
            @Fecha,
            @Hora,
            @Observaciones
        );

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE ReprogramarTurno
    @IDTurno INT,
    @NuevaFecha DATE,
    @NuevaHora TIME
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET DATEFIRST 1;

    BEGIN TRY
        BEGIN TRAN;

        DECLARE
            @IDPaciente INT,
            @IDMedico INT,
            @IDEspecialidad INT,
            @IDEstadoReprogramado INT;

        IF NOT EXISTS (SELECT 1 FROM Turnos WHERE IDTurno = @IDTurno)
            THROW 50020, 'El turno no existe.', 1;

        IF DATEPART(MINUTE, @NuevaHora) <> 0 OR DATEPART(SECOND, @NuevaHora) <> 0
            THROW 50021, 'Los turnos deben reprogramarse en horas completas.', 1;

        IF DATEADD(MINUTE, DATEDIFF(MINUTE, 0, @NuevaHora), CAST(@NuevaFecha AS DATETIME2)) < SYSDATETIME()
            THROW 50022, 'No se pueden reprogramar turnos a una fecha y hora vencidas.', 1;

        SELECT
            @IDPaciente = IDPaciente,
            @IDMedico = IDMedico,
            @IDEspecialidad = IDEspecialidad
        FROM Turnos
        WHERE IDTurno = @IDTurno;

        IF NOT EXISTS (
            SELECT 1
            FROM HorariosMedicos HM
            WHERE HM.IDMedico = @IDMedico
              AND HM.DiaSemana = DATEPART(WEEKDAY, @NuevaFecha)
              AND @NuevaHora >= HM.HoraInicio
              AND @NuevaHora < HM.HoraFin
        )
            THROW 50023, 'El medico no tiene disponibilidad en la nueva fecha y hora.', 1;

        IF EXISTS (
            SELECT 1
            FROM Turnos
            WHERE IDTurno <> @IDTurno
              AND IDMedico = @IDMedico
              AND Fecha = @NuevaFecha
              AND Hora = @NuevaHora
        )
            THROW 50024, 'Ya existe un turno para ese medico en la nueva fecha y hora.', 1;

        IF EXISTS (
            SELECT 1
            FROM Turnos
            WHERE IDTurno <> @IDTurno
              AND IDPaciente = @IDPaciente
              AND Fecha = @NuevaFecha
              AND Hora = @NuevaHora
        )
            THROW 50025, 'Ya existe un turno para ese paciente en la nueva fecha y hora.', 1;

        SELECT @IDEstadoReprogramado = IDEstadoTurno
        FROM EstadoTurno
        WHERE Nombre = 'Reprogramado';

        IF @IDEstadoReprogramado IS NULL
            THROW 50027, 'No existe el estado Reprogramado.', 1;

        UPDATE Turnos
        SET Fecha = @NuevaFecha,
            Hora = @NuevaHora,
            IDEstadoTurno = @IDEstadoReprogramado
        WHERE IDTurno = @IDTurno;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE CancelarTurno
    @IDTurno INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        DECLARE @IDEstadoCancelado INT;

        IF NOT EXISTS (SELECT 1 FROM Turnos WHERE IDTurno = @IDTurno)
            THROW 50030, 'El turno no existe.', 1;

        SELECT @IDEstadoCancelado = IDEstadoTurno
        FROM EstadoTurno
        WHERE Nombre = 'Cancelado';

        IF @IDEstadoCancelado IS NULL
            THROW 50031, 'No existe el estado Cancelado.', 1;

        UPDATE Turnos
        SET IDEstadoTurno = @IDEstadoCancelado
        WHERE IDTurno = @IDTurno;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE RegistrarDiagnostico
    @IDTurno INT,
    @Diagnostico VARCHAR(200),
    @Tratamiento VARCHAR(255) = NULL,
    @Observaciones VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        DECLARE
            @IDPaciente INT,
            @IDMedico INT,
            @IDEstadoCerrado INT;

        IF NOT EXISTS (SELECT 1 FROM Turnos WHERE IDTurno = @IDTurno)
            THROW 50040, 'El turno no existe.', 1;

        IF EXISTS (SELECT 1 FROM HistoriaClinica WHERE IDTurno = @IDTurno)
            THROW 50041, 'Ya existe un registro de historia clinica para este turno.', 1;

        IF @Diagnostico IS NULL OR LTRIM(RTRIM(@Diagnostico)) = ''
            THROW 50042, 'Debe ingresar un diagnostico.', 1;

        IF EXISTS (
            SELECT 1
            FROM Turnos T
            INNER JOIN EstadoTurno ET
                ON ET.IDEstadoTurno = T.IDEstadoTurno
            WHERE T.IDTurno = @IDTurno
              AND ET.Nombre = 'Cancelado'
        )
            THROW 50043, 'No se puede registrar diagnostico para un turno cancelado.', 1;

        SELECT
            @IDPaciente = IDPaciente,
            @IDMedico = IDMedico
        FROM Turnos
        WHERE IDTurno = @IDTurno;

        SELECT @IDEstadoCerrado = IDEstadoTurno
        FROM EstadoTurno
        WHERE Nombre = 'Cerrado';

        IF @IDEstadoCerrado IS NULL
            THROW 50044, 'No existe el estado Cerrado.', 1;

        INSERT INTO HistoriaClinica (
            IDPaciente,
            IDMedico,
            IDTurno,
            Diagnostico,
            Tratamiento,
            Observaciones
        )
        VALUES (
            @IDPaciente,
            @IDMedico,
            @IDTurno,
            @Diagnostico,
            @Tratamiento,
            @Observaciones
        );

        UPDATE Turnos
        SET IDEstadoTurno = @IDEstadoCerrado
        WHERE IDTurno = @IDTurno;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO