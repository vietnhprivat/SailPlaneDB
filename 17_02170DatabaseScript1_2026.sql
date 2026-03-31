-- 4. SailPlane Database Schema

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

-- 5. Populate tables
INSERT INTO Airfield (AirfieldName, AirfieldAddress, RunwayMaterial, RunwayLength, RunwayDirection) VALUES
('Kalundborg Flyveplads', 'Eskebjergvej 101', 'Grass', 699, '09/27'),
('Arnborg Flyveplads', 'Flyvepladsvej 99', 'Grass', 1100, '11/29'),
('Svæveflyvecenter Nordsjælland', 'Hillerødsvej 150', 'Grass', 950, '10/28'),
('Stauning Lufthavn', 'Lufthavnsvej 1', 'Asphalt', 1400, '09/11');

INSERT INTO Club (ClubName, AirfieldName) VALUES
('Polyteknisk flyvegruppe', 'Kalundborg Flyveplads'),
('Herning Svæveflyveklub', 'Arnborg Flyveplads'),
('Nordsjællands Svæveflyveklub', 'Svæveflyvecenter Nordsjælland'),
('Ringkøbing Svæveflyveklub', 'Stauning Lufthavn');

INSERT INTO Members (MemberID, MemberName, MembershipType, State, ClubName) VALUES
(1, 'Joseph Nguyen', 'Student', TRUE, 'Polyteknisk flyvegruppe'),
(2, 'Viet Nguyen', 'Instructor', TRUE, 'Polyteknisk flyvegruppe'),
(3, 'Jakob Jensen', 'Student', TRUE, 'Herning Svæveflyveklub'),
(4, 'Zilas Aarestrup', 'Instructor', TRUE, 'Herning Svæveflyveklub'),
(5, 'Mads Sørensen', 'Solo', TRUE, 'Herning Svæveflyveklub'),
(6, 'Freja Holme', 'S-pilot', TRUE, 'Ringkøbing Svæveflyveklub'),
(7, 'Aisha Khan', 'Solo', TRUE, 'Nordsjællands Svæveflyveklub'),
(8, 'Lars Rørbek', 'S-pilot', FALSE, 'Polyteknisk flyvegruppe');

INSERT INTO Plane (Registration, PlaneType, FlightHours, CompetitionNumber) VALUES
('OY-X11', 'Glider', 1250.50, 'D11'),
('OY-X22', 'TMG', 3420.75, 'T22'),
('OY-X33', 'SLG', 890.20, 'S33'),
('OY-X44', 'SSG', 1575.00, 'G44'),
('OY-X55', 'Glider', 2105.40, 'K55');

INSERT INTO ClubOwnsPlane (ClubName, PlaneRegistration, OwnershipShare) VALUES
('Polyteknisk flyvegruppe', 'OY-X11', 1.00),
('Herning Svæveflyveklub', 'OY-X22', 1.00),
('Nordsjællands Svæveflyveklub', 'OY-X33', 1.00),
('Ringkøbing Svæveflyveklub', 'OY-X44', 0.50);

INSERT INTO MemberOwnsPlane (MemberID, PlaneRegistration, OwnershipShare) VALUES
(6, 'OY-X44', 0.50),
(7, 'OY-X55', 1.00);

INSERT INTO Flight (FlightID, PilotInCommandID, SecondaryPilotID, StartAirfieldName, EndAirfieldName, StartDateTime, StopDateTime, PlaneRegistration) VALUES
(1, 2, 1, 'Kalundborg Flyveplads', 'Kalundborg Flyveplads', '2026-03-10 09:15:00', '2026-03-10 09:42:00', 'OY-X11'),
(2, 4, 3, 'Arnborg Flyveplads', 'Arnborg Flyveplads', '2026-03-11 10:00:00', '2026-03-11 10:36:00', 'OY-X22'),
(3, 6, NULL, 'Stauning Lufthavn', 'Stauning Lufthavn', '2026-03-12 13:20:00', '2026-03-12 14:05:00', 'OY-X55'),
(4, 5, NULL, 'Arnborg Flyveplads', 'Arnborg Flyveplads', '2026-03-13 11:00:00', '2026-03-13 11:28:00', 'OY-X22'),
(5, 2, 1, 'Kalundborg Flyveplads', 'Kalundborg Flyveplads', '2026-03-15 14:10:00', '2026-03-15 14:48:00', 'OY-X11'),
(6, 4, 3, 'Arnborg Flyveplads', 'Arnborg Flyveplads', '2026-03-16 15:30:00', '2026-03-16 16:02:00', 'OY-X22');

INSERT INTO Exercise (FlightID, ExerciseType, Grade) VALUES
(1, 'A01', '2'),
(2, 'B02', '3'),
(5, 'C03', '1'),
(6, 'D04', '2');

INSERT INTO Theory (MemberID, Course, EligibilityTest, Exam, ExamDate) VALUES
(1, 'Luftfartsret', TRUE, FALSE, NULL),
(1, 'Meteorologi', TRUE, TRUE, '2024-03-26'),
(1, 'Navigation', TRUE, TRUE, '2024-03-26'),
(2, 'Meteorologi', TRUE, TRUE, '2023-03-26'),
(2, 'Luftfartsret', TRUE, TRUE, '2023-03-27'),
(2, 'Navigation', TRUE, TRUE, '2023-03-26'),
(2, 'Menneskelig præstationsevne', TRUE, TRUE, '2023-03-27'),
(2, 'Kommunikation', TRUE, TRUE, '2023-03-26'),
(2, 'Flyveprincipper', TRUE, TRUE, '2023-03-27'),
(2, 'Operationelle procedurer', TRUE, TRUE, '2023-03-26'),
(2, 'Flyvepræstationer og planlægning', TRUE, TRUE, '2023-03-26'),
(2, 'Generel viden om luftfartøjer', TRUE, TRUE, '2023-03-27'),
(3, 'Luftfartsret', TRUE, TRUE, '2026-03-26');

# View all tables
SELECT * FROM Airfield;
SELECT * FROM Club;
SELECT * FROM Members;
SELECT * FROM Plane;
SELECT * FROM Flight;
SELECT * FROM Exercise;
SELECT * FROM Theory;
SELECT * FROM ClubOwnsPlane;
SELECT * FROM MemberOwnsPlane;