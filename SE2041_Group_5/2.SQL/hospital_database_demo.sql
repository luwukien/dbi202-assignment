
USE HospitalManagementDB;
GO

/* =========================================================
   8. INPUT GOC (SEED DATA CO BAN)
   ========================================================= */

/* 8.1 Department */
INSERT INTO Department (department_name, description, phone)
VALUES
(N'Cardiology', N'Heart and cardiovascular treatment', '02839001001'),
(N'Neurology', N'Brain and nervous system treatment', '02839001002'),
(N'Pediatrics', N'Healthcare services for children', '02839001003'),
(N'Emergency', N'Emergency and urgent care', '02839001004');
GO

/* 8.2 Role */
INSERT INTO Role (role_name, description)
VALUES
('Doctor', N'Medical doctor'),
('Nurse', N'Nursing staff'),
('Receptionist', N'Front desk / reception'),
('Pharmacist', N'Pharmacy staff');
GO

/* 8.3 Room category */
INSERT INTO Room_Category (type_name, capacity)
VALUES
('VIP', 1),
('Standard', 2),
('ICU', 1);
GO

/* 8.4 Service */
INSERT INTO Service (service_name, description, price)
VALUES
(N'General Checkup', N'Basic outpatient consultation', 200000),
(N'Blood Test', N'Basic blood test package', 150000),
(N'X-Ray', N'Chest X-Ray', 300000),
(N'ECG', N'Electrocardiogram', 250000),
(N'CT Scan', N'Computed tomography scan', 1200000);
GO

/* 8.5 Medicine */
INSERT INTO Medicine (medicine_name, price, category, unit, stock_quantity, expiry_date)
VALUES
(N'Paracetamol 500mg', 5000, 'Painkiller', 'Tablet', 500, DATEADD(DAY, 365, CAST(GETDATE() AS DATE))),
(N'Amoxicillin 500mg', 8000, 'Antibiotic', 'Capsule', 300, DATEADD(DAY, 420, CAST(GETDATE() AS DATE))),
(N'Vitamin C', 3000, 'Supplement', 'Tablet', 400, DATEADD(DAY, 300, CAST(GETDATE() AS DATE))),
(N'Cough Syrup', 45000, 'Respiratory', 'Bottle', 120, DATEADD(DAY, 250, CAST(GETDATE() AS DATE))),
(N'Omeprazole 20mg', 7000, 'Gastrointestinal', 'Capsule', 250, DATEADD(DAY, 500, CAST(GETDATE() AS DATE)));
GO

/* 8.6 Patient */
INSERT INTO Patient (blood_type, full_name, date_of_birth, phone, gender, address)
VALUES
('A+', N'Nguyen Van An', '1995-04-12', '0901000001', 'Male', N'12 Le Loi, District 1, HCMC'),
('O+', N'Tran Thi Binh', '1988-11-23', '0901000002', 'Female', N'45 Nguyen Hue, District 1, HCMC'),
('B+', N'Le Hoang Minh', '2001-02-14', '0901000003', 'Male', N'78 Vo Van Tan, District 3, HCMC'),
('AB+', N'Pham Ngoc Mai', '2014-09-20', '0901000004', 'Female', N'22 Hai Ba Trung, District 1, HCMC');
GO

/* 8.7 Relations */
INSERT INTO Relations (patient_id, relationship_with_patient, full_name, date_of_birth, phone)
VALUES
(1, N'Father', N'Nguyen Van Hung', '1970-03-10', '0912000001'),
(2, N'Husband', N'Pham Quoc Tuan', '1985-06-25', '0912000002'),
(3, N'Mother', N'Le Thi Lan', '1978-08-08', '0912000003'),
(4, N'Mother', N'Pham Thi Hoa', '1989-01-15', '0912000004');
GO

/* 8.8 Staff */
INSERT INTO Staff (department_id, role_id, full_name, email, phone, gender)
VALUES
(1, 1, N'Dr. Nguyen Minh Duc', 'duc.nguyen@hospital.local', '0933000001', 'Male'),
(2, 1, N'Dr. Tran Thu Ha', 'ha.tran@hospital.local', '0933000002', 'Female'),
(3, 1, N'Dr. Le Quoc Bao', 'bao.le@hospital.local', '0933000003', 'Male'),
(4, 2, N'Nurse Pham My Linh', 'linh.pham@hospital.local', '0933000004', 'Female'),
(1, 2, N'Nurse Do Anh Tuan', 'tuan.do@hospital.local', '0933000005', 'Male'),
(4, 3, N'Vo Thi Thu', 'thu.vo@hospital.local', '0933000006', 'Female'),
(4, 4, N'Hoang Gia Huy', 'huy.hoang@hospital.local', '0933000007', 'Male');
GO

/* 8.9 Room */
INSERT INTO Room (department_id, category_id, room_number)
VALUES
(1, 1, 'C101'),
(1, 2, 'C102'),
(2, 2, 'N201'),
(4, 3, 'E001');
GO

/* 8.10 Bed */
INSERT INTO Bed (room_id, bed_number, status)
VALUES
(1, 'B1', 'Available'),
(2, 'B1', 'Available'),
(2, 'B2', 'Available'),
(3, 'B1', 'Available'),
(3, 'B2', 'Available'),
(4, 'B1', 'Available');
GO

/* =========================================================
   9. INPUT MAU DEMO (DU LIEU PHAT SINH)
   ========================================================= */

/* 9.1 Tạo 2 lịch hẹn qua stored procedure */
DECLARE @appt_date DATETIME;
SET @appt_date = DATEADD(DAY, 1, GETDATE());

EXEC sp_CreateAppointment
    @patient_id = 1,
    @doctor_id = 1,
    @appointment_date = @appt_date,
    @reason = N'Chest pain and shortness of breath';
GO

DECLARE @appt_date DATETIME;
SET @appt_date = DATEADD(DAY, 1, GETDATE());

EXEC sp_CreateAppointment
    @patient_id = 2,
    @doctor_id = 2,
    @appointment_date = @appt_date,
    @reason = N'Frequent headache and dizziness';
GO

/* 9.2 Tạo hồ sơ bệnh án cho lịch hẹn số 1 */
EXEC sp_CreateMedicalRecord_ForAppointment
    @appointment_id = 1,
    @patient_id = 1,
    @doctor_id = 1,
    @diagnosis = N'Mild arrhythmia',
    @treatment = N'Rest, monitor heart rate, do ECG',
    @notes = N'Patient should return after 7 days';
GO

/* 9.3 Tạo đơn thuốc cho hồ sơ bệnh án appointment */
INSERT INTO Prescription (patient_id, doctor_id, medical_record_id, prescription_date)
VALUES (1, 1, 1, CAST(GETDATE() AS DATE));
GO

INSERT INTO Prescription_Detail (prescription_id, medicine_id, quantity, dosage, duration, frequency)
VALUES
(1, 1, 10, '500mg', '5 days', '2 times/day'),
(1, 3, 20, '1 tablet', '10 days', '1 time/day');
GO

/* 9.4 Admit bệnh nhân nội trú */

DECLARE @adm_date DATE;
SET @adm_date = CAST(GETDATE() AS DATE);

EXEC sp_AdmitPatient
    @patient_id = 3,
    @bed_id = 2,
    @doctor_id = 1,
    @admission_date = @adm_date;
GO

/* 9.5 Tạo hồ sơ bệnh án cho admission */
EXEC sp_CreateMedicalRecord_ForAdmission
    @admission_id = 1,
    @patient_id = 3,
    @doctor_id = 1,
    @diagnosis = N'Acute gastritis',
    @treatment = N'IV fluids, omeprazole, observe for 2 days',
    @notes = N'Need follow-up after discharge';
GO

/* 9.6 Tạo đơn thuốc cho admission */
INSERT INTO Prescription (patient_id, doctor_id, medical_record_id, prescription_date)
VALUES (3, 1, 2, CAST(GETDATE() AS DATE));
GO

INSERT INTO Prescription_Detail (prescription_id, medicine_id, quantity, dosage, duration, frequency)
VALUES
(2, 5, 14, '20mg', '7 days', '2 times/day'),
(2, 1, 6, '500mg', '3 days', '2 times/day');
GO

/* 9.7 Bổ sung chi tiết hóa đơn cho appointment invoice_id = 1 */
INSERT INTO Invoice_Service_Detail (service_id, invoice_id, unit_price, quantity, subtotal)
VALUES
(1, 1, 200000, 1, 200000),
(4, 1, 250000, 1, 250000),
(2, 1, 150000, 1, 150000);
GO

INSERT INTO Invoice_Medicine_Detail (invoice_id, medicine_id, quantity, unit_price, subtotal)
VALUES
(1, 1, 10, 5000, 50000),
(1, 3, 20, 3000, 60000);
GO

UPDATE Invoice
SET status = 'Paid'
WHERE invoice_id = 1;
GO

/* 9.8 Bổ sung chi tiết hóa đơn cho admission invoice_id = 3 */
INSERT INTO Invoice_Service_Detail (service_id, invoice_id, unit_price, quantity, subtotal)
VALUES
(3, 3, 300000, 1, 300000),
(2, 3, 150000, 2, 300000);
GO

INSERT INTO Invoice_Medicine_Detail (invoice_id, medicine_id, quantity, unit_price, subtotal)
VALUES
(3, 5, 14, 7000, 98000),
(3, 1, 6, 5000, 30000);
GO

INSERT INTO Invoice_Bed_Detail (invoice_id, bed_id, days, unit_price, subtotal)
VALUES
(3, 2, 3, 500000, 1500000);
GO

UPDATE Invoice
SET status = 'Partial'
WHERE invoice_id = 3;
GO

/* =========================================================
   10. DEMO CAC CHUC NANG
   ========================================================= */

/* 10.1 Xem input gốc */
PRINT '=== DEMO 10.1: MASTER DATA ===';
SELECT * FROM Department;
SELECT * FROM Role;
SELECT * FROM Room_Category;
SELECT * FROM Service;
SELECT * FROM Medicine;
GO

/* 10.2 Xem dữ liệu bệnh nhân, thân nhân, nhân sự, phòng giường */
PRINT '=== DEMO 10.2: CORE BASE DATA ===';
SELECT * FROM Patient;
SELECT * FROM Relations;
SELECT * FROM Staff;
SELECT * FROM Room;
SELECT * FROM Bed;
GO

/* 10.3 Demo function tính tuổi */
PRINT '=== DEMO 10.3: FUNCTION fn_CalculateAge ===';
SELECT patient_id, full_name, date_of_birth, dbo.fn_CalculateAge(date_of_birth) AS age
FROM Patient;
GO

/* 10.4 Demo function xác định encounter type */
PRINT '=== DEMO 10.4: FUNCTION fn_GetEncounterType ===';
SELECT invoice_id, appointment_id, admission_id,
       dbo.fn_GetEncounterType(appointment_id, admission_id) AS encounter_type
FROM Invoice
ORDER BY invoice_id;
GO

/* 10.5 Demo function tính tổng hóa đơn */
PRINT '=== DEMO 10.5: FUNCTION fn_GetInvoiceTotal ===';
SELECT i.invoice_id,
       p.full_name AS patient_name,
       i.total_amount AS stored_total,
       dbo.fn_GetInvoiceTotal(i.invoice_id) AS calculated_total
FROM Invoice i
JOIN Patient p ON i.patient_id = p.patient_id
ORDER BY i.invoice_id;
GO

/* 10.6 Demo view lịch hẹn */
PRINT '=== DEMO 10.6: VIEW vw_Appointment_Detail ===';
SELECT * FROM vw_Appointment_Detail ORDER BY appointment_id;
GO

/* 10.7 Demo view nhập viện */
PRINT '=== DEMO 10.7: VIEW vw_Admission_Detail ===';
SELECT * FROM vw_Admission_Detail ORDER BY admission_id;
GO

/* 10.8 Demo view hóa đơn */
PRINT '=== DEMO 10.8: VIEW vw_Invoice_Summary ===';
SELECT * FROM vw_Invoice_Summary ORDER BY invoice_id;
GO

/* 10.9 Demo stored procedure discharge */
PRINT '=== DEMO 10.9: PROCEDURE sp_DischargePatient ===';

DECLARE @dis_date DATE;
SET @dis_date = CAST(GETDATE() AS DATE);

EXEC sp_DischargePatient
    @admission_id = 1,
    @discharge_date = @dis_date;
GO

SELECT * FROM Admission WHERE admission_id = 1;
SELECT * FROM Bed WHERE bed_id = 2;
GO

/* 10.10 Demo trigger tự cập nhật total_amount */
PRINT '=== DEMO 10.10: TRIGGER RECALCULATE INVOICE TOTAL ===';
INSERT INTO Invoice_Service_Detail (service_id, invoice_id, unit_price, quantity, subtotal)
VALUES (5, 3, 1200000, 1, 1200000);
GO

SELECT invoice_id, total_amount, dbo.fn_GetInvoiceTotal(invoice_id) AS calculated_total
FROM Invoice
WHERE invoice_id = 3;
GO

/* 10.11 Demo trigger đồng bộ trạng thái giường sau discharge */
PRINT '=== DEMO 10.11: BED STATUS AFTER DISCHARGE ===';
SELECT bed_id, bed_number, status
FROM Bed
WHERE bed_id = 2;
GO

/* 10.12 Demo truy vấn tổng hợp nghiệp vụ */
PRINT '=== DEMO 10.12: BUSINESS REPORTS ===';
SELECT d.department_name, COUNT(s.staff_id) AS total_staff
FROM Department d
LEFT JOIN Staff s ON d.department_id = s.department_id
GROUP BY d.department_name
ORDER BY d.department_name;

SELECT p.full_name AS patient_name,
       COUNT(a.appointment_id) AS total_appointments,
       COUNT(ad.admission_id) AS total_admissions
FROM Patient p
LEFT JOIN Appointment a ON p.patient_id = a.patient_id
LEFT JOIN Admission ad ON p.patient_id = ad.patient_id
GROUP BY p.full_name
ORDER BY p.full_name;

SELECT TOP 10
       i.invoice_id,
       p.full_name AS patient_name,
       i.status,
       i.total_amount,
       i.created_at
FROM Invoice i
JOIN Patient p ON i.patient_id = p.patient_id
ORDER BY i.total_amount DESC, i.invoice_id DESC;
GO

/* 10.13 Demo optional: các test lỗi để kiểm tra trigger/check constraint */

INSERT INTO Patient (blood_type, full_name, date_of_birth, phone, gender, address)
VALUES ('O+', N'Test Future DOB', DATEADD(DAY, 1, CAST(GETDATE() AS DATE)), '0999999999', 'Male', N'Test address');
GO

INSERT INTO Medicine (medicine_name, price, category, unit, stock_quantity, expiry_date)
VALUES (N'Expired Demo Drug', 10000, 'Demo', 'Tablet', 10, CAST(GETDATE() AS DATE));
GO

INSERT INTO Appointment (patient_id, doctor_id, appointment_date, status, reason)
VALUES (1, 1, DATEADD(DAY, -1, GETDATE()), 'Scheduled', N'Past appointment test');
GO
