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