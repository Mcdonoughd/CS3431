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
	CONSTRAINT CHK_EmpRank CHECK (EmpRank == '0' OR EmpRank == '1' OR EmpRank == '2')
);

/*Room */
CREATE TABLE Room(
	Num INTEGER NOT NULL PRIMARY KEY,
	Occupied BOOLEAN
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
	Description DESCRIBE, /*Who needs instructions? - can be NULL*/
	Model VARCHAR2(20) NOT NULL UNIQUE,
	Instructions CHAR(500), /*Who needs instructions? - can be NULL*/
	FOREIGN KEY (ID) REFERENCES Equipment(TypeID)
);



/*RoomService */
CREATE TABLE RoomService(
	RoomNum INTEGER NOT NULL PRIMARY KEY,
	Service CHAR(20) NOT NULL PRIMARY KEY,
	FOREIGN KEY (RoomNum) REFERENCES Room(Num)
);

/*RoomAccess */
CREATE TABLE RoomAccess(
	RoomNum INTEGER NOT NULL PRIMARY KEY,
	EmpID INTEGER NOT NULL PRIMARY KEY,
	FOREIGN KEY (RoomNum) REFERENCES Room(Num)
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
	Gender BOOLEAN,
	Specialty CHAR(20) NOT NULL /*ASSUME SPECIALTY CAN BE LABLED AS GENERAL*/
);

/*Admission */
CREATE TABLE Admission(
	Num INTEGER NOT NULL PRIMARY KEY,
	AdmissionDate DATE NOT NULL,
	LeaveDate DATE, /*Assume leave date is not pre-scheduled*/
	TotalPayment REAL NOT NULL,
	InsurancePayment REAL, /*Assume patient can have null insurance*/
	Patient_SSN INTEGER NOT NULL,
	FutureVisit Date, /*Patient doesnt need to have a future visit*/
	FOREIGN KEY Patient_SSN REFERENCES Patient(SSN)
);

/*Examine*/
CREATE TABLE Examine(
	DoctorID INTEGER NOT NULL PRIMARY KEY,
	AdmissionNum INTEGER NOT NULL PRIMARY KEY,
	Comment CHAR(200),
	FOREIGN KEY DoctorID REFERENCES Doctor(ID),
	FOREIGN KEY AdmissionNum REFERENCES Admission(Num)
);

/*StayIn*/
CREATE TABLE StayIn(
	AdmissionNum INTEGER NOT NULL PRIMARY KEY,
	RoomNum INTEGER NOT NULL PRIMARY KEY,
	StartDate DATE NOT NULL PRIMARY KEY,
	EndDate DATE,
	FOREIGN KEY RoomNum REFERENCES Room(Num),
	FOREIGN KEY AdmissionNum REFERENCES Admission(Num)
);


