-- Part1, Question4
CREATE TABLE IF NOT EXISTS EmployeeBCNF (
    empID INT(11),
    firstName VARCHAR(100),
    lastName VARCHAR(100),
    middleName VARCHAR(100),
    job VARCHAR(100),
    salary INT(11),
    PRIMARY KEY (empID)
);

CREATE TABLE IF NOT EXISTS Project  (
    projID INT(11),
    title VARCHAR(100),
    budget INT(11),
    funds INT(11),
    PRIMARY KEY (projID)
);

CREATE TABLE IF NOT EXISTS DepartmentBCNF  (
    deptID INT(11),
    deptName VARCHAR(100) ,
    PRIMARY KEY (deptID)
);

CREATE TABLE IF NOT EXISTS PostalCode  (
    postalCode VARCHAR(100),
    cityName VARCHAR(100),
    province VARCHAR(100),
    PRIMARY KEY (postalCode)
);

CREATE TABLE IF NOT EXISTS EmployeeDept  (
    empID INT(11),
    deptID INT(11),
    PRIMARY KEY (empID, deptID),
    FOREIGN KEY (empID) REFERENCES EmployeeBCNF (empID),
    FOREIGN KEY (deptID) REFERENCES DepartmentBCNF (deptID)
);

CREATE TABLE IF NOT EXISTS Assigned  (
    empID INT(11),
    projID INT(11),
    role VARCHAR(100),
    PRIMARY KEY (empID, projID, role),
    FOREIGN KEY (empID) REFERENCES EmployeeBCNF (empID),
    FOREIGN KEY (projID) REFERENCES Project (projID)
);

CREATE TABLE IF NOT EXISTS Location  (
    locationID INT(11),
    streetName VARCHAR(100),
    streetNumber VARCHAR(100),
    postalCode VARCHAR(100),
    PRIMARY KEY (locationID),
    FOREIGN KEY (postalCode) REFERENCES PostalCode (postalCode)
);

CREATE TABLE IF NOT EXISTS DepartmentLocation  (
    deptID INT(11),
    locationID INT(11),
    PRIMARY KEY (deptID, locationID),
    FOREIGN KEY (deptID) REFERENCES DepartmentBCNF (deptID),
    FOREIGN KEY (locationID) REFERENCES Location (locationID)
);


-- Part1, Question5 
CREATE VIEW Abc AS
SELECT empID,
       concat(firstName, middleName, lastName) AS empName,
       job,
       deptID,
       salary
FROM EmployeeBCNF
LEFT JOIN EmployeeDept USING (empID);

CREATE VIEW Department AS
SELECT deptID,
       deptName,
       concat(streetName, streetNumber, cityName, province, postalCode) AS location
FROM DepartmentBCNF 
    LEFT join DepartmentLocation using (deptID)
    LEFT join Location using (locationID)
    LEFT join PostalCode using (postalCode);

-- Part1, Question6
DELIMITER $$
CREATE PROCEDURE `payRaise` (
                        in inEmpID int(11),
                        in inPercentageRaise double(4, 2),
                        out errorCode int(11))
    BEGIN
        -- set errorCode = 0;
        if inPercentageRaise > 0.1 or inPercentageRaise < 0 THEN
            set errorCode = -1;
        elseif not EXISTS (SELECT empID from EmployeeBCNF WHERE empID = inEmpID) then
            set errorCode = -2;
        else 
            set errorCode = 0;
            update EmployeeBCNF set salary = salary * (1 + inPercentageRaise) where  empID = inEmpID;
        end if;
    END $$
DELIMITER;

-- set @errorCode = 0;
-- select payRaise(empID, 0.05, @errorCode) 
-- from EmployeeBCNF 
--     inner join EmployeeDept using (empID)
--     inner join DepartmentBCNF using (deptID)
--     inner join DepartmentLocation using (deptID)
--     inner join Location using (locationID)
--     inner join PostalCode using (postalCode)
-- where cityName = "Waterloo"; 

-- update EmployeeBCNF 
--     inner join EmployeeDept using (empID)
--     inner join DepartmentBCNF using (deptID)
--     inner join DepartmentLocation using (deptID)
--     inner join Location using (locationID)
--     inner join PostalCode using (postalCode)
-- set salary = salary * (1 + 0.05)
-- where cityName = "Waterloo"; 

-- raise with the store procedure
-- https://stackoverflow.com/questions/20865592/mysql-stored-procedure-with-cursor#
DELIMITER $$  
CREATE PROCEDURE `raiseAllWaterloo`(out errorCode int(11))
    BEGIN

    declare done int;
    declare waterloo_empID int(11);

    declare cur1 cursor for 
            select empID 
            from EmployeeBCNF 
                inner join EmployeeDept using (empID)
                inner join DepartmentBCNF using (deptID)
                inner join DepartmentLocation using (deptID)
                inner join Location using (locationID)
                inner join PostalCode using (postalCode)
            where cityName = "Waterloo"; 
    declare continue handler for not found set done = 1;

    set done = 0;
    open cur1;
    updateLoop: loop
        fetch cur1 into waterloo_empID;
        if done = 1 then
            leave updateLoop; 
        end if;

        call payRaise(waterloo_empID, 0.05, errorCode);

    end loop updateLoop;
    close cur1;
END $$
 
Call raiseAllWaterloo(@errorCode);

-- test case 
-- insert into PostalCode(postalCode, cityName) values (1, "Waterloo"), (2, "Toronto");
-- insert into EmployeeBCNF(empID, firstName, middleName, lastName, salary)values (5, "a", "b","c", 1000), (6,"a", "b","c",  2000), (7,"a", "b","c",  3000), (8,"a", "b","c",  4000);
-- insert into DepartmentBCNF(deptID, deptName) values (1, "ECE"), (2, "CS");
-- insert into EmployeeDept(empID, deptID) values (1, 1), (2, 1), (3, 2), (4, 2);
-- insert into Location(locationID, postalCode) values (1, 1), (2, 2);
-- insert into DepartmentLocation(deptID, locationID) values (1, 1), (2, 2);
