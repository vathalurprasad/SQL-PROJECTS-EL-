-- HOSPITAL MANAGEMENT DATABASE SQL SCRIPT

-- Step 1: Create Schema
CREATE SCHEMA Hospital_Management_Analysis;
USE Hospital_Management_Analysis;

-- Step 2: Create Tables

CREATE TABLE Departments (
    DepartmentID INT AUTO_INCREMENT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Doctors (
    DoctorID INT AUTO_INCREMENT PRIMARY KEY,
    DoctorName VARCHAR(100) NOT NULL,
    Specialization VARCHAR(100),
    Phone VARCHAR(15),
    Email VARCHAR(100),
    DepartmentID INT,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

CREATE TABLE Patients (
    PatientID INT AUTO_INCREMENT PRIMARY KEY,
    PatientName VARCHAR(100) NOT NULL,
    Age INT,
    Gender VARCHAR(10),
    Address VARCHAR(200),
    ContactNumber VARCHAR(15),
    Email VARCHAR(100)
);

CREATE TABLE Visits (
    VisitID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT,
    DoctorID INT,
    VisitDate DATE,
    Symptoms TEXT,
    Diagnosis VARCHAR(255),
    Prescription TEXT,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);
CREATE TABLE Bills (
    BillID INT AUTO_INCREMENT PRIMARY KEY,
    VisitID INT,
    Amount DECIMAL(10,2),
    PaymentStatus VARCHAR(50),
    PaymentMethod VARCHAR(50),
    BillDate DATE,
    FOREIGN KEY (VisitID) REFERENCES Visits(VisitID)
);

CREATE TABLE Medications (
    MedicationID INT AUTO_INCREMENT PRIMARY KEY,
    MedicationName VARCHAR(100),
    Dosage VARCHAR(50),
    Frequency VARCHAR(50)
);

CREATE TABLE Prescriptions (
    PrescriptionID INT AUTO_INCREMENT PRIMARY KEY,
    VisitID INT,
    MedicationID INT,
    Instructions TEXT,
    FOREIGN KEY (VisitID) REFERENCES Visits(VisitID),
    FOREIGN KEY (MedicationID) REFERENCES Medications(MedicationID)
);

-- Step 3: Insert Sample Data

INSERT INTO Departments (DepartmentName) VALUES
('Cardiology'), ('Neurology'), ('Orthopedics'), ('General Medicine'), ('Pediatrics');

select * from Departments;

INSERT INTO Doctors (DoctorName, Specialization, Phone, Email, DepartmentID) VALUES
('Dr. A Sharma', 'Cardiologist', '9876543210', 'a.sharma@hospital.com', 1),
('Dr. B Rao', 'Neurologist', '9823456789', 'b.rao@hospital.com', 2),
('Dr. C Iyer', 'Orthopedic', '9786543210', 'c.iyer@hospital.com', 3),
('Dr. D Nair', 'Physician', '9123456780', 'd.nair@hospital.com', 4),
('Dr. E Verma', 'Pediatrician', '9112345678', 'e.verma@hospital.com', 5);

select * from Doctors;

INSERT INTO Patients (PatientName, Age, Gender, Address, ContactNumber, Email) VALUES
('Rajesh Kumar', 45, 'Male', 'Delhi', '9000000001', 'rajesh@gmail.com'),
('Anita Sharma', 30, 'Female', 'Mumbai', '9000000002', 'anita@gmail.com'),
('John Paul', 55, 'Male', 'Kolkata', '9000000003', 'john@gmail.com'),
('Sonal Mehta', 26, 'Female', 'Chennai', '9000000004', 'sonal@gmail.com'),
('Rohit Das', 8, 'Male', 'Bangalore', '9000000005', 'rohit@gmail.com');

select * from Patients;

INSERT INTO Visits (PatientID, DoctorID, VisitDate, Symptoms, Diagnosis, Prescription) VALUES
(1, 1, '2025-07-15', 'Chest Pain, Dizziness', 'High BP', 'Atenolol, BP monitoring'),
(2, 2, '2025-07-16', 'Headache, Light Sensitivity', 'Migraine', 'Paracetamol, Rest'),
(3, 3, '2025-07-17', 'Leg Pain, Swelling', 'Fracture', 'Bed rest, Cast'),
(4, 4, '2025-07-18', 'Fever, Cough', 'Viral Fever', 'Paracetamol, Fluids'),
(5, 5, '2025-07-19', 'Cough, Sneezing', 'Cold & Flu', 'Syrup, Steam Inhalation');

select * from Visits;

INSERT INTO Bills (VisitID, Amount, PaymentStatus, PaymentMethod) VALUES
(1, 1500.00, 'Paid', 'Credit Card'),
(2, 1200.00, 'Pending', 'Cash'),
(3, 2500.00, 'Paid', 'Online'),
(4, 1000.00, 'Paid', 'Cash'),
(5, 900.00, 'Pending', 'UPI');

select * from Bills;

INSERT INTO Medications (MedicationName, Dosage, Frequency) VALUES
('Atenolol', '50mg', 'Once Daily'),
('Paracetamol', '500mg', 'Thrice Daily'),
('Amoxicillin', '250mg', 'Twice Daily'),
('Cough Syrup', '10ml', 'Twice Daily'),
('Vitamin C', '1000mg', 'Once Daily');

select * from Medications;

INSERT INTO Prescriptions (VisitID, MedicationID, Instructions) VALUES
(1, 1, 'Take in the morning with food'),
(2, 2, 'Take after meals'),
(4, 4, 'Shake well before use'),
(5, 5, 'Take after breakfast');

select * from Prescriptions;

-- Step 4: Useful Queries

-- 1. List of Doctors with Departments
SELECT d.DepartmentName, doc.DoctorName, doc.Specialization
FROM Doctors doc
JOIN Departments d ON doc.DepartmentID = d.DepartmentID;

-- 2. Full Visit History of Patients
SELECT p.PatientName, v.VisitDate, doc.DoctorName, v.Diagnosis, v.Prescription
FROM Visits v
JOIN Patients p ON v.PatientID = p.PatientID
JOIN Doctors doc ON v.DoctorID = doc.DoctorID;

-- 3. Patient Billing Information
SELECT p.PatientName, b.Amount, b.PaymentStatus, b.PaymentMethod, b.BillDate
FROM Bills b
JOIN Visits v ON b.VisitID = v.VisitID
JOIN Patients p ON v.PatientID = p.PatientID;

-- 4. Total Billing Per Department
SELECT dept.DepartmentName, SUM(b.Amount) AS TotalBilling
FROM Bills b
JOIN Visits v ON b.VisitID = v.VisitID
JOIN Doctors doc ON v.DoctorID = doc.DoctorID
JOIN Departments dept ON doc.DepartmentID = dept.DepartmentID
GROUP BY dept.DepartmentName;

-- 5. Patients with Pending Payments
SELECT DISTINCT p.PatientName
FROM Bills b
JOIN Visits v ON b.VisitID = v.VisitID
JOIN Patients p ON v.PatientID = p.PatientID
WHERE b.PaymentStatus = 'Pending';

-- 6. Number of Visits Per Doctor
SELECT d.DoctorName, COUNT(v.VisitID) AS TotalVisits
FROM Doctors d
JOIN Visits v ON d.DoctorID = v.DoctorID
GROUP BY d.DoctorName;

-- 7. Frequently Prescribed Medications
SELECT m.MedicationName, COUNT(p.PrescriptionID) AS TimesPrescribed
FROM Prescriptions p
JOIN Medications m ON p.MedicationID = m.MedicationID
GROUP BY m.MedicationName
ORDER BY TimesPrescribed DESC;

-- End of Enhanced Script
