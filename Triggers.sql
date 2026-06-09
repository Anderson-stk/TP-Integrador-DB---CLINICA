use ClinicaDDBB
go

CREATE OR ALTER TRIGGER TurnosValidar ON Turnos
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    SET DATEFIRST 1;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN deleted d ON d.IDTurno = i.IDTurno
        WHERE (d.IDTurno IS NULL
               OR i.Fecha <> d.Fecha
               OR i.Hora <> d.Hora
               OR i.IDMedico <> d.IDMedico
               OR i.IDPaciente <> d.IDPaciente
               OR i.IDEspecialidad <> d.IDEspecialidad)
          AND DATEADD(MINUTE, DATEDIFF(MINUTE, 0, i.Hora), CAST(i.Fecha AS DATETIME2)) < SYSDATETIME()
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, 'No se pueden cargar o reprogramar turnos vencidos.', 1;
    END

    IF EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN deleted d ON d.IDTurno = i.IDTurno
        WHERE (d.IDTurno IS NULL
               OR i.Fecha <> d.Fecha
               OR i.Hora <> d.Hora
               OR i.IDMedico <> d.IDMedico)
          AND NOT EXISTS (
                SELECT 1
                FROM HorariosMedicos HM
                WHERE HM.IDMedico = i.IDMedico
                  AND HM.DiaSemana = DATEPART(WEEKDAY, i.Fecha)
                  AND i.Hora >= HM.HoraInicio
                  AND i.Hora < HM.HoraFin
          )
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50002, 'El medico no tiene disponibilidad para la fecha y hora seleccionadas.', 1;
    END

    IF EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN deleted d ON d.IDTurno = i.IDTurno
        WHERE (d.IDTurno IS NULL
               OR i.IDMedico <> d.IDMedico
               OR i.IDEspecialidad <> d.IDEspecialidad)
          AND NOT EXISTS (
                SELECT 1
                FROM MedicoEspecialidad ME
                WHERE ME.IDMedico = i.IDMedico
                  AND ME.IDEspecialidad = i.IDEspecialidad
          )
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50003, 'El medico no esta asociado a la especialidad seleccionada.', 1;
    END

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.Turnos T
            ON T.IDMedico = i.IDMedico
           AND T.Fecha = i.Fecha
           AND T.Hora = i.Hora
           AND T.IDTurno <> i.IDTurno
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50004, 'Ya existe un turno para ese medico en la misma fecha y hora.', 1;
    END

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.Turnos T
            ON T.IDPaciente = i.IDPaciente
           AND T.Fecha = i.Fecha
           AND T.Hora = i.Hora
           AND T.IDTurno <> i.IDTurno
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50005, 'Ya existe un turno para ese paciente en la misma fecha y hora.', 1;
    END
END;
GO

CREATE OR ALTER TRIGGER TurnosNoEliminados ON Turnos
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    THROW 50006, 'Los turnos no pueden eliminarse. Solo pueden reprogramarse o cancelarse.', 1;
END;
GO
