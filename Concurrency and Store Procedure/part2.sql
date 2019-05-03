-- Part 2 stored procedure
DELIMITER $$ 
CREATE PROCEDURE `switchSection`(in courseID varchar(8), in section1 int, in section2 int, in termCode decimal(4), in quantity int, out errorCode int)
    BEGIN
    
    -- initialize variables
    DECLARE enrollmentSection1 INT;
    DECLARE enrollmentSection2 INT;
    DECLARE capacity_new INT;
    
    -- potential updates to database
    IF ((NOT EXISTS (SELECT * FROM Offering WHERE Offering.courseID = courseID AND (Offering.section = section1 OR Offering.section = section2) AND Offering.termCode = termCode)) OR (quantity <= 0) OR (section1 = section2)) THEN
        SET errorCode = -1;
    ELSE
        UPDATE Offering SET enrollment = enrollment - quantity WHERE Offering.section = section1 AND Offering.courseID = courseID AND Offering.termCode = termCode;
        UPDATE Offering SET enrollment = enrollment + quantity WHERE Offering.section = section2 AND Offering.courseID = courseID AND Offering.termCode = termCode;
    END IF;
    
    -- assign value to variables 
    SET enrollmentSection1 = (SELECT enrollment FROM Offering WHERE Offering.section = section1 AND Offering.courseID = courseID AND Offering.termCode = termCode);
    SET enrollmentSection2 = (SELECT enrollment FROM Offering WHERE Offering.section = section2 AND Offering.courseID = courseID AND Offering.termCode = termCode);
    SET capacity_new = (SELECT capacity FROM Classroom INNER JOIN Offering ON Classroom.roomID = Offering.roomID WHERE Offering.courseID = courseID AND Offering.section = section2 AND Offering.termCode = termCode);
    
    -- handling different cases
    IF (errorCode = -1) THEN
        ROLLBACK;
    ELSEIF (enrollmentSection1 < 0) THEN
        SET errorCode = -2;
        ROLLBACK;
    ELSEIF (enrollmentSection2 > capacity_new) THEN
        SET errorCode = -3;
        ROLLBACK;
    ELSE
        SET errorCode = 0;
        COMMIT;
    END IF;
    
    -- reture value
    SELECT errorCode;
    -- SELECT enrollmentSection1;
    -- SELECT enrollmentSection2;
END $$

-- Test Cases:
CALL switchSection('ECE356', 2, 1, 1191, 30, @errorCode);
-- Success, output is 0
CALL switchSection('ECE356', 1, 2, 1191, 0, @errorCode);
-- Abort, quantity is 0, output is -1
CALL switchSection('ECE356', 1, 2, 1191, -1, @errorCode);
-- Abort, quantity is negative, output is -1
CALL switchSection('ECE999', 1, 2, 1191, 30, @errorCode);
-- Abort, course does not exist, output is -1
CALL switchSection('ECE356', 1, 1, 1191, 30, @errorCode);
-- Abort, sections are the same, output is -1
CALL switchSection('ECE356', 1, 2, 1191, 1000, @errorCode);
-- Abort, first section has negative enrollment after updates, output is -2
CALL switchSection('ECE356', 1, 2, 1191, 50, @errorCode);
-- Abort, second section enrollment exceeds classroom capacity, output is -3


