-- SailPlane Database Schema

CREATE DATABASE IF NOT EXISTS sailplane;

CREATE TABLE IF NOT EXISTS Airfield (
    AirfieldName     VARCHAR(50)  NOT NULL,
    Address          VARCHAR(50),
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

CREATE TABLE IF NOT EXISTS Member (
    MemberID         INT AUTO_INCREMENT NOT NULL,
    MemberName       VARCHAR(50),
    MembershipType   ENUM('Student', 'Solo', 'S-pilot', 'Instructor'),
    State		     BOOLEAN,
    FlightclubName   VARCHAR(50) NOT NULL,
    PRIMARY KEY (MemberID),
    FOREIGN KEY (FlightclubName) REFERENCES Club(ClubName)
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
    FOREIGN KEY (PilotInCommandID) REFERENCES Member(MemberID)
        ON UPDATE CASCADE,
    FOREIGN KEY (SecondaryPilotID) REFERENCES Member(MemberID)
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
    FOREIGN KEY (StudentPilotID) REFERENCES Member(MemberID)
        ON UPDATE CASCADE,
    FOREIGN KEY (InstructorID) REFERENCES Member(MemberID)
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Theory (
    MemberID           INT NOT NULL,
    Course             INT NOT NULL,
    EligibilityTest    BOOLEAN,
    Exam               BOOLEAN,
    ExamDate           DATE,
    PRIMARY KEY (MemberID, Course),
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS ClubOwnsPlane (
    ClubName           VARCHAR(50)  NOT NULL,
    PlaneRegistration  CHAR(6)  NOT NULL,
    OwnershipShare     DECIMAL(4,2) CHECK (Share >= 0 AND Share <= 1),
    PRIMARY KEY (ClubName, PlaneRegistration),
    FOREIGN KEY (ClubName) REFERENCES Club(ClubName)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (PlaneRegistration) REFERENCES Plane(Registration)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS MemberOwnsPlane (
    MemberID           CHAR(8)  NOT NULL,
    PlaneRegistration  CHAR(6) NOT NULL,
    OwnershipShare     DECIMAL(4,2) CHECK (Share >= 0 AND Share <= 1),
    PRIMARY KEY (MemberID, PlaneRegistration),
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (PlaneRegistration) REFERENCES Plane(Registration)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);