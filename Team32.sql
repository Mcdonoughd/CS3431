/*Phase 2 By Daniel McDonough & Talal Jaber*/
/*desc tablename : This allows you to see the status of a query*/
/*Part 1 CREATE TABLE*/



/*Employee*/
CREATE TABLE Employee(
	ID INTEGER NOT NULL PRIMARY KEY,
	FName CHAR(20) NOT NULL,
	LName CHAR(30) NOT NULL,
	Salary REAL NOT NULL,
	JobTitle CHAR(30) NOT NULL,
	OfficeNum CHAR(30) NOT NULL UNIQUE, /*Assume: B16 is an office, Employees cannot share office space */
	EmpRank INTEGER NOT NULL, /* employee is regular (rank = 0), division manager (rank = 1), or general manager (rank = 2) */
	SupervisorID INTEGER, /*General Managers dont have supervisors*/
	CONSTRAINT CHK_EmpRank CHECK (EmpRank = 0 OR EmpRank = 1 OR EmpRank = 2)
);

/*Room */
CREATE TABLE Room(
	Num INTEGER NOT NULL PRIMARY KEY,
	Occupied CHAR(1),
	CONSTRAINT CHK_Occupied CHECK (Occupied = 0 OR Occupied = 1)
); 

/*Equipment */
CREATE TABLE Equipment(
	Serial# INTEGER NOT NULL PRIMARY KEY,
	TypeID INTEGER NOT NULL UNIQUE,
	PurchaseYear DATE NOT NULL,
	LastInspetion DATE,
	RoomNum INTEGER NOT NULL,
	FOREIGN KEY (RoomNum) REFERENCES Room(Num)
);



/*EquipmentType */
CREATE TABLE EquipmentType (
	ID INTEGER NOT NULL PRIMARY KEY,
	Description CHAR(20), /*Who needs instructions? - can be NULL*/
	Model VARCHAR2(20) NOT NULL UNIQUE,
	Instructions CHAR(500), /*Who needs instructions? - can be NULL*/
	FOREIGN KEY (ID) REFERENCES Equipment(TypeID)
);

/*RoomService */
CREATE TABLE RoomService(
	RoomNum INTEGER NOT NULL PRIMARY KEY,
	Service CHAR(20) NOT NULL UNIQUE,
	FOREIGN KEY (RoomNum) REFERENCES Room(Num)
);

/*RoomAccess */
CREATE TABLE RoomAccess(
	RoomNum INTEGER NOT NULL,
	EmpID INTEGER NOT NULL,
	FOREIGN KEY (RoomNum) REFERENCES Room(Num),
	FOREIGN KEY (EmpID) REFERENCES Employee(ID)
);

/*Patient */
CREATE TABLE Patient(
	SSN INTEGER NOT NULL PRIMARY KEY,
	FirstName CHAR(20) NOT NULL,
	LastName CHAR(30) NOT NULL,
	Address VARCHAR2(30),
	TelNum INTEGER
);

/*Doctor */
CREATE TABLE Doctor(
	ID INTEGER NOT NULL PRIMARY KEY,
	FirstName CHAR(20) NOT NULL,
	LastName CHAR(30) NOT NULL,
	Gender CHAR(1),
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
	Patient_SSN INTEGER NOT NULL,
	FutureVisit Date, /*Patient doesnt need to have a future visit*/
	FOREIGN KEY (Patient_SSN) REFERENCES Patient(SSN)
);

/*Examine*/
CREATE TABLE Examine(
	DoctorID INTEGER NOT NULL,
	AdmissionNum INTEGER NOT NULL,
	Comments CHAR(200),
	FOREIGN KEY (DoctorID) REFERENCES Doctor(ID),
	FOREIGN KEY (AdmissionNum) REFERENCES Admission(ANum)
);

/*StayIn*/
CREATE TABLE StayIn(
	AdmissionNum INTEGER NOT NULL UNIQUE,
	RoomNum INTEGER NOT NULL UNIQUE,
	StartDate DATE NOT NULL PRIMARY KEY,
	EndDate DATE,
	FOREIGN KEY (RoomNum) REFERENCES Room(Num),
	FOREIGN KEY (AdmissionNum) REFERENCES Admission(ANum)
);

/*Begin Population!*/








/*DROP TABLES TO MAKE SURE EVERYTHING IS HUNKYDORY*/
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
DROP TABLE StayIn;








