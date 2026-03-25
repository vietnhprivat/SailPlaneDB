-- SailPlane Database Schema

CREATE TABLE IF NOT EXISTS Airfield (
    Name            VARCHAR(50)  NOT NULL,
    Address         VARCHAR(100),
    RunwayMaterial  VARCHAR(30),
    RunwayLength    INT,
    RunwayDirection VARCHAR(20),
    PRIMARY KEY (Name)
);

CREATE TABLE IF NOT EXISTS Club (
    Name         VARCHAR(50) NOT NULL,
    AirfieldName VARCHAR(50) NOT NULL UNIQUE,
    PRIMARY KEY (Name),
    FOREIGN KEY (AirfieldName) REFERENCES Airfield(Name)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Member (
    ID             VARCHAR(8)  NOT NULL,
    Name           VARCHAR(50),
    State          ENUM('Student', 'S-pilot', 'Instructor'),
    MembershipType VARCHAR(30),
    FlightclubName VARCHAR(50) NOT NULL,
    PRIMARY KEY (ID),
    FOREIGN KEY (FlightclubName) REFERENCES Club(Name)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Plane (
    Registration      VARCHAR(15)  NOT NULL,
    Type              VARCHAR(30),
    FlightHours       DECIMAL(8,1),
    CompetitionNumber VARCHAR(10),
    PRIMARY KEY (Registration)
);

CREATE TABLE IF NOT EXISTS Flight (
    ID                VARCHAR(8)  NOT NULL,
    PilotInCommandID  VARCHAR(8)  NOT NULL,
    SecondaryPilotID  VARCHAR(8),
    StartAirfieldName VARCHAR(50) NOT NULL,
    EndAirfieldName   VARCHAR(50) NOT NULL,
    StartDateTime     DATETIME,
    StopDateTime      DATETIME,
    PlaneRegistration VARCHAR(15) NOT NULL,
    PRIMARY KEY (ID),
    FOREIGN KEY (PilotInCommandID)  REFERENCES Member(ID)
        ON DELETE RESTRICT  ON UPDATE CASCADE,
    FOREIGN KEY (SecondaryPilotID)  REFERENCES Member(ID)
        ON DELETE SET NULL  ON UPDATE CASCADE,
    FOREIGN KEY (StartAirfieldName) REFERENCES Airfield(Name)
        ON DELETE RESTRICT  ON UPDATE CASCADE,
    FOREIGN KEY (EndAirfieldName)   REFERENCES Airfield(Name)
        ON DELETE RESTRICT  ON UPDATE CASCADE,
    FOREIGN KEY (PlaneRegistration) REFERENCES Plane(Registration)
        ON DELETE RESTRICT  ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Exercise (
    FlightID       VARCHAR(8)  NOT NULL,
    ExerciseType   VARCHAR(50),
    StudentPilotID VARCHAR(8)  NOT NULL,
    Grade          VARCHAR(20),
    InstructorID   VARCHAR(8)  NOT NULL,
    PRIMARY KEY (FlightID),
    FOREIGN KEY (FlightID)       REFERENCES Flight(ID)
        ON DELETE CASCADE  ON UPDATE CASCADE,
    FOREIGN KEY (StudentPilotID) REFERENCES Member(ID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (InstructorID)   REFERENCES Member(ID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Theory (
    MemberID          VARCHAR(8) NOT NULL,
    Course            INT        NOT NULL,
    Indstillingsprove BOOLEAN,
    Exam              BOOLEAN,
    ExamDate          DATE,
    PRIMARY KEY (MemberID, Course),
    FOREIGN KEY (MemberID) REFERENCES Member(ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS ClubOwnsPlane (
    ClubName          VARCHAR(50)  NOT NULL,
    PlaneRegistration VARCHAR(15)  NOT NULL,
    Share             DECIMAL(5,2),
    PRIMARY KEY (ClubName, PlaneRegistration),
    FOREIGN KEY (ClubName)          REFERENCES Club(Name)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (PlaneRegistration) REFERENCES Plane(Registration)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS MemberOwnsPlane (
    MemberID          VARCHAR(8)  NOT NULL,
    PlaneRegistration VARCHAR(15) NOT NULL,
    Share             DECIMAL(5,2),
    PRIMARY KEY (MemberID, PlaneRegistration),
    FOREIGN KEY (MemberID)          REFERENCES Member(ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (PlaneRegistration) REFERENCES Plane(Registration)
        ON DELETE CASCADE ON UPDATE CASCADE
);
