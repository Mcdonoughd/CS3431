/*Phase 3 By Team 32 (Daniel McDonough & Talal Jaber)*/
/*desc tablename : This allows you to see the status of a query*/


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
    Where numberOfAdmissionsToICU >= 2;/


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
        Where Loadnum <= 10);/


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
CREATE TRIGGER CheckRoomServiceCount 
 BEFORE INSERT OR UPDATE 
 ON RoomService  
 Declare 
      serviceCount int;
Begin
      Select count(Service)  into serviceCount
      COUNT(Service), roomNum
	  FROM RoomService
	  GROUP BY roomNum;
      
     IF  serviceCount > 3  Then
	 RAISE_APPLICATION_ERROR(-20004, 'A Room Cannot Have more than 3  Services');
	 END IF;
END; /


/*The insurance payment should be calculated automatically as 70% of the total
payment. If the total payment changes then the insurance amount should also
change.*/
CREATE TRIGGER CalcInsurance
BEFORE INSERT OR UPDATE
ON Admission
BEGIN
:new.InsurancePayment := :new.TotalPayment * 0.70;
END;/

/*Ensure that regular employees (with rank 0) must have their supervisors as
division managers (with rank 1). Also each regular employee must have a
supervisor at all times. */
/*check if supervisor rank is not 1 or null*/
CREATE TRIGGER CHECKMANAGERS
BEFORE INSERT OR UPDATE ON Employees
BEGIN
	SELECT EmpID, EmpRank as BossRank
	FROM (SELECT EmpRank, EmpID, SupervisorID as BossID /*get supervisor id*/
	FROM Employees 
	Where :new.EmpID = EmpID && EmpRank = 0) 
	Where EmpID = BossID
	IF BossRank NOT = 1 OR BossRank = NULL then	
	RAISE_APPLICATION_ERROR(-20004, 'Employee has invalid supervisor');
	END IF
END;/

/* Before you delete a supervisor check if they have employees*/
CREATE TRIGGER CHECKSUPERVISEE
BEFORE DELETE ON Employees
BEGIN 
	SELECT count(EmpID) as supervided, SupervisorID From Employees
	Where :new.EmpRank = 0
	Group By SupervisorID
	IF supervided > 0 then
	RAISE_APPLICATION_ERROR(-200,'THE SUPERVISOR IS STILL SUPERVISING PEOPLE!');
	END IF
END;/


/* Similarly, division managers (with rank 1) must have their supervisors as general
managers (with rank 2). Division managers must have supervisors at all times.*/
CREATE TRIGGER CHECKGENMANAGERS
BEFORE INSERT OR UPDATE ON Employees
BEGIN
	SELECT EmpID, EmpRank as BossRank
	FROM (SELECT EmpRank, EmpID, SupervisorID as BossID /*get supervisor id*/
	FROM Employees 
	Where :new.EmpID = EmpID && EmpRank = 1) 
	Where EmpID = BossID;
	IF BossRank NOT = 2 OR BossRank = NULL then	
	RAISE_APPLICATION_ERROR(-20004, 'Employee has invalid supervisor');
	END IF
END;/

/* Before you delete a supervisor check if they have employees*/
CREATE TRIGGER CHECKDIVSUPERVISEE
BEFORE DELETE ON Employees
BEGIN 
	SELECT count(EmpID) as supervided, SupervisorID From Employees
	Where :new.EmpRank = 1
	Group By SupervisorID
	IF supervided > 0 then
	RAISE_APPLICATION_ERROR(-200,'THE SUPERVISOR IS STILL SUPERVISING PEOPLE!');
	END IF
END;/
	
/* When a patient is admitted to ICU room on date D, the futureVisitDate should be
automatically set to 3 months after that date, i.e., D + 3 months. The
futureVisitDate may be manually changed later, but when the ICU admission
happens, the date should be set to default as mentioned above. */

CREATE TRIGGER CHECKFutureVisit
AFTER INSERT ON Admission
BEGIN
	:old.FutureVisit := :old.AdmissionDate + INTERVAL '3' Month(1);
END;/

/* If an equipment of type ‘MRI’, then the purchase year must be not null and after
2005.*/
CREATE TRIGGER MRI2005CHECK
AFTER INSERT OR UPDATE ON Equipment
BEGIN
SELECT PurchaseYear,TypeID FROM Equipment
IF TypeID = 'MRI' AND (PurchaseYear > TO_DATE('2005') OR PurchaseYear = NULL)then
RAISE_APPLICATION_ERROR(-300,'MRI Machine can not be purchased after 2005 or null');
END IF
END;/

/* When a patient is admitted to the hospital, i.e., a new record is inserted into the
Admission table; the system should print out the names of the doctors who
previously examined this patient (if any).*/
CREATE TRIGGER
AFTER INSERT ON Admission
BEGIN
SELECT DISTINCT FirstName,LastName 
FROM Examine NATURAL Join Doctor NATURAL JOIN Admission 
WHERE :old.Patient_SSN = Patient_SSN
Group BY Patient_SSN
END;/












