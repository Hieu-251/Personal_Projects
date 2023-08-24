-- Q1
SELECT L.Lec_Id, L.Lec_Name, C.Class_Code ,S.Sub_Code, S.Sub_Name
FROM LECTURER L 
INNER JOIN CLASS C
ON L.Lec_Id = C.Lec_Id
INNER JOIN SUBJECT S
ON S.Sub_Code = C.Sub_Code
ORDER BY Lec_Id ASC;

-- Q2
SELECT C.Class_Code, S.Sub_Name, G.Letter_G, COUNT(*) AS NumberOfLetterGrade
FROM CLASS C 
INNER JOIN SUBJECT S
ON C.Sub_Code = S.Sub_Code
INNER JOIN GRADE G
ON C.Class_Code = G.Class_Code
GROUP BY G.Letter_G, C.Class_Code
HAVING G.Letter_G = 'A' OR G.Letter_G = 'A+'
ORDER BY G.Letter_G DESC;

-- Q3
CREATE VIEW FeesPaymentFromStudent AS
SELECT S.Stu_Id, S.FullName, I.Total_Fee, P.Amount_Paid, I.Total_Debt 
FROM STUDENT S 
INNER JOIN PAYMENT P
ON S.Stu_Id = P.Stu_Id
INNER JOIN INVOICE I
ON I.In_Id = P.In_Id
ORDER BY Total_Debt ASC;

SELECT * FROM FeesPaymentFromStudent;

-- Q4
START TRANSACTION;
INSERT INTO PAYMENT 
VALUES (2451, 18071451, 'IN1451', 6966000, '2021/05/08', 'Completed');

UPDATE INVOICE
SET Total_Debt = Total_Debt - 6966000
WHERE In_Id = 'IN1451';
COMMIT;

-- Q5
SELECT S.Stu_Id, Fullname , AVG(Avg_4) AS AverageScoreOnScale4
FROM STUDENT S
INNER JOIN ENROLLMENT E
ON S.Stu_Id = E.Stu_Id
INNER JOIN GRADE G
ON S.Stu_Id = G.Stu_Id
AND E.Class_Code = G.Class_Code
GROUP BY Stu_Id
HAVING AVG(Avg_4) >= 3.2;

-- Q6
DELIMITER //

CREATE PROCEDURE GetStuInfoByHometownName(
		IN HometownName NVARCHAR(15)
)
BEGIN 
		SELECT *
        FROM STUDENT
        WHERE Hometown = HometownName;
END //

CALL GetStuInfoByHometownName('Hà Nội');   

-- Q7
SELECT Date_Paid, COUNT(*) AS NumberOfTransaction
FROM PAYMENT
WHERE Date_Paid
BETWEEN ('2021-05-01') AND ('2021-05-03')
GROUP BY Date_Paid;

-- Q8
DROP VIEW IF EXISTS Class_credits;
CREATE VIEW Class_credits AS 
SELECT G.Gra_Id, G.Class_Code, Sub_Credits 
FROM GRADE G
INNER JOIN  ENROLLMENT E
ON G.Stu_Id = E.Stu_Id
AND G.Class_Code = E.Class_Code
INNER JOIN CLASS C
ON  G.Class_Code = C.Class_Code
INNER JOIN SUBJECT S
ON C.Sub_Code = S.Sub_code;
	
DROP PROCEDURE IF EXISTS Cre_update;
DELIMITER //
CREATE PROCEDURE Cre_update (
IN GradeID CHAR(6),
IN StudentID CHAR(8)
)
BEGIN 
DECLARE Finalresult CHAR(6);
DECLARE Creditsnum INT;

SELECT Result 
INTO Finalresult 
FROM GRADE 
WHERE Gra_Id = GradeID;

SELECT Sub_Credits
INTO Creditsnum
FROM Class_credits
WHERE Gra_Id = GradeID;

IF Finalresult = 'Passed'  THEN 
	UPDATE student 
	SET Stu_Credits = Stu_Credits + Creditsnum
    	WHERE Stu_Id = StudentID;
END IF;
END //
DELIMITER ;
	
DROP TRIGGER IF EXISTS Credit_update;
DELIMITER //
CREATE TRIGGER Credit_update
AFTER INSERT ON GRADE
FOR EACH ROW
BEGIN
CALL Cre_update ( NEW.Gra_Id, NEW.Stu_Id);
END //
DELIMITER ;
	
INSERT INTO GRADE VALUES ('1503_6', 18071503, 'SOC1050', '2020-2021', 2, 'SOC1050', 10, 9, 9, 9.1, 4, 'A+', 'Passed');
SELECT * FROM STUDENT WHERE Stu_Id = '18071503';



