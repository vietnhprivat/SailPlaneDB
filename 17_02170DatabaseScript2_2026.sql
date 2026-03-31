-- 6.3 IN
SELECT Registration, PlaneType FROM Plane
WHERE Registration NOT IN (
SELECT PlaneRegistration FROM Flight
);

-- 7.1 Function
DROP FUNCTION IF EXISTS GetMemberTotalFlightHours;
DELIMITER //
CREATE FUNCTION GetMemberTotalFlightHours (vMemberID INT) RETURNS DECIMAL(8,2)
BEGIN
    DECLARE vTotalMinutes INT;
    SELECT COALESCE(
        SUM(TIMESTAMPDIFF(MINUTE, StartDateTime, StopDateTime)),0)
    INTO vTotalMinutes
    FROM Flight
    WHERE PilotInCommandID = vMemberID OR SecondaryPilotID = vMemberID;
    RETURN ROUND(vTotalMinutes / 60.0, 2);
END//
DELIMITER ;

-- Testing function
# 1. Get flight hours for a specific member
SELECT GetMemberTotalFlightHours(1);

# 2. Get flight hours for all members
SELECT MemberID, MemberName, GetMemberTotalFlightHours(MemberID) AS TotalFlightHours
FROM Members;

# 3. Find all members with more than 1 flight hour
SELECT MemberID, MemberName, GetMemberTotalFlightHours(MemberID) AS TotalFlightHours
FROM Members
WHERE GetMemberTotalFlightHours(MemberID) > 1;

-- 7.2 Trigger
DROP TRIGGER IF EXISTS StudentTheoryInit;

DELIMITER //
CREATE TRIGGER StudentTheoryInit
AFTER INSERT ON Members
FOR EACH ROW
BEGIN
    IF NEW.MembershipType = 'Student' THEN
        INSERT INTO Theory (MemberID, Course, EligibilityTest, Exam, ExamDate) VALUES
        (NEW.MemberID, 'Luftfartsret', FALSE, FALSE, NULL),
        (NEW.MemberID, 'Menneskelig præstationsevne', FALSE, FALSE, NULL),
        (NEW.MemberID, 'Meteorologi', FALSE, FALSE, NULL),
        (NEW.MemberID, 'Kommunikation', FALSE, FALSE, NULL),
        (NEW.MemberID, 'Flyveprincipper', FALSE, FALSE, NULL),
        (NEW.MemberID, 'Operationelle procedurer', FALSE, FALSE, NULL),
        (NEW.MemberID, 'Flyvepræstationer og planlægning', FALSE, FALSE, NULL),
        (NEW.MemberID, 'Generel viden om luftfartøjer', FALSE, FALSE, NULL),
        (NEW.MemberID, 'Navigation', FALSE, FALSE, NULL);
    END IF;
END //
DELIMITER ;

-- Testing the trigger
SELECT * FROM THEORY; # 1. Before trigger

INSERT INTO Members (MemberName, MembershipType, State, ClubName) VALUES
('Kasper Dolberg', 'Student', True, 'Polyteknisk flyvegruppe');

SELECT * FROM THEORY; # 2. After trigger

-- 7.3 Procedure
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
END //
DELIMITER ;

-- Testing procedure
SELECT * FROM Theory; # 1
CALL UpdateMemberTheoryExamAfterExpiration(2); # Newest exam more than 2 years old
SELECT * FROM Theory; # 2
CALL UpdateMemberTheoryExamAfterExpiration(1); # Oldest exam more than 18 months old and not all passed
CALL UpdateMemberTheoryExamAfterExpiration(3); # Newly passed exam
SELECT * FROM Theory; # 3

-- 8.1 Update statement
SELECT MemberID, MemberName, MembershipType FROM Members WHERE MemberID = 5;

-- Applying update to member 5 after passed exam
UPDATE Members SET MembershipType = 'S-pilot' WHERE MemberID = 5;

SELECT MemberID, MemberName, MembershipType FROM Members WHERE MemberID = 5;

-- 8.2 Delete statement
-- Case: Member 6 sells their 50% share of OY-X44 to Ringkøbing Svæveflyveklub. First the before
SELECT 'Member' AS OwnerType, MemberID AS Owner, OwnershipShare FROM MemberOwnsPlane WHERE PlaneRegistration = 'OY-X44'
UNION
SELECT 'Club', ClubName, OwnershipShare FROM ClubOwnsPlane WHERE PlaneRegistration = 'OY-X44';

-- Delete ownership share, and update share of others.
DELETE FROM MemberOwnsPlane WHERE MemberID = 6 AND PlaneRegistration = 'OY-X44';
UPDATE ClubOwnsPlane SET OwnershipShare = 1.00 WHERE ClubName = 'Ringkøbing Svæveflyveklub' AND PlaneRegistration = 'OY-X44';

-- Then run same UNION select statement above.