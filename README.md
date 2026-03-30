# Hospital Management Database System - DBI202

## Introduction
This project is the final assignment for the DBI202 (Database Systems) course. It is a database system designed to manage the daily operations of a general hospital. The system helps organize patient information, doctor appointments, hospital admissions, medical records, pharmacy inventory, and billing processes.

## Team Members - Group 5
* Nguyen Huy Nhat (HE204465)
* Luu Chi Kien (HS204365)
* Nguyen Hoang Long (HE204497)
* Pham Cong Hung (HE204376)
* Lai Viet Hieu (HE201856)
* Mai Khanh Hung (HS204492)

## System Scope
The database is divided into five main functional areas:

1. Master Data & Organization: Manages hospital departments, staff roles, room categories, and the list of medical services and medicines.
2. Patient & Human Resources: Stores personal details of patients, their emergency contacts, and hospital staff (doctors, nurses, etc.).
3. Infrastructure: Manages hospital rooms and tracks the real-time status of hospital beds (Available, Occupied, Cleaning).
4. Clinical Operations: Handles the core medical workflow. This includes scheduling outpatient appointments, managing inpatient admissions, recording medical diagnoses, and writing prescriptions.
5. Billing and Finance: Automatically generates invoices and calculates total costs based on medical services used, medicines purchased, and days spent in a hospital bed.

## Technical Features
The project is built using Microsoft SQL Server and includes the following database objects:

* Tables: 19 normalized tables to store all hospital data.
* Constraints: Primary keys, foreign keys, unique constraints, and check constraints to ensure data accuracy.
* Triggers: Used to automate rules and maintain data integrity. For example: preventing the use of expired medicines, checking medicine stock before prescribing, preventing double-booking of beds, and automatically updating invoice totals when new services are added.
* Functions: Custom functions to calculate a patient's exact age, calculate the total amount of an invoice, and determine the type of medical visit.
* Views: Virtual tables that combine data to provide clear summaries of appointments, admissions, and invoices for reporting.
* Stored Procedures: Pre-written SQL code to handle complex business tasks safely, such as creating new appointments, admitting patients to beds, discharging patients, and generating medical records.

## How to Run the Project

1. Open Microsoft SQL Server Management Studio (SSMS).
2. Open the file named "hospital_database-ddl.sql".
3. Execute this file. It will create the "HospitalManagementDB" database, build all the tables, and set up the triggers, views, functions, and stored procedures.
4. Open the file named "hospital_database_demo.sql".
5. Execute this file. It will insert sample data (seed data) into the tables and run test cases to demonstrate how the procedures and triggers work in real scenarios.

