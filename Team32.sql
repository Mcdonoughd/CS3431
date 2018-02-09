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
	FOREIGN KEY (TypeID) REFERENCES EquipmentType(ID)
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
	FutureVisit Date /*Patient doesnt need to have a future visit*/
	/*FOREIGN KEY (Patient_SSN) REFERENCES Patient(SSN)*/
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

/*Part 2: SQL Queries*/
 
/*1: This query is to select the room numbers of rooms that are currently occupied */
Select Num 
From Room 
Where Occupied = 1;

/* 2: This query is to select the ID, names, and salaries of regular employees that are supervised by a manager with a given ID */ 
Select ID, FName, LName, Salary 
From Employee 
Where SupervisorID = 700 
AND 
JobTitle = 'Regular Employee';

/* 3: This query is to select patients' social security numbers and sum of the amount paid by their insurance company for them */
Select Patient_SSN, Sum(InsurancePayment) AS Total    /* 3. Adds back in patients who had an insurance company pay for them with the right total values */
From Admission 
Group By Patient_SSN      
Union
    (Select SSN AS Patient_SSN, 0 AS Total           /* 1. Reports all patients*/      
    From Patient      
    Minus 
        (Select Patient_SSN, 0 AS Total              /* 2. Removes patients who have had an insurance company pay for them */ 
        From Admission));        

/* 4: This query is to select patients' social security numbers, names, and number of visits */
Select SSN, FirstName, LastName, Visits             /* 3. Addds back in patiens who have made visits with the right values */ 
From Patient NATURAL JOIN (                        
    Select Patient_SSN AS SSN, Count(*) AS Visits 
    From Admission 
    Group By Patient_SSN)
Union
    (Select SSN, FirstName, LastName, 0 AS Visits  /* 1. Reports all patients*/
    From Patient               
    Minus
        (Select SSN, FirstName, LastName, Visits   /* 2. Removes patients who have made visits */
        From Patient NATURAL JOIN (     
            Select Patient_SSN AS SSN, 0 AS Visits 
            From Admission)));
    
/* 5: This query is to select room numbers of rooms with equipment units of the serial number 'A01-02X' */
Select RoomNum 
From Equipment 
Where Serial# = 'A01-02X';

/* 6: This query is to select the ID of employees who can acces the largest number of rooms */
Select EmpID, Max(Rooms)
From
    (Select EmpID, Count(RoomNum) AS Rooms
    From RoomAccess
    Group By EmpID)
Group By EmpID;

/* 7: This query is to select the number of regular employees, division managers, and general managers in the hospital */
Select JobTitle AS Type, Count(JobTitle) AS Count 
From Employee 
Group By JobTitle;

/* 8: This query is to select the social security numbers, names, and visit dates of patients with future visits */
Select SSN, FirstName, LastName, FutureVisit
From Patient NATURAL JOIN (
    Select Patient_SSN as SSN, FutureVisit
    From Admission);

/* 9: This query is to select the ID, models, and number of units of equipment typs with more than 3 units */
Select ID, Model, Units
From EquipmentType NATURAL JOIN (
    Select TypeID AS ID, Count(*) as Units
    From Equipment
    Group By TypeID)    
Where Units > 3;

/* 10: This query selects the date of the coming future visit for the patent with the social security number of 111-22-3333 */
Select Max(FutureVisit)
From Admission
Where Patient_SSN = '111-22-3333';

/* 11: This query selects the ID of the doctors who have examined the patient with the social security number of 111-22-3333 more than twice */
Select DoctorID
From
    (Select DoctorID, Count(AdmissionNum) as Examinations
    From Examine NATURAL JOIN (
        Select ANum AS AdmissionNum
        From Admission
        Where Patient_SSN = '111-22-3333')
    Group By DoctorID)
Where Examinations > 2;

/* 12: This query is to select the ID of the equipment types for which units were purchased in both 2010 and 2011 */
Select TypeID
From Equipment
Where PurchaseYear = TO_DATE('2010', 'yyyy')
Union
    (Select TypeID
    From Equipment
    Where PurchaseYear = TO_DATE('2011', 'yyyy'));

/*PHASE3: Begin Population!*/

/*VALID Patients*/
INSERT INTO Patient(SSN,FirstName,LastName,Address,TelNum) VALUES('012-34-5678','Dan','Kmemes','12 FarAway ST.','(123)-456-7890');
INSERT INTO Patient(SSN,FirstName,LastName,Address,TelNum) VALUES('123-45-6789','Tabal','Prince','100 Institute RD.','(585)-567-5309');
INSERT INTO Patient(SSN,FirstName,LastName,Address,TelNum) VALUES('123-45-6780','King','Philip','30 Yes ST.','(012)-345-6789');
INSERT INTO Patient(SSN,FirstName,LastName,Address,TelNum) VALUES('036-66-6059','John','Tavis','10 NoWHERE BLV.','(123)-654-7890');
INSERT INTO Patient(SSN,FirstName,LastName,Address,TelNum) VALUES('988-77-4328','John','Doe','12 FarAway ST.','(987)-456-0321');
INSERT INTO Patient(SSN,FirstName,LastName,Address,TelNum) VALUES('765-89-0254','Sally','Smith','12 FarAway ST.','(010)-101-0101');
INSERT INTO Patient(SSN,FirstName,LastName,Address,TelNum) VALUES('678-54-3760','Sarah','Pipsi','12 FarAway ST.','(111)-111-0000');
INSERT INTO Patient(SSN,FirstName,LastName,Address,TelNum) VALUES('123-79-6540','Eron','Steel','12 FarAway ST.','(111)-111-1111');
INSERT INTO Patient(SSN,FirstName,LastName,Address,TelNum) VALUES('192-847-452','Tabal','Prince','12 FarAway ST.','(333)-666-6999');
INSERT INTO Patient(SSN,FirstName,LastName,Address,TelNum) VALUES('000-98-6132','Cave','Johnson','50 Jazz RD','(000)-000-0000');

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

/*EquipmentType*/
INSERT INTO EquipmentType(ID,Description,Model,Instructions) VALUES('3000','SUPER COOL','A','DO IT YOURSELF');
INSERT INTO EquipmentType(ID,Description,Model,Instructions) VALUES('4000','AMAZING','B','CALL IKEA');
INSERT INTO EquipmentType(ID,Description,Model,Instructions) VALUES('5000','KINDA GOOD','C','');
 

/*Equipment*/
INSERT INTO Equipment(Serial#,TypeID,PurchaseYear,LastInspetion,RoomNum) VALUES('ABD123','3000',TO_DATE('2003', 'yyyy'),TO_DATE('2003/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),'101');
INSERT INTO Equipment(Serial#,TypeID,PurchaseYear,LastInspetion,RoomNum) VALUES('ABDC1234','3000',TO_DATE('2003', 'yyyy'),TO_DATE('2003/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),'105');
INSERT INTO Equipment(Serial#,TypeID,PurchaseYear,LastInspetion,RoomNum) VALUES('ABC123','3000',TO_DATE('2003', 'yyyy'),TO_DATE('2003/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),'107');
INSERT INTO Equipment(Serial#,TypeID,PurchaseYear,LastInspetion,RoomNum) VALUES('XYZ789','4000',TO_DATE('2004', 'yyyy'),TO_DATE('2003/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),'102');
INSERT INTO Equipment(Serial#,TypeID,PurchaseYear,LastInspetion,RoomNum) VALUES('XYZ000','4000',TO_DATE('2004', 'yyyy'),TO_DATE('2003/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),'103');
INSERT INTO Equipment(Serial#,TypeID,PurchaseYear,LastInspetion,RoomNum) VALUES('XYZ999','4000',TO_DATE('2004', 'yyyy'),TO_DATE('2003/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),'104');
INSERT INTO Equipment(Serial#,TypeID,PurchaseYear,LastInspetion,RoomNum) VALUES('JKL456','5000',TO_DATE('2005', 'yyyy'),TO_DATE('2003/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),'109');
INSERT INTO Equipment(Serial#,TypeID,PurchaseYear,LastInspetion,RoomNum) VALUES('JKLQRS','5000',TO_DATE('2005', 'yyyy'),TO_DATE('2003/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),'101');
INSERT INTO Equipment(Serial#,TypeID,PurchaseYear,LastInspetion,RoomNum) VALUES('555JKS','5000',TO_DATE('2005', 'yyyy'),TO_DATE('2003/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),'109');


/*Admission*/
INSERT INTO Admission(ANum,AdmissionDate,LeaveDate,TotalPayment,InsurancePayment,Patient_SSN,FutureVisit) VALUES('1',TO_DATE('2003/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),TO_DATE('2003/05/05 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),'1000','0','123-45-6789',TO_DATE('2004/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'));
INSERT INTO Admission(ANum,AdmissionDate,LeaveDate,TotalPayment,InsurancePayment,Patient_SSN,FutureVisit) VALUES('2',TO_DATE('2013/09/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),TO_DATE('2003/05/05 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),'1000','0','123-45-6789',TO_DATE('2004/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'));
INSERT INTO Admission(ANum,AdmissionDate,LeaveDate,TotalPayment,InsurancePayment,Patient_SSN,FutureVisit) VALUES('3',TO_DATE('2007/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),TO_DATE('2003/05/05 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),'1000','0','123-45-6789',TO_DATE('2004/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'));
INSERT INTO Admission(ANum,AdmissionDate,LeaveDate,TotalPayment,InsurancePayment,Patient_SSN,FutureVisit) VALUES('4',TO_DATE('2006/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),TO_DATE('2003/05/05 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),'1000','0','123-45-6789',TO_DATE('2004/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'));
INSERT INTO Admission(ANum,AdmissionDate,LeaveDate,TotalPayment,InsurancePayment,Patient_SSN,FutureVisit) VALUES('5',TO_DATE('2005/06/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),TO_DATE('2003/05/05 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),'1000','0','123-45-6789',TO_DATE('2004/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'));
INSERT INTO Admission(ANum,AdmissionDate,LeaveDate,TotalPayment,InsurancePayment,Patient_SSN,FutureVisit) VALUES('6',TO_DATE('2002/08/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),TO_DATE('2003/05/05 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),'1000','0','123-45-6789',TO_DATE('2004/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'));
INSERT INTO Admission(ANum,AdmissionDate,LeaveDate,TotalPayment,InsurancePayment,Patient_SSN,FutureVisit) VALUES('7',TO_DATE('2003/03/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),TO_DATE('2003/05/05 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),'1000','0','123-45-6789',TO_DATE('2004/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'));
INSERT INTO Admission(ANum,AdmissionDate,LeaveDate,TotalPayment,InsurancePayment,Patient_SSN,FutureVisit) VALUES('8',TO_DATE('2003/04/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),TO_DATE('2003/05/05 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),'1000','0','123-45-6789',TO_DATE('2004/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'));
INSERT INTO Admission(ANum,AdmissionDate,LeaveDate,TotalPayment,InsurancePayment,Patient_SSN,FutureVisit) VALUES('9',TO_DATE('2003/04/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),TO_DATE('2003/05/05 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),'1000','0','123-45-6789',TO_DATE('2004/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'));
INSERT INTO Admission(ANum,AdmissionDate,LeaveDate,TotalPayment,InsurancePayment,Patient_SSN,FutureVisit) VALUES('10',TO_DATE('2003/02/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),TO_DATE('2003/05/05 21:02:44', 'yyyy/mm/dd hh24:mi:ss'),'1000','0','123-45-6789',TO_DATE('2004/05/03 21:02:44', 'yyyy/mm/dd hh24:mi:ss'));

/*Employee*/
INSERT INTO Employee(ID,FName,LName,Salary,JobTitle,OfficeNum,EmpRank,SupervisorID) VALUES('600','Josh','Pickles','10.00','Regular Employee','101','0','700');
INSERT INTO Employee(ID,FName,LName,Salary,JobTitle,OfficeNum,EmpRank,SupervisorID) VALUES('601','Surya','Leman','10.00','Regular Employee','102','0','700');
INSERT INTO Employee(ID,FName,LName,Salary,JobTitle,OfficeNum,EmpRank,SupervisorID) VALUES('602','Kistan','Hilbert','10.00','Regular Employee','103','0','700');
INSERT INTO Employee(ID,FName,LName,Salary,JobTitle,OfficeNum,EmpRank,SupervisorID) VALUES('603','Mansa','Yao','10.00','Regular Employee','104','0','701');
INSERT INTO Employee(ID,FName,LName,Salary,JobTitle,OfficeNum,EmpRank,SupervisorID) VALUES('604','Ralph','Jones','10.00','Regular Employee','105','0','701');
INSERT INTO Employee(ID,FName,LName,Salary,JobTitle,OfficeNum,EmpRank,SupervisorID) VALUES('605','Jen','Rulon','10.00','Regular Employee','106','0','701');
INSERT INTO Employee(ID,FName,LName,Salary,JobTitle,OfficeNum,EmpRank,SupervisorID) VALUES('606','Josh','Conte','10.00','Regular Employee','107','0','702');
INSERT INTO Employee(ID,FName,LName,Salary,JobTitle,OfficeNum,EmpRank,SupervisorID) VALUES('607','Anthony','Poreloo','10.00','Regular Employee','108','0','702');
INSERT INTO Employee(ID,FName,LName,Salary,JobTitle,OfficeNum,EmpRank,SupervisorID) VALUES('608','Lily','Coie','10.00','Regular Employee','109','0','703');
INSERT INTO Employee(ID,FName,LName,Salary,JobTitle,OfficeNum,EmpRank,SupervisorID) VALUES('609','Sam','Smith','10.00','Regular Employee','110','0','703');

INSERT INTO Employee(ID,FName,LName,Salary,JobTitle,OfficeNum,EmpRank,SupervisorID) VALUES('700','Jona','Smos','12.00','Division Manager','111','1','800');
INSERT INTO Employee(ID,FName,LName,Salary,JobTitle,OfficeNum,EmpRank,SupervisorID) VALUES('701','Kim','Pasta','12.00','Division Manager','112','1','800');
INSERT INTO Employee(ID,FName,LName,Salary,JobTitle,OfficeNum,EmpRank,SupervisorID) VALUES('702','Tom','Brady','12.00','Division Manager','113','1','801');
INSERT INTO Employee(ID,FName,LName,Salary,JobTitle,OfficeNum,EmpRank,SupervisorID) VALUES('703','Rose','Low','12.00','Division Manager','114','1','801');

INSERT INTO Employee(ID,FName,LName,Salary,JobTitle,OfficeNum,EmpRank) VALUES('800','Bill','Gates','15.00','General Manager','200','2');
INSERT INTO Employee(ID,FName,LName,Salary,JobTitle,OfficeNum,EmpRank) VALUES('801','Franca','Pheonix','15.00','General Manager','201','2');



/*

Look inside the tables */
select * FROM Patient;
select * FROM Doctor;
select * FROM Room;
select * FROM EquipmentType;
select * FROM Equipment;
select * FROM Admission;
select * FROM Employee;


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







