/*Phase 3 By Daniel McDonough & Talal Jaber*/
/*desc tablename : This allows you to see the status of a query*/

/*FROM PHASE 2*/

/*Employee*/
CREATE TABLE Employee(
	ID INTEGER NOT NULL PRIMARY KEY,
	FName CHAR(20) NOT NULL,
	LName CHAR(30) NOT NULL,
	Salary REAL NOT NULL,
	JobTitle CHAR(30) NOT NULL,
	OfficeNum CHAR(30) NOT NULL UNIQUE, /*Assume: B16 is an office, Employees cannot share office space */
	EmpRank INTEGER NOT NULL, /* employee is regular (rank = 0), division manager (rank = 1), or general manager (rank = 2) */
	SupervisorID INTEGER, /*General Managers don't have supervisors*/
	CONSTRAINT CHK_EmpRank CHECK (EmpRank = 0 OR EmpRank = 1 OR EmpRank = 2)
);

/*Room */
CREATE TABLE Room(
	Num INTEGER NOT NULL PRIMARY KEY,
	Occupied CHAR(1) NOT NULL,
	CONSTRAINT CHK_Occupied CHECK (Occupied = 0 OR Occupied = 1) /*UnOccupied = 0, Occupied = 1*/
); 

/*EquipmentType */
CREATE TABLE EquipmentType (
	ID INTEGER NOT NULL PRIMARY KEY,
	Description CHAR(20), /*Who needs Descriptions? - can be NULL*/
	Model VARCHAR2(20) NOT NULL,
	Instructions VARCHAR2(500) /*Who needs instructions? - can be NULL*/
);

/*Equipment */
CREATE TABLE Equipment(
	Serial# VARCHAR2(20) NOT NULL PRIMARY KEY,
	TypeID INTEGER NOT NULL,
	PurchaseYear DATE NOT NULL,
	LastInspetion DATE,
	RoomNum INTEGER NOT NULL,
	FOREIGN KEY (RoomNum) REFERENCES Room(Num),
	FOREIGN KEY (TypeID) REFERENCES EquipmentType(ID),
	CONSTRAINT Ck_Equipment CHECK (LastInspetion >= PurchaseYear)
);



/*RoomService */
CREATE TABLE RoomService(
	RoomNum INTEGER NOT NULL,
	Service CHAR(20) NOT NULL,
	CONSTRAINT PK_RoomService PRIMARY KEY (RoomNum,Service),
	FOREIGN KEY (RoomNum) REFERENCES Room(Num)
);

/*RoomAccess */
CREATE TABLE RoomAccess(
	RoomNum INTEGER NOT NULL,
	EmpID INTEGER NOT NULL,
	CONSTRAINT PK_RoomAccess PRIMARY KEY (RoomNum,EmpID),
	FOREIGN KEY (RoomNum) REFERENCES Room(Num),
	FOREIGN KEY (EmpID) REFERENCES Employee(ID)
);

/*Patient */
CREATE TABLE Patient(
	SSN VARCHAR2(11) NOT NULL PRIMARY KEY, /* ASSUME Format 000-00-0000*/
	FirstName CHAR(20) NOT NULL,
	LastName CHAR(30) NOT NULL,
	Address VARCHAR2(30) NOT NULL,  
	TelNum VARCHAR(14) NOT NULL/* ASSUME FORMAT (123)-456-7890*/
);

/*Doctor */
CREATE TABLE Doctor(
	ID INTEGER NOT NULL PRIMARY KEY,
	FirstName CHAR(20) NOT NULL,
	LastName CHAR(30) NOT NULL,
	Gender CHAR(1) NOT NULL,
	Specialty CHAR(20) NOT NULL, /*ASSUME SPECIALTY CAN BE LABLED AS GENERAL*/
	CONSTRAINT CHK_Gender CHECK (Gender = 'M' OR Gender = 'F')
);

/*Admission */
CREATE TABLE Admission(
	ANum INTEGER NOT NULL PRIMARY KEY,
	AdmissionDate DATE NOT NULL,
	LeaveDate DATE, /*Assume leave date is not pre-scheduled*/
	TotalPayment REAL NOT NULL,
	InsurancePayment REAL, /*Assume patient can have null insurance*/
	Patient_SSN VARCHAR2(11) NOT NULL,
	FutureVisit Date, /*Patient doesnt need to have a future visit*/
	/*FOREIGN KEY (Patient_SSN) REFERENCES Patient(SSN)*/
	CONSTRAINT Ck_Admission CHECK (AdmissionDate<=LeaveDate),
	CONSTRAINT Ck_Future CHECK (LeaveDate<FutureVisit),
	CONSTRAINT Ck_Payment CHECK (InsurancePayment<=TotalPayment)
);

/*Examine*/
CREATE TABLE Examine(
	DoctorID INTEGER NOT NULL,
	AdmissionNum INTEGER NOT NULL,
	Comments VARCHAR2(200), /* Doc can choose to not leave a comment*/
	CONSTRAINT PK_Examine PRIMARY KEY (DoctorID,AdmissionNum),
	FOREIGN KEY (DoctorID) REFERENCES Doctor(ID),
	FOREIGN KEY (AdmissionNum) REFERENCES Admission(ANum)
);

/*StayIn*/
CREATE TABLE StayIn(
	AdmissionNum INTEGER NOT NULL,
	RoomNum INTEGER NOT NULL,
	StartDate DATE NOT NULL,
	EndDate DATE, /* CAN BE NULL IF WE DO NOT KNOW HOW LONG A PATIENT MAY STAY*/
	CONSTRAINT PK_StayIn PRIMARY KEY (AdmissionNum,RoomNum,StartDate),
	FOREIGN KEY (RoomNum) REFERENCES Room(Num),
	FOREIGN KEY (AdmissionNum) REFERENCES Admission(ANum)
);

/*DROP TABLES TO MAKE SURE EVERYTHING IS HUNKYDORY 

DROP TABLE Employee CASCADE CONSTRAINTS;
DROP TABLE Room CASCADE CONSTRAINTS;
DROP TABLE Equipment CASCADE CONSTRAINTS;
DROP TABLE EquipmentType CASCADE CONSTRAINTS;
DROP TABLE RoomAccess CASCADE CONSTRAINTS;
DROP TABLE RoomService CASCADE CONSTRAINTS;
DROP TABLE Patient CASCADE CONSTRAINTS;
DROP TABLE Doctor CASCADE CONSTRAINTS;
DROP TABLE Admission CASCADE CONSTRAINTS;
DROP TABLE Examine CASCADE CONSTRAINTS;
DROP TABLE StayIn CASCADE CONSTRAINTS;

*/


/* PHASE 3 START* /

/* Part 1: Views */

CREATE VIEW CriticalCases AS 
    Select SSN AS Patient_SSN, firstName, lastName, numberOfAdmissionsToICU 
    From Patient NATURAL JOIN ( 
        Select Patient_SSN AS SSN, Count(*) AS numberOfAdmissionsToICU 
        From Admission NATURAL JOIN ( 
            Select AdmissionNum AS ANum  
            From StayIn NATURAL JOIN ( 
                Select RoomNum 
                From RoomService 
                Where Service = 'ICU')) 
        Group By Patient_SSN) 
    Where numberOfAdmissionsToICU >= 2;


CREATE VIEW DoctorsLoad AS    
    Select ID as DoctorID, gender, 'Overloaded' AS load
    From Doctor NATURAL JOIN(
        Select DoctorID AS ID, Count(AdmissionNum) AS LoadNum
        From Examine
        Group By DoctorID)
    Where Loadnum > 10
    Union
        (Select ID as DoctorID, gender, 'Underloaded' AS load
        From Doctor NATURAL JOIN(
            Select DoctorID AS ID, Count(AdmissionNum) AS LoadNum
            From Examine
            Group By DoctorID)
        Where Loadnum <= 10);


Select *
From CriticalCases
Where numberOfAdmissionsToICU > 4;


Select ID, firstName, lastName
From Doctor D, DoctorsLoad L
Where D.ID = L.DoctorID
    AND
    D.gender = 'F'
    AND
    L.load = 'Overloaded';


Select D.DoctorID, C.Patient_SSN, Comments
From CriticalCases C, Admission A, Examine E, DoctorsLoad D
Where C.Patient_SSN = A.Patient_SSN
    AND
    A.ANum = E.AdmissionNum
    AND
    E.DoctorID = D.DoctorID
    AND
    D.load = 'Underloaded'; 
