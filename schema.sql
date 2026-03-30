-- SailPlane Database Schema

CREATE DATABASE IF NOT EXISTS SailPlane;
USE SailPlane;

DROP TABLE IF EXISTS MemberOwnsPlane;
DROP TABLE IF EXISTS ClubOwnsPlane;
DROP TABLE IF EXISTS Theory;
DROP TABLE IF EXISTS Exercise;
DROP TABLE IF EXISTS Flight;
DROP TABLE IF EXISTS Plane;
DROP TABLE IF EXISTS Members;
DROP TABLE IF EXISTS Club;
DROP TABLE IF EXISTS Airfield;

CREATE TABLE IF NOT EXISTS Airfield (
    AirfieldName     VARCHAR(50)  NOT NULL,
    AirfieldAddress  VARCHAR(50),
    RunwayMaterial   VARCHAR(30),
    RunwayLength     INT,
    RunwayDirection  VARCHAR(20),
    PRIMARY KEY (AirfieldName)
);

CREATE TABLE IF NOT EXISTS Club (
    ClubName         VARCHAR(50) NOT NULL,
    AirfieldName     VARCHAR(50) NOT NULL UNIQUE,
    PRIMARY KEY (ClubName),
    FOREIGN KEY (AirfieldName) REFERENCES Airfield(AirfieldName)
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Members (
    MemberID         INT AUTO_INCREMENT NOT NULL,
    MemberName       VARCHAR(50),
    MembershipType   ENUM('Student', 'Solo', 'S-pilot', 'Instructor'),
    State		     BOOLEAN,
    ClubName   VARCHAR(50) NOT NULL,
    PRIMARY KEY (MemberID),
    FOREIGN KEY (ClubName) REFERENCES Club(ClubName)
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Plane (
    Registration      CHAR(6)  NOT NULL,
    PlaneType         ENUM('TMG', 'Glider', 'SLG', 'SSG'),
    FlightHours       DECIMAL(6,2),
    CompetitionNumber VARCHAR(10),
    PRIMARY KEY (Registration)
);

CREATE TABLE IF NOT EXISTS Flight (
    FlightID           INT AUTO_INCREMENT  NOT NULL,
    PilotInCommandID   INT NOT NULL,
    SecondaryPilotID   INT,
    StartAirfieldName  VARCHAR(50) NOT NULL,
    EndAirfieldName    VARCHAR(50) NOT NULL,
    StartDateTime      DATETIME,
    StopDateTime       DATETIME,
    PlaneRegistration  CHAR(6) NOT NULL,
    PRIMARY KEY (FlightID),
    FOREIGN KEY (PilotInCommandID) REFERENCES Members(MemberID)
        ON UPDATE CASCADE,
    FOREIGN KEY (SecondaryPilotID) REFERENCES Members(MemberID)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (StartAirfieldName) REFERENCES Airfield(AirfieldName)
        ON UPDATE CASCADE,
    FOREIGN KEY (EndAirfieldName) REFERENCES Airfield(AirfieldName)
        ON UPDATE CASCADE,
    FOREIGN KEY (PlaneRegistration) REFERENCES Plane(Registration)
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Exercise (
    FlightID         INT NOT NULL,
    ExerciseType     VARCHAR(3),
    Grade            ENUM('1', '2', '3'),
    PRIMARY KEY (FlightID),
    FOREIGN KEY (FlightID) REFERENCES Flight(FlightID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Theory (
    MemberID           INT NOT NULL,
    Course             ENUM('Luftfartsret', 'Menneskelig præstationsevne', 'Meteorologi', 'Kommunikation', 'Flyveprincipper', 'Operationelle procedurer', 
    'Flyvepræstationer og planlægning', 'Generel viden om luftfartøjer', 'Navigation'),
    EligibilityTest    BOOLEAN,
    Exam               BOOLEAN,
    ExamDate           DATE,
    PRIMARY KEY (MemberID, Course),
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS ClubOwnsPlane (
    ClubName           VARCHAR(50)  NOT NULL,
    PlaneRegistration  CHAR(6)  NOT NULL,
    OwnershipShare     DECIMAL(4,2) CHECK (OwnershipShare >= 0 AND OwnershipShare <= 1),
    PRIMARY KEY (ClubName, PlaneRegistration),
    FOREIGN KEY (ClubName) REFERENCES Club(ClubName)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (PlaneRegistration) REFERENCES Plane(Registration)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS MemberOwnsPlane (
    MemberID           INT NOT NULL,
    PlaneRegistration  CHAR(6) NOT NULL,
    OwnershipShare     DECIMAL(4,2) CHECK (OwnershipShare >= 0 AND OwnershipShare <= 1),
    PRIMARY KEY (MemberID, PlaneRegistration),
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (PlaneRegistration) REFERENCES Plane(Registration)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


DROP VIEW IF EXISTS StudentFlights;
CREATE VIEW StudentFlights AS 
SELECT * FROM Members JOIN Flight ON Members.MemberID = Flight.SecondaryPilotID WHERE Members.MembershipType='Student';
SELECT * FROM StudentFlights;

SELECT * FROM Exercise JOIN StudentFlights ON Exercise.FlightID = StudentFlights.FlightID;
SELECT StartAirfieldName, Count(FlightID) as 'Number of flights' FROM Flight WHERE StartDateTime > NOW() - INTERVAL 1 MONTH GROUP BY StartAirfieldName HAVING Count(FlightID) < 3; 

DROP PROCEDURE IF EXISTS UpdateMemberTheoryExamAfterExpiration;
DELIMITER //
CREATE PROCEDURE UpdateMemberTheoryExamAfterExpiration(IN PilotID INT)
BEGIN
    SET @ExamsPassed = 0;
    SELECT COUNT(Exam) INTO @ExamsPassed FROM Theory WHERE MemberID = PilotID AND Exam = 1;
    
    IF @ExamsPassed = 9 THEN
		SET @NewestExamPassed = "2000-01-01";
        SELECT MAX(ExamDate) INTO @NewestExamPassed FROM Theory WHERE MemberID = PilotID AND Exam = 1;
        IF @NewestExamPassed < NOW() - INTERVAL 2 YEAR THEN
			UPDATE Theory SET Exam=FALSE, ExamDate=NULL WHERE MemberID = PilotID;
        END IF;
	ELSE
		Set @OldestExamPassed = "2000-01-01";
		SELECT MIN(ExamDate) INTO @OldestExamPassed FROM Theory WHERE MemberID = PilotID AND Exam = 1;
		IF @OldestExamPassed < NOW() - INTERVAL 18 MONTH THEN
			UPDATE Theory SET Exam=FALSE, ExamDate=NULL WHERE MemberID = PilotID;
		END IF;
    END IF;
END; //
DELIMITER ;

SELECT * FROM Theory;
CALL UpdateMemberTheoryExamAfterExpiration(2); # Newest exam more than 2 years old
SELECT * FROM Theory;
CALL UpdateMemberTheoryExamAfterExpiration(1); # Oldest exam more than 18 months old and not all passed
CALL UpdateMemberTheoryExamAfterExpiration(3); # Newly passed exam, shouldn't reset
SELECT * FROM Theory;


DROP FUNCTION IF EXISTS GetMemberTotalFlightHours;
DELIMITER //
CREATE FUNCTION GetMemberTotalFlightHours (vMemberID INT) RETURNS DECIMAL(8,2)
BEGIN
    DECLARE vTotalMinutes INT;
    SELECT COALESCE(SUM(TIMESTAMPDIFF(MINUTE, StartDateTime, StopDateTime)), 0)
    INTO vTotalMinutes
    FROM Flight
    WHERE PilotInCommandID = vMemberID OR SecondaryPilotID = vMemberID;
    RETURN ROUND(vTotalMinutes / 60.0, 2);
END//
DELIMITER ;

# Get flight hours for a specific member
SELECT GetMemberTotalFlightHours(1);

# Get flight hours for all members
SELECT MemberID, MemberName, GetMemberTotalFlightHours(MemberID) AS TotalFlightHours
FROM Members;

# Find all members with more than 2 flight hours
SELECT MemberID, MemberName, GetMemberTotalFlightHours(MemberID) AS TotalFlightHours
FROM Members
WHERE GetMemberTotalFlightHours(MemberID) > 2;




