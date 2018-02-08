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
	Occupied CHAR(1) NOT NULL,
	CONSTRAINT CHK_Occupied CHECK (Occupied = 0 OR Occupied = 1) /*UnOccupied = 0, Occupied = 1*/
); 

/*Equipment */
CREATE TABLE Equipment(
	Serial# INTEGER NOT NULL PRIMARY KEY,
	TypeID INTEGER NOT NULL,
	PurchaseYear DATE NOT NULL,
	LastInspetion DATE,
	RoomNum INTEGER NOT NULL,
	FOREIGN KEY (RoomNum) REFERENCES Room(Num)
);



/*EquipmentType */
CREATE TABLE EquipmentType (
	ID INTEGER NOT NULL PRIMARY KEY,
	Description CHAR(20), /*Who needs Descriptions? - can be NULL*/
	Model VARCHAR2(20) NOT NULL UNIQUE,
	Instructions CHAR(500), /*Who needs instructions? - can be NULL*/
	FOREIGN KEY (ID) REFERENCES Equipment(TypeID)
);

/*RoomService */
CREATE TABLE RoomService(
	RoomNum INTEGER NOT NULL,
	Service CHAR(20) NOT NULL,
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

/*PHASE3: Begin Population!*/

/*VALID Patients*/
INSERT INTO Patient(SSN,FirstName,LastName,Address,TelNum) VALUES('012345678','Dan','Kmemes','12 FarAway ST.','1234567890');
INSERT INTO Patient(SSN,FirstName,LastName,Address,TelNum) VALUES('987654321','Tabal','Prince','100 Institute RD','5855675309');
INSERT INTO Patient(SSN,FirstName,LastName,Address,TelNum) VALUES('123456780','King','Philip','30 Yes ST.','0123456789');
INSERT INTO Patient(SSN,FirstName,LastName,Address,TelNum) VALUES('036666059','John','Tavis','10 NoWHERE Blv.','1236547890');
INSERT INTO Patient(SSN,FirstName,LastName,Address,TelNum) VALUES('988774328','John','Doe','12 FarAway ST.','9874560321');
INSERT INTO Patient(SSN,FirstName,LastName,Address,TelNum) VALUES('765890254','Sally','Smith','12 FarAway ST.','0101010101');
INSERT INTO Patient(SSN,FirstName,LastName,Address,TelNum) VALUES('678543760','Sarah','Pipsi','12 FarAway ST.','1111110000');
INSERT INTO Patient(SSN,FirstName,LastName,Address,TelNum) VALUES('123796540','Eron','Steel','12 FarAway ST.','1111111111');
INSERT INTO Patient(SSN,FirstName,LastName,Address,TelNum) VALUES('192847452','Tabal','Prince','12 FarAway ST.','3336666999');
INSERT INTO Patient(SSN,FirstName,LastName) VALUES('000986132','Cave','Johnson');

/*VALID DOCTORS*/
INSERT INTO Doctor(ID,FirstName,LastName,Gender,Specialty) VALUES('1000','Patrick','Star','M','General');
INSERT INTO Doctor(ID,FirstName,LastName,Gender,Specialty) VALUES('1010','Santa','Clause','M','Stomach');
INSERT INTO Doctor(ID,FirstName,LastName,Gender,Specialty) VALUES('1020','Blake','Nelson','M','Brain');
INSERT INTO Doctor(ID,FirstName,LastName,Gender,Specialty) VALUES('1030','James','Paterson','M','General');
INSERT INTO Doctor(ID,FirstName,LastName,Gender,Specialty) VALUES('1040','Sarah','Burns','F','Leg');
INSERT INTO Doctor(ID,FirstName,LastName,Gender,Specialty) VALUES('1050','Joe','Shmoe','M','Hands');
INSERT INTO Doctor(ID,FirstName,LastName,Gender,Specialty) VALUES('1060','Kim','Possible','F','Heart');
INSERT INTO Doctor(ID,FirstName,LastName,Gender,Specialty) VALUES('1070','Jasmine','Lain','F','Hip');
INSERT INTO Doctor(ID,FirstName,LastName,Gender,Specialty) VALUES('1080','Ned','Stark','M','Head');
INSERT INTO Doctor(ID,FirstName,LastName,Gender,Specialty) VALUES('1090','Arya','Stark','F','Eyes');

/*Rooms*/
INSERT INTO Room(Num,Occupied) VALUES('101','0');
INSERT INTO Room(Num,Occupied) VALUES('102','1');
INSERT INTO Room(Num,Occupied) VALUES('105','0');
INSERT INTO Room(Num,Occupied) VALUES('106','0');
INSERT INTO Room(Num,Occupied) VALUES('103','1');
INSERT INTO Room(Num,Occupied) VALUES('104','1');
INSERT INTO Room(Num,Occupied) VALUES('108','0');
INSERT INTO Room(Num,Occupied) VALUES('109','1');
INSERT INTO Room(Num,Occupied) VALUES('107','0');
INSERT INTO Room(Num,Occupied) VALUES('110','1');

/*RoomService*/
INSERT INTO RoomService(RoomNum,Service) VALUES('102','MRI');
INSERT INTO RoomService(RoomNum,Service) VALUES('102','BloodTesting');
INSERT INTO RoomService(RoomNum,Service) VALUES('102','CATScan');
INSERT INTO RoomService(RoomNum,Service) VALUES('103','Cafeteria');
INSERT INTO RoomService(RoomNum,Service) VALUES('103','Dining');
INSERT INTO RoomService(RoomNum,Service) VALUES('103','Xray');
INSERT INTO RoomService(RoomNum,Service) VALUES('104','CPR');
INSERT INTO RoomService(RoomNum,Service) VALUES('104','MRI');

/*Equipment*/
INSERT INTO Equipment(Serial#,TypeID,PurchaseYear,LastInspetion,RoomNum) VALUES();


/*Look inside the tables*/
select * FROM Patient;
select * FROM Doctor;
select * FROM Room;
select * FROM Equipment;





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








