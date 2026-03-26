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
    StudentPilotID   INT NOT NULL,
    Grade            ENUM('1', '2', '3'),
    InstructorID     INT NOT NULL,
    PRIMARY KEY (FlightID),
    FOREIGN KEY (FlightID) REFERENCES Flight(FlightID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (StudentPilotID) REFERENCES Members(MemberID)
        ON UPDATE CASCADE,
    FOREIGN KEY (InstructorID) REFERENCES Members(MemberID)
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Theory (
    MemberID           INT NOT NULL,
    Course             INT NOT NULL,
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