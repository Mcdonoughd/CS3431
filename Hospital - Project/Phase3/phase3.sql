/*Phase 3 By Team 32 (Daniel McDonough & Talal Jaber)*/
set serveroutput on;
DROP VIEW CriticalCases;
DROP VIEW DoctorsLoad;
DROP TRIGGER CheckRoomServiceCount;
DROP TRIGGER CalcInsurance;
DROP TRIGGER CHECKMANAGERS;
DROP TRIGGER CHECKDIVSUPERVISEE;
DROP TRIGGER CHECKGENMANAGERS;
DROP TRIGGER CHECKSUPERVISEE;
DROP TRIGGER CHECKFutureVisit;
DROP TRIGGER MRI2005CHECK;
DROP TRIGGER PREVDOC;


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
	
	
/*Part 2 TRIGGERS*/

/* Any room in the hospital cannot offer more than three services. */

CREATE OR REPLACE TRIGGER CheckRoomServiceCount 
 BEFORE INSERT OR UPDATE 
 ON RoomService
 FOR EACH ROW
 Declare 
      serviceCount INTEGER := 0;
Begin
      Select count(Service) into serviceCount
	  FROM RoomService
	 WHERE RoomNum = :new.RoomNum;
     IF serviceCount > 2  Then
	 RAISE_APPLICATION_ERROR(-20004, 'A Room Cannot Have more than 3  Services');
	 END IF;
END; 
/
Show errors;

/*The insurance payment should be calculated automatically as 70% of the total
payment. If the total payment changes then the insurance amount should also
change.*/
CREATE OR REPLACE TRIGGER CalcInsurance
BEFORE INSERT OR UPDATE
ON Admission
FOR EACH ROW
BEGIN
:new.InsurancePayment := :new.TotalPayment * 0.70;
END;
/
Show errors;
/*Ensure that regular employees (with rank 0) must have their supervisors as
division managers (with rank 1). Also each regular employee must have a
supervisor at all times. */
/*check if supervisor rank is not 1 or null*/
CREATE OR REPLACE TRIGGER CHECKMANAGERS
BEFORE INSERT OR UPDATE 
ON Employee
FOR EACH ROW
WHEN (new.EmpRank = 0)
DECLARE
   BossRank NUMBER := 1;
BEGIN 
    Select EmpRank INTO BossRank FROM Employee WHERE ID = :new.SupervisorID;
    IF(BossRank != 1) THEN
	RAISE_APPLICATION_ERROR(-20004, 'Employee of Rank 0 must have Supervisor of Rank 1');
	END IF;
END;
/
Show errors;

/* Before you delete a supervisor check if they have employees*/
CREATE OR REPLACE TRIGGER CHECKSUPERVISEE
BEFORE DELETE 
ON Employee 
FOR EACH ROW 
WHEN (old.EmpRank = 1)
DECLARE	
	SUPERVISEE INTEGER := 0;
BEGIN 
	SELECT COUNT(ID) INTO SUPERVISEE FROM Employee WHERE SupervisorID = :old.ID;
	IF SUPERVISEE > 0 then
	RAISE_APPLICATION_ERROR(-200,'This Person is still supervising people. Cannot Be Removed.');
	END IF;
END;
/
Show errors;
/* Similarly, division managers (with rank 1) must have their supervisors as general
managers (with rank 2). Division managers must have supervisors at all times.*/
CREATE OR REPLACE TRIGGER CHECKGENMANAGERS
BEFORE INSERT OR UPDATE 
ON Employee
FOR EACH ROW
WHEN (new.EmpRank = 1)
DECLARE
   BossRank NUMBER := 2;
BEGIN 
    Select EmpRank INTO BossRank FROM Employee WHERE ID = :new.SupervisorID;
    IF(BossRank != 2) THEN
	RAISE_APPLICATION_ERROR(-20004, 'Employee of Rank 1 must have Supervisor of Rank 2');
	END IF;
END;
/
Show errors;

/* Before you delete a supervisor check if they have employees*/
CREATE OR REPLACE TRIGGER CHECKDIVSUPERVISEE
BEFORE DELETE 
ON Employee 
FOR EACH ROW 
WHEN (old.EmpRank = 2)
DECLARE	
	SUPERVISEE INTEGER := 0;
BEGIN 
	SELECT COUNT(ID) INTO SUPERVISEE FROM Employee WHERE SupervisorID = :old.ID;
	IF SUPERVISEE > 0 then
	RAISE_APPLICATION_ERROR(-200,'This Person is still supervising people. Cannot Be Removed.');
	END IF;
END;
/	
Show errors;
/* When a patient is admitted to ICU room on date D, the futureVisitDate should be
automatically set to 3 months after that date, i.e., D + 3 months. The
futureVisitDate may be manually changed later, but when the ICU admission
happens, the date should be set to default as mentioned above. */

CREATE OR REPLACE TRIGGER CHECKFutureVisit
BEFORE INSERT 
ON Admission
FOR EACH ROW
DECLARE
	RmType varchar2(30);
BEGIN
	Select Service INTO RmType 
    From Patient NATURAL JOIN ( 
        Select Patient_SSN AS SSN, Service
        From Admission NATURAL JOIN ( 
            Select AdmissionNum AS ANum,Service  
            From StayIn NATURAL JOIN ( 
                Select RoomNum,Service 
                From RoomService 
                Where Service = 'ICU')) 
        Group By Patient_SSN)
		Where :old.Patient_SSN = :new.Patient_SSN;
IF(RmType='ICU')THEN
:new.FutureVisit:= :new.AdmissionDate + INTERVAL '3' Month;
END IF;
END;
/
Show errors;

/* If an equipment of description ‘MRI’, then the purchase year must be not null and after
2005.*/
CREATE OR REPLACE TRIGGER MRI2005CHECK
BEFORE INSERT OR UPDATE 
ON Equipment 
FOR EACH ROW
DECLARE
	EqType char(20);
BEGIN
SELECT EquipmentType.Description INTO EqType FROM
Equipment NATURAL JOIN EquipmentType
Where Equipment.PurchaseYear > TO_DATE('2005', 'yyyy');
IF (eqType = 'MRI') THEN
RAISE_APPLICATION_ERROR(-300,'MRI Machine can not be purchased after 2005 or null');
END IF;
END;
/
Show errors;
/* When a patient is admitted to the hospital, i.e., a new record is inserted into the
Admission table; the system should print out the names of the doctors who
previously examined this patient (if any).*/
CREATE OR REPLACE TRIGGER PREVDOC
Before INSERT 
ON Admission 
FOR EACH ROW 
DECLARE
	FullName varchar2(40);
BEGIN
SELECT CONCAT(D.FirstName, D.LastName) AS DocName INTO FullName
FROM Doctor D,Examine E,Admission A
WHERE A.ANum=E.AdmissionNum
AND E.DoctorID = D.ID
AND A.Patient_SSN = :new.Patient_SSN;
IF (FullName != NULL) THEN
dbms_output.put_line('Doctor: '||FullName);
END IF;
EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FullName := NULL;
END;
/
Show errors;






