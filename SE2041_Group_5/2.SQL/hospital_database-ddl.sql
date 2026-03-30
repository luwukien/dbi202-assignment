/*
    Hospital Management Database - SQL Server Script
    Generated from the provided logical schema and business constraints.

    Main assumptions to make the script consistent and executable:
    1. All *_id columns use INT IDENTITY PRIMARY KEY.
    2. doctor_id references Staff(staff_id). In business terms, doctors are staff members.
    3. The uploaded schema separates invoice details into:
       - Invoice_Service_Detail
       - Invoice_Medicine_Detail
       - Invoice_Bed_Detail
       Therefore the "medicine OR service" check on a single Invoice_Detail row is not needed here.
    4. Admission status is normalized to: 'Admitted', 'Discharged', 'In-patient', 'Pending_Payment'
       exactly as requested, even though 'Pending_Payment' is more about payment than admission lifecycle.
*/

USE master;
GO

IF DB_ID('HospitalManagementDB') IS NOT NULL
BEGIN
    ALTER DATABASE HospitalManagementDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HospitalManagementDB;
END;
GO

CREATE DATABASE HospitalManagementDB;
GO

USE HospitalManagementDB;
GO

/* =========================
   1. MASTER / LOOKUP TABLES
   ========================= */

CREATE TABLE Department (
    department_id     INT IDENTITY(1,1) PRIMARY KEY,
    department_name   NVARCHAR(200) NOT NULL,
    description       NVARCHAR(MAX) NULL,
    phone             VARCHAR(20) NULL,
    CONSTRAINT UQ_Department_department_name UNIQUE (department_name)
);
GO

CREATE TABLE Role (
    role_id           INT IDENTITY(1,1) PRIMARY KEY,
    role_name         VARCHAR(100) NOT NULL,
    description       NVARCHAR(MAX) NULL,
    CONSTRAINT UQ_Role_role_name UNIQUE (role_name)
);
GO

CREATE TABLE Room_Category (
    category_id       INT IDENTITY(1,1) PRIMARY KEY,
    type_name         VARCHAR(100) NOT NULL,
    capacity          INT NOT NULL,
    CONSTRAINT UQ_Room_Category_type_name UNIQUE (type_name),
    CONSTRAINT CHK_Room_Category_capacity CHECK (capacity > 0)
);
GO

CREATE TABLE Service (
    service_id        INT IDENTITY(1,1) PRIMARY KEY,
    service_name      NVARCHAR(200) NOT NULL,
    description       NVARCHAR(MAX) NULL,
    price             DECIMAL(18,2) NOT NULL,
    CONSTRAINT UQ_Service_service_name UNIQUE (service_name),
    CONSTRAINT CHK_Service_price CHECK (price > 0)
);
GO

CREATE TABLE Medicine (
    medicine_id       INT IDENTITY(1,1) PRIMARY KEY,
    medicine_name     NVARCHAR(200) NOT NULL,
    price             DECIMAL(18,2) NOT NULL,
    category          VARCHAR(100) NULL,
    unit              VARCHAR(50) NOT NULL,
    stock_quantity    INT NOT NULL,
    expiry_date       DATE NOT NULL,
    CONSTRAINT UQ_Medicine_medicine_name UNIQUE (medicine_name),
    CONSTRAINT CHK_Medicine_price CHECK (price > 0),
    CONSTRAINT CHK_Medicine_stock_quantity CHECK (stock_quantity >= 0)
);
GO

/* =========================
   2. CORE TABLES
   ========================= */

CREATE TABLE Patient (
    patient_id        INT IDENTITY(1,1) PRIMARY KEY,
    blood_type        VARCHAR(10) NOT NULL,
    full_name         NVARCHAR(200) NOT NULL,
    date_of_birth     DATE NOT NULL,
    phone             VARCHAR(20) NULL,
    gender            VARCHAR(20) NULL,
    address           NVARCHAR(300) NULL,
    CONSTRAINT CHK_Patient_blood_type CHECK (blood_type IN ('O+','O-','A+','A-','B+','B-','AB+','AB-','Others')),
    CONSTRAINT CHK_Patient_gender CHECK (gender IS NULL OR gender IN ('Male','Female','Other'))
);
GO

CREATE TABLE Relations (
    patient_id                    INT PRIMARY KEY,
    relationship_with_patient     NVARCHAR(100) NOT NULL,
    full_name                     NVARCHAR(200) NOT NULL,
    date_of_birth                 DATE NULL,
    phone                         VARCHAR(20) NULL,
    CONSTRAINT FK_Relations_Patient FOREIGN KEY (patient_id) REFERENCES Patient(patient_id)
);
GO

CREATE TABLE Staff (
    staff_id           INT IDENTITY(1,1) PRIMARY KEY,
    department_id      INT NOT NULL,
    role_id            INT NOT NULL,
    full_name          NVARCHAR(200) NOT NULL,
    email              VARCHAR(255) NULL,
    phone              VARCHAR(20) NULL,
    gender             VARCHAR(20) NULL,
    CONSTRAINT FK_Staff_Department FOREIGN KEY (department_id) REFERENCES Department(department_id),
    CONSTRAINT FK_Staff_Role FOREIGN KEY (role_id) REFERENCES Role(role_id),
    CONSTRAINT UQ_Staff_email UNIQUE (email),
    CONSTRAINT CHK_Staff_gender CHECK (gender IS NULL OR gender IN ('Male','Female','Other'))
);
GO

CREATE TABLE Room (
    room_id             INT IDENTITY(1,1) PRIMARY KEY,
    department_id       INT NOT NULL,
    category_id         INT NOT NULL,
    room_number         VARCHAR(50) NOT NULL,
    CONSTRAINT FK_Room_Department FOREIGN KEY (department_id) REFERENCES Department(department_id),
    CONSTRAINT FK_Room_Room_Category FOREIGN KEY (category_id) REFERENCES Room_Category(category_id),
    CONSTRAINT UQ_Room_department_room_number UNIQUE (department_id, room_number)
);
GO

CREATE TABLE Bed (
    bed_id              INT IDENTITY(1,1) PRIMARY KEY,
    room_id             INT NOT NULL,
    bed_number          VARCHAR(50) NOT NULL,
    status              VARCHAR(20) NOT NULL,
    CONSTRAINT FK_Bed_Room FOREIGN KEY (room_id) REFERENCES Room(room_id),
    CONSTRAINT UQ_Bed_room_bed_number UNIQUE (room_id, bed_number),
    CONSTRAINT CHK_Bed_status CHECK (status IN ('Available', 'Occupied', 'Cleaning'))
);
GO

CREATE TABLE Appointment (
    appointment_id      INT IDENTITY(1,1) PRIMARY KEY,
    patient_id          INT NOT NULL,
    doctor_id           INT NOT NULL,
    appointment_date    DATETIME NOT NULL,
    status              VARCHAR(20) NOT NULL,
    reason              NVARCHAR(MAX) NULL,
    CONSTRAINT FK_Appointment_Patient FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
    CONSTRAINT FK_Appointment_Doctor FOREIGN KEY (doctor_id) REFERENCES Staff(staff_id),
    CONSTRAINT CHK_Appointment_status CHECK (status IN ('Scheduled', 'Completed', 'Cancelled', 'No-show'))
);
GO

CREATE TABLE Admission (
    admission_id        INT IDENTITY(1,1) PRIMARY KEY,
    patient_id          INT NOT NULL,
    bed_id              INT NOT NULL,
    doctor_id           INT NOT NULL,
    status              VARCHAR(30) NOT NULL,
    discharge_date      DATE NULL,
    admission_date      DATE NOT NULL,
    CONSTRAINT FK_Admission_Patient FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
    CONSTRAINT FK_Admission_Bed FOREIGN KEY (bed_id) REFERENCES Bed(bed_id),
    CONSTRAINT FK_Admission_Doctor FOREIGN KEY (doctor_id) REFERENCES Staff(staff_id),
    CONSTRAINT CHK_Admission_status CHECK (status IN ('Admitted', 'Discharged', 'In-patient', 'Pending_Payment')),
    CONSTRAINT CHK_Admission_dates CHECK (discharge_date IS NULL OR admission_date <= discharge_date)
);
GO

CREATE TABLE Medical_Record (
    medical_record_id   INT IDENTITY(1,1) PRIMARY KEY,
    appointment_id      INT NULL,
    admission_id        INT NULL,
    patient_id          INT NOT NULL,
    doctor_id           INT NOT NULL,
    diagnosis           NVARCHAR(MAX) NULL,
    treatment           NVARCHAR(MAX) NULL,
    notes               NVARCHAR(MAX) NULL,
    record_date         DATETIME NOT NULL,
    CONSTRAINT FK_Medical_Record_Appointment FOREIGN KEY (appointment_id) REFERENCES Appointment(appointment_id),
    CONSTRAINT FK_Medical_Record_Admission FOREIGN KEY (admission_id) REFERENCES Admission(admission_id),
    CONSTRAINT FK_Medical_Record_Patient FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
    CONSTRAINT FK_Medical_Record_Doctor FOREIGN KEY (doctor_id) REFERENCES Staff(staff_id),
    CONSTRAINT CHK_Medical_Record_parent CHECK (
        (appointment_id IS NOT NULL AND admission_id IS NULL)
        OR (appointment_id IS NULL AND admission_id IS NOT NULL)
    )
);
GO

CREATE TABLE Prescription (
    prescription_id     INT IDENTITY(1,1) PRIMARY KEY,
    patient_id          INT NOT NULL,
    doctor_id           INT NOT NULL,
    medical_record_id   INT NOT NULL,
    prescription_date   DATE NOT NULL,
    CONSTRAINT FK_Prescription_Patient FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
    CONSTRAINT FK_Prescription_Doctor FOREIGN KEY (doctor_id) REFERENCES Staff(staff_id),
    CONSTRAINT FK_Prescription_Medical_Record FOREIGN KEY (medical_record_id) REFERENCES Medical_Record(medical_record_id)
);
GO

CREATE TABLE Prescription_Detail (
    prescription_detail_id  INT IDENTITY(1,1) PRIMARY KEY,
    prescription_id         INT NOT NULL,
    medicine_id             INT NOT NULL,
    quantity                INT NOT NULL,
    dosage                  VARCHAR(100) NULL,
    duration                VARCHAR(100) NULL,
    frequency               VARCHAR(100) NULL,
    CONSTRAINT FK_Prescription_Detail_Prescription FOREIGN KEY (prescription_id) REFERENCES Prescription(prescription_id),
    CONSTRAINT FK_Prescription_Detail_Medicine FOREIGN KEY (medicine_id) REFERENCES Medicine(medicine_id),
    CONSTRAINT CHK_Prescription_Detail_quantity CHECK (quantity > 0)
);
GO

CREATE TABLE Invoice (
    invoice_id           INT IDENTITY(1,1) PRIMARY KEY,
    patient_id           INT NOT NULL,
    admission_id         INT NULL,
    appointment_id       INT NULL,
    status               VARCHAR(20) NOT NULL,
    created_at           DATETIME NOT NULL CONSTRAINT DF_Invoice_created_at DEFAULT GETDATE(),
    total_amount         DECIMAL(18,2) NOT NULL CONSTRAINT DF_Invoice_total_amount DEFAULT 0,
    CONSTRAINT FK_Invoice_Patient FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
    CONSTRAINT FK_Invoice_Admission FOREIGN KEY (admission_id) REFERENCES Admission(admission_id),
    CONSTRAINT FK_Invoice_Appointment FOREIGN KEY (appointment_id) REFERENCES Appointment(appointment_id),
    CONSTRAINT CHK_Invoice_status CHECK (status IN ('Paid', 'Unpaid', 'Partial')),
    CONSTRAINT CHK_Invoice_total_amount CHECK (total_amount >= 0),
    CONSTRAINT CHK_Invoice_parent CHECK (
        (admission_id IS NOT NULL AND appointment_id IS NULL)
        OR (admission_id IS NULL AND appointment_id IS NOT NULL)
    )
);
GO

CREATE TABLE Invoice_Service_Detail (
    invoice_service_detail_id   INT IDENTITY(1,1) PRIMARY KEY,
    service_id                  INT NOT NULL,
    invoice_id                  INT NOT NULL,
    unit_price                  DECIMAL(18,2) NOT NULL,
    quantity                    INT NOT NULL,
    subtotal                    DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_Invoice_Service_Detail_Service FOREIGN KEY (service_id) REFERENCES Service(service_id),
    CONSTRAINT FK_Invoice_Service_Detail_Invoice FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id),
    CONSTRAINT CHK_Invoice_Service_Detail_quantity CHECK (quantity > 0),
    CONSTRAINT CHK_Invoice_Service_Detail_prices CHECK (unit_price > 0 AND subtotal > 0),
    CONSTRAINT CHK_Invoice_Service_Detail_subtotal CHECK (subtotal = unit_price * quantity)
);
GO

CREATE TABLE Invoice_Medicine_Detail (
    invoice_medicine_detail_id  INT IDENTITY(1,1) PRIMARY KEY,
    invoice_id                  INT NOT NULL,
    medicine_id                 INT NOT NULL,
    quantity                    INT NOT NULL,
    unit_price                  DECIMAL(18,2) NOT NULL,
    subtotal                    DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_Invoice_Medicine_Detail_Invoice FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id),
    CONSTRAINT FK_Invoice_Medicine_Detail_Medicine FOREIGN KEY (medicine_id) REFERENCES Medicine(medicine_id),
    CONSTRAINT CHK_Invoice_Medicine_Detail_quantity CHECK (quantity > 0),
    CONSTRAINT CHK_Invoice_Medicine_Detail_prices CHECK (unit_price > 0 AND subtotal > 0),
    CONSTRAINT CHK_Invoice_Medicine_Detail_subtotal CHECK (subtotal = unit_price * quantity)
);
GO

CREATE TABLE Invoice_Bed_Detail (
    invoice_bed_detail_id   INT IDENTITY(1,1) PRIMARY KEY,
    invoice_id              INT NOT NULL,
    bed_id                  INT NOT NULL,
    days                    INT NOT NULL,
    unit_price              DECIMAL(18,2) NOT NULL,
    subtotal                DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_Invoice_Bed_Detail_Invoice FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id),
    CONSTRAINT FK_Invoice_Bed_Detail_Bed FOREIGN KEY (bed_id) REFERENCES Bed(bed_id),
    CONSTRAINT CHK_Invoice_Bed_Detail_days CHECK (days > 0),
    CONSTRAINT CHK_Invoice_Bed_Detail_prices CHECK (unit_price > 0 AND subtotal > 0),
    CONSTRAINT CHK_Invoice_Bed_Detail_subtotal CHECK (subtotal = unit_price * days)
);
GO

/* =========================
   3. INDEXES
   ========================= */

CREATE INDEX IX_Appointment_patient_id ON Appointment(patient_id);
CREATE INDEX IX_Appointment_doctor_id ON Appointment(doctor_id);
CREATE INDEX IX_Appointment_appointment_date ON Appointment(appointment_date);

CREATE INDEX IX_Admission_patient_id ON Admission(patient_id);
CREATE INDEX IX_Admission_bed_id ON Admission(bed_id);
CREATE INDEX IX_Admission_doctor_id ON Admission(doctor_id);

CREATE INDEX IX_Medical_Record_patient_id ON Medical_Record(patient_id);
CREATE INDEX IX_Medical_Record_doctor_id ON Medical_Record(doctor_id);

CREATE INDEX IX_Prescription_patient_id ON Prescription(patient_id);
CREATE INDEX IX_Prescription_doctor_id ON Prescription(doctor_id);
CREATE INDEX IX_Prescription_Detail_medicine_id ON Prescription_Detail(medicine_id);

CREATE INDEX IX_Invoice_patient_id ON Invoice(patient_id);
CREATE INDEX IX_Invoice_admission_id ON Invoice(admission_id);
CREATE INDEX IX_Invoice_appointment_id ON Invoice(appointment_id);

CREATE INDEX IX_Invoice_Service_Detail_invoice_id ON Invoice_Service_Detail(invoice_id);
CREATE INDEX IX_Invoice_Medicine_Detail_invoice_id ON Invoice_Medicine_Detail(invoice_id);
CREATE INDEX IX_Invoice_Bed_Detail_invoice_id ON Invoice_Bed_Detail(invoice_id);
GO

/* =========================
   4. TRIGGERS
   ========================= */

/* 4.1 Appointment date must be today or in the future */
CREATE TRIGGER TRG_Appointment_ValidateDate
ON Appointment
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE appointment_date < GETDATE()
    )
    BEGIN
        RAISERROR ('Appointment date must be today or in the future.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

/* 4.2 Medicine expiry date must be in the future */
CREATE TRIGGER TRG_Medicine_ValidateExpiryDate
ON Medicine
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE expiry_date <= CAST(GETDATE() AS DATE)
    )
    BEGIN
        RAISERROR ('Medicine expiry_date must be greater than today.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

/* 4.3 Patient date of birth cannot be in the future */
CREATE TRIGGER TRG_Patient_ValidateDOB
ON Patient
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE date_of_birth > CAST(GETDATE() AS DATE)
    )
    BEGIN
        RAISERROR ('Patient date_of_birth cannot be in the future.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

/* 4.4 Prescription quantity cannot exceed current medicine stock */
CREATE TRIGGER TRG_Prescription_Detail_CheckStock
ON Prescription_Detail
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Medicine m ON i.medicine_id = m.medicine_id
        WHERE i.quantity > m.stock_quantity
    )
    BEGIN
        RAISERROR ('Prescription quantity cannot exceed medicine stock quantity.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

/* 4.5 One bed can have at most one active admission at a time */
CREATE TRIGGER TRG_Admission_OneActiveBed
ON Admission
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT a.bed_id
        FROM Admission a
        WHERE a.discharge_date IS NULL
        GROUP BY a.bed_id
        HAVING COUNT(*) > 1
    )
    BEGIN
        RAISERROR ('A bed can have at most one active admission (discharge_date IS NULL).', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

/* 4.6 Recalculate invoice total_amount from all invoice detail tables */
CREATE TRIGGER TRG_Invoice_Service_Detail_RecalcInvoiceTotal
ON Invoice_Service_Detail
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH affected AS (
        SELECT invoice_id FROM inserted
        UNION
        SELECT invoice_id FROM deleted
    )
    UPDATE i
    SET total_amount = ISNULL(s.service_total, 0)
                     + ISNULL(m.medicine_total, 0)
                     + ISNULL(b.bed_total, 0)
    FROM Invoice i
    JOIN affected a ON i.invoice_id = a.invoice_id
    OUTER APPLY (
        SELECT SUM(subtotal) AS service_total
        FROM Invoice_Service_Detail sd
        WHERE sd.invoice_id = i.invoice_id
    ) s
    OUTER APPLY (
        SELECT SUM(subtotal) AS medicine_total
        FROM Invoice_Medicine_Detail md
        WHERE md.invoice_id = i.invoice_id
    ) m
    OUTER APPLY (
        SELECT SUM(subtotal) AS bed_total
        FROM Invoice_Bed_Detail bd
        WHERE bd.invoice_id = i.invoice_id
    ) b;
END;
GO

CREATE TRIGGER TRG_Invoice_Medicine_Detail_RecalcInvoiceTotal
ON Invoice_Medicine_Detail
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH affected AS (
        SELECT invoice_id FROM inserted
        UNION
        SELECT invoice_id FROM deleted
    )
    UPDATE i
    SET total_amount = ISNULL(s.service_total, 0)
                     + ISNULL(m.medicine_total, 0)
                     + ISNULL(b.bed_total, 0)
    FROM Invoice i
    JOIN affected a ON i.invoice_id = a.invoice_id
    OUTER APPLY (
        SELECT SUM(subtotal) AS service_total
        FROM Invoice_Service_Detail sd
        WHERE sd.invoice_id = i.invoice_id
    ) s
    OUTER APPLY (
        SELECT SUM(subtotal) AS medicine_total
        FROM Invoice_Medicine_Detail md
        WHERE md.invoice_id = i.invoice_id
    ) m
    OUTER APPLY (
        SELECT SUM(subtotal) AS bed_total
        FROM Invoice_Bed_Detail bd
        WHERE bd.invoice_id = i.invoice_id
    ) b;
END;
GO

CREATE TRIGGER TRG_Invoice_Bed_Detail_RecalcInvoiceTotal
ON Invoice_Bed_Detail
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH affected AS (
        SELECT invoice_id FROM inserted
        UNION
        SELECT invoice_id FROM deleted
    )
    UPDATE i
    SET total_amount = ISNULL(s.service_total, 0)
                     + ISNULL(m.medicine_total, 0)
                     + ISNULL(b.bed_total, 0)
    FROM Invoice i
    JOIN affected a ON i.invoice_id = a.invoice_id
    OUTER APPLY (
        SELECT SUM(subtotal) AS service_total
        FROM Invoice_Service_Detail sd
        WHERE sd.invoice_id = i.invoice_id
    ) s
    OUTER APPLY (
        SELECT SUM(subtotal) AS medicine_total
        FROM Invoice_Medicine_Detail md
        WHERE md.invoice_id = i.invoice_id
    ) m
    OUTER APPLY (
        SELECT SUM(subtotal) AS bed_total
        FROM Invoice_Bed_Detail bd
        WHERE bd.invoice_id = i.invoice_id
    ) b;
END;
GO

/* Optional: keep bed status in sync with active admission */
CREATE TRIGGER TRG_Admission_SyncBedStatus
ON Admission
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH affected_beds AS (
        SELECT bed_id FROM inserted
        UNION
        SELECT bed_id FROM deleted
    )
    UPDATE b
    SET status = CASE
                    WHEN EXISTS (
                        SELECT 1
                        FROM Admission a
                        WHERE a.bed_id = b.bed_id
                          AND a.discharge_date IS NULL
                    ) THEN 'Occupied'
                    ELSE 'Available'
                 END
    FROM Bed b
    JOIN affected_beds ab ON b.bed_id = ab.bed_id;
END;
GO

/* =========================================================
   5. FUNCTIONS
   ========================================================= */

/* 5.1 Tính tuổi bệnh nhân từ ngày sinh */
CREATE OR ALTER FUNCTION fn_CalculateAge
(
    @date_of_birth DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @age INT;

    SET @age = DATEDIFF(YEAR, @date_of_birth, GETDATE())
             - CASE
                   WHEN DATEADD(YEAR, DATEDIFF(YEAR, @date_of_birth, GETDATE()), @date_of_birth) > CAST(GETDATE() AS DATE)
                   THEN 1
                   ELSE 0
               END;

    RETURN @age;
END;
GO

/* 5.2 Lấy tổng tiền hóa đơn từ 3 bảng detail */
CREATE OR ALTER FUNCTION fn_GetInvoiceTotal
(
    @invoice_id INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @total DECIMAL(18,2);

    SELECT @total =
        ISNULL((SELECT SUM(subtotal) FROM Invoice_Service_Detail  WHERE invoice_id = @invoice_id), 0)
      + ISNULL((SELECT SUM(subtotal) FROM Invoice_Medicine_Detail WHERE invoice_id = @invoice_id), 0)
      + ISNULL((SELECT SUM(subtotal) FROM Invoice_Bed_Detail      WHERE invoice_id = @invoice_id), 0);

    RETURN ISNULL(@total, 0);
END;
GO

/* 5.3 Xác định loại hồ sơ: Appointment / Admission */
CREATE OR ALTER FUNCTION fn_GetEncounterType
(
    @appointment_id INT,
    @admission_id INT
)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @result VARCHAR(20);

    SET @result =
        CASE
            WHEN @appointment_id IS NOT NULL AND @admission_id IS NULL THEN 'Appointment'
            WHEN @appointment_id IS NULL AND @admission_id IS NOT NULL THEN 'Admission'
            ELSE 'Invalid'
        END;

    RETURN @result;
END;
GO


/* =========================================================
   6. VIEWS
   ========================================================= */

/* 6.1 View lịch hẹn đầy đủ */
CREATE OR ALTER VIEW vw_Appointment_Detail
AS
SELECT
    a.appointment_id,
    a.appointment_date,
    a.status,
    a.reason,
    p.patient_id,
    p.full_name AS patient_name,
    dbo.fn_CalculateAge(p.date_of_birth) AS patient_age,
    p.phone AS patient_phone,
    s.staff_id AS doctor_id,
    s.full_name AS doctor_name,
    d.department_name
FROM Appointment a
JOIN Patient p
    ON a.patient_id = p.patient_id
JOIN Staff s
    ON a.doctor_id = s.staff_id
JOIN Department d
    ON s.department_id = d.department_id;
GO

/* 6.2 View nhập viện đầy đủ */
CREATE OR ALTER VIEW vw_Admission_Detail
AS
SELECT
    ad.admission_id,
    ad.admission_date,
    ad.discharge_date,
    ad.status,
    p.patient_id,
    p.full_name AS patient_name,
    dbo.fn_CalculateAge(p.date_of_birth) AS patient_age,
    p.phone AS patient_phone,
    s.staff_id AS doctor_id,
    s.full_name AS doctor_name,
    b.bed_id,
    b.bed_number,
    r.room_id,
    r.room_number,
    d.department_name
FROM Admission ad
JOIN Patient p
    ON ad.patient_id = p.patient_id
JOIN Staff s
    ON ad.doctor_id = s.staff_id
JOIN Bed b
    ON ad.bed_id = b.bed_id
JOIN Room r
    ON b.room_id = r.room_id
JOIN Department d
    ON r.department_id = d.department_id;
GO

/* 6.3 View hóa đơn tổng hợp, giữ Appointment và Admission ngang hàng */
CREATE OR ALTER VIEW vw_Invoice_Summary
AS
SELECT
    i.invoice_id,
    i.patient_id,
    p.full_name AS patient_name,
    i.created_at,
    i.status,
    i.appointment_id,
    i.admission_id,
    dbo.fn_GetEncounterType(i.appointment_id, i.admission_id) AS encounter_type,
    dbo.fn_GetInvoiceTotal(i.invoice_id) AS calculated_total,
    i.total_amount AS stored_total
FROM Invoice i
JOIN Patient p
    ON i.patient_id = p.patient_id;
GO


/* =========================================================
   7. STORED PROCEDURES (mỗi procedure đều có TRANSACTION)
   ========================================================= */

/* 7.1 Tạo Appointment + tạo Invoice luôn */
CREATE OR ALTER PROCEDURE sp_CreateAppointment
    @patient_id INT,
    @doctor_id INT,
    @appointment_date DATETIME,
    @reason NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @appointment_id INT;
    DECLARE @invoice_id INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Appointment
        (
            patient_id,
            doctor_id,
            appointment_date,
            status,
            reason
        )
        VALUES
        (
            @patient_id,
            @doctor_id,
            @appointment_date,
            'Scheduled',
            @reason
        );

        SET @appointment_id = SCOPE_IDENTITY();

        INSERT INTO Invoice
        (
            patient_id,
            appointment_id,
            admission_id,
            status
        )
        VALUES
        (
            @patient_id,
            @appointment_id,
            NULL,
            'Unpaid'
        );

        SET @invoice_id = SCOPE_IDENTITY();

        COMMIT TRANSACTION;

        SELECT
            @appointment_id AS appointment_id,
            @invoice_id AS invoice_id,
            'Create appointment successfully' AS message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO


/* 7.2 Tạo Admission + tạo Invoice luôn */
CREATE OR ALTER PROCEDURE sp_AdmitPatient
    @patient_id INT,
    @bed_id INT,
    @doctor_id INT,
    @admission_date DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @admission_id INT;
    DECLARE @invoice_id INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS
        (
            SELECT 1
            FROM Admission
            WHERE bed_id = @bed_id
              AND discharge_date IS NULL
        )
        BEGIN
            RAISERROR('This bed is currently occupied by another active admission.', 16, 1);
        END

        INSERT INTO Admission
        (
            patient_id,
            bed_id,
            doctor_id,
            status,
            admission_date,
            discharge_date
        )
        VALUES
        (
            @patient_id,
            @bed_id,
            @doctor_id,
            'Admitted',
            @admission_date,
            NULL
        );

        SET @admission_id = SCOPE_IDENTITY();

        INSERT INTO Invoice
        (
            patient_id,
            admission_id,
            appointment_id,
            status
        )
        VALUES
        (
            @patient_id,
            @admission_id,
            NULL,
            'Unpaid'
        );

        SET @invoice_id = SCOPE_IDENTITY();

        UPDATE Bed
        SET status = 'Occupied'
        WHERE bed_id = @bed_id;

        COMMIT TRANSACTION;

        SELECT
            @admission_id AS admission_id,
            @invoice_id AS invoice_id,
            'Admit patient successfully' AS message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO


/* 7.3 Xuất viện */
CREATE OR ALTER PROCEDURE sp_DischargePatient
    @admission_id INT,
    @discharge_date DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @bed_id INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @bed_id = bed_id
        FROM Admission
        WHERE admission_id = @admission_id;

        IF @bed_id IS NULL
        BEGIN
            RAISERROR('Admission does not exist.', 16, 1);
        END

        UPDATE Admission
        SET discharge_date = @discharge_date,
            status = 'Discharged'
        WHERE admission_id = @admission_id;

        UPDATE Bed
        SET status = 'Cleaning'
        WHERE bed_id = @bed_id;

        COMMIT TRANSACTION;

        SELECT
            @admission_id AS admission_id,
            @bed_id AS bed_id,
            'Discharge patient successfully' AS message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO


/* 7.4 Tạo Medical Record cho Appointment */
CREATE OR ALTER PROCEDURE sp_CreateMedicalRecord_ForAppointment
    @appointment_id INT,
    @patient_id INT,
    @doctor_id INT,
    @diagnosis NVARCHAR(MAX) = NULL,
    @treatment NVARCHAR(MAX) = NULL,
    @notes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Medical_Record
        (
            appointment_id,
            admission_id,
            patient_id,
            doctor_id,
            diagnosis,
            treatment,
            notes,
            record_date
        )
        VALUES
        (
            @appointment_id,
            NULL,
            @patient_id,
            @doctor_id,
            @diagnosis,
            @treatment,
            @notes,
            GETDATE()
        );

        UPDATE Appointment
        SET status = 'Completed'
        WHERE appointment_id = @appointment_id;

        COMMIT TRANSACTION;

        SELECT
            SCOPE_IDENTITY() AS medical_record_id,
            'Create medical record for appointment successfully' AS message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO


/* 7.5 Tạo Medical Record cho Admission */
CREATE OR ALTER PROCEDURE sp_CreateMedicalRecord_ForAdmission
    @admission_id INT,
    @patient_id INT,
    @doctor_id INT,
    @diagnosis NVARCHAR(MAX) = NULL,
    @treatment NVARCHAR(MAX) = NULL,
    @notes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Medical_Record
        (
            appointment_id,
            admission_id,
            patient_id,
            doctor_id,
            diagnosis,
            treatment,
            notes,
            record_date
        )
        VALUES
        (
            NULL,
            @admission_id,
            @patient_id,
            @doctor_id,
            @diagnosis,
            @treatment,
            @notes,
            GETDATE()
        );

        COMMIT TRANSACTION;

        SELECT
            SCOPE_IDENTITY() AS medical_record_id,
            'Create medical record for admission successfully' AS message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO