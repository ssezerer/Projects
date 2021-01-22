--University Registration Database

--adding constraints and loading values

--adding constraints

--1--
CREATE FUNCTION check_credit()
RETURNS INT
AS
BEGIN
DECLARE @ret int
IF EXISTS(SELECT e.student_id, sum(credit) 
			FROM courses c JOIN enrollment e ON c.course_id=e.course_id
			GROUP BY e.student_id
			HAVING SUM(credit) > 180) 
	SELECT @ret = 1
ELSE
	SELECT @ret = 0;
RETURN @ret;
END;

ALTER TABLE enrollment
ADD CONSTRAINT credit_control CHECK(dbo.check_credit() = 0);

--INSERT INTO enrollment([student_id],[course_id],[enrolled_date])
--VALUES(1, 6, '2020-09-20')

--2--

CREATE FUNCTION check_quota()
RETURNS INT
AS
BEGIN
DECLARE @ret int
IF EXISTS(SELECT c.course_id, avg(c.quota) - count(c.course_id)
			FROM courses c JOIN enrollment e ON c.course_id=e.course_id
			GROUP BY c.course_id   
			HAVING avg(c.quota) - count(c.course_id) < 0)
	SELECT @ret = 1
ELSE
	SELECT @ret = 0;
RETURN @ret;
END;


ALTER TABLE enrollment
ADD CONSTRAINT quota_control CHECK(dbo.check_quota() = 0);

--INSERT INTO enrollment([student_id],[course_id],[enrolled_date])
--VALUES(8, 1, '2020-09-20')

--3--

CREATE FUNCTION check_assignment5()
RETURNS INT
AS
BEGIN
DECLARE @ret int
IF EXISTS(SELECT e.student_id, c.course_id, count(a.assignment_id)
			FROM assignment a JOIN enrollment e ON a.course_id=e.course_id and a.student_id = e.student_id
			JOIN courses c ON a.course_id = c.course_id 
			WHERE c.credit = 30 
			GROUP BY e.student_id, c.course_id 
			HAVING count(a.assignment_id) > 5)
	SELECT @ret =1
ELSE
	SELECT @ret = 0;
RETURN @ret;
END;

ALTER TABLE assignment
ADD CONSTRAINT assignment5_control CHECK(dbo.check_assignment5() = 0);

--INSERT INTO assignment ([student_id],[course_id],[assignment_id],[grade])
--VALUES(1, 1, 6, 90)

--4--

CREATE FUNCTION check_assignment3()
RETURNS INT
AS
BEGIN
DECLARE @ret int
IF EXISTS(SELECT e.student_id, c.course_id, count(a.assignment_id)
			FROM assignment a JOIN enrollment e ON a.course_id=e.course_id and a.student_id = e.student_id
			JOIN courses c ON a.course_id = c.course_id 
			WHERE c.credit = 15 
			GROUP BY e.student_id, c.course_id 
			HAVING count(a.assignment_id) > 3)
	SELECT @ret =1
ELSE
	SELECT @ret = 0;
RETURN @ret;
END;

ALTER TABLE assignment
ADD CONSTRAINT assignment3_control CHECK(dbo.check_assignment3() = 0);

--INSERT INTO assignment ([student_id],[course_id],[assignment_id],[grade])
--VALUES(5, 6, 4, 90)

--5--

CREATE FUNCTION check_region1()
RETURNS INT
AS
BEGIN
DECLARE @ret int
IF EXISTS(SELECT *
			FROM students s JOIN staff st ON s.counselor_id = st.staff_id
			WHERE s.student_region != st.staff_region)
	SELECT @ret =1
ELSE
	SELECT @ret = 0;
RETURN @ret;
END;


ALTER TABLE students
ADD CONSTRAINT region_control1 CHECK(dbo.check_region1() = 0);

--INSERT INTO students ([student_firstname],[student_lastname],[registration_year],[counselor_id], [student_region])
--VALUES('Osman', 'Þimþek', '2020-09-15', 1, 'Wales')

--6--

CREATE FUNCTION check_region2()
RETURNS INT
AS
BEGIN
DECLARE @ret int
IF EXISTS(select tutor_id, staff_region, e.student_id, student_region 
			from courses c
			left join staff s on s.staff_id = c.tutor_id
			left join enrollment e on c.course_id = e.course_id
			left join students st on e.student_id = st.student_id
			WHERE st.student_region != s.staff_region
			)
	SELECT @ret =1
ELSE
	SELECT @ret = 0;
RETURN @ret;
END;

ALTER TABLE enrollment
ADD CONSTRAINT region_control2 CHECK(dbo.check_region2() = 0);

INSERT INTO enrollment([student_id],[course_id],[enrolled_date])
VALUES(9, 9, '2020-09-20')


-----------------------------------------------------------------

--loading values

INSERT INTO staff ([staff_firstname],[staff_lastname],[staff_region])
VALUES('Selim', 'Aydýn', 'England'),
('Ahmet', 'Yýlmaz', 'Wales'),
('Mehmet', 'Gür', 'Scotland'),
('Ali', 'Solmaz', 'Northern Ireland'),
('Ayþe', 'Korkmaz', 'England'),
('Gül', 'Zorlu', 'England'),
('Deniz', 'Güzel', 'England'),
('Derya', 'Sarý', 'Scotland'),
('Sezgin', 'Yýldýrým', 'Northern Ireland'),
('Emre', 'Atmaca', 'Wales')

select * from [dbo].[staff]

INSERT INTO students ([student_firstname],[student_lastname],[registration_year],[counselor_id], [student_region])
VALUES('Ali', 'Güzel', '2020-09-15', 1, 'England'),
('Osman', 'Yücel', '2020-09-15', 4, 'Northern Ireland'),
('Ömer', 'Ýlhan', '2020-09-15', 3, 'Scotland'),
('Bekir', 'Gül', '2020-09-15', 5,'England'),
('Ahmet', 'Çiçek', '2020-09-15', 2, 'Wales'),
('Mehmet', 'Uyanýk', '2020-09-15', 9, 'Northern Ireland'),
('Ayþe', 'Menekþe', '2020-09-15', 6, 'England'),
('Jale', 'Batý', '2020-09-15', 7, 'England'),
('Hale', 'Doðu', '2020-09-15', 10, 'Wales'),
('Hande', 'Güney', '2020-09-15', 4, 'Northern Ireland'),
('Murat', 'Kuzey', '2020-09-15', 8, 'Scotland'),
('Enes', 'Poyraz', '2020-09-15', 1, 'England'),
('Onur', 'Karayel', '2020-09-15', 2, 'Wales'),
('Ýdris', 'Lodos', '2020-09-15', 5, 'England'),
('Atýf', 'Yýldýz', '2020-09-15', 3, 'Scotland'),
('Ertan', 'Dað', '2020-09-15', 6, 'England'),
('Ýlker', 'Oba', '2020-09-15', 9, 'Northern Ireland'),
('Gürcan', 'Koyun', '2020-09-15', 8, 'Scotland'),
('Ercan', 'Arslan', '2020-09-15', 7, 'England'),
('Serdar', 'Kurt', '2020-09-15', 1, 'England')

select * from [dbo].[students]

INSERT INTO courses([title],[credit],[quota],[tutor_id])
VALUES('Math', 30, 5, 1),
('Physics', 30, 5, 2),
('Chemistry', 30, 5, 3),
('English', 30, 5, 4),
('Biology', 15, 5, 5),
('Fine Arts', 15, 5, 6),
('German', 30, 5, 7),
('Social Arts', 30, 5, 8),
('Math2', 30, 5, 9),
('History', 15, 5, 8),
('Computer', 30, 5, 10);

select * from [dbo].[courses]

INSERT INTO enrollment([student_id],[course_id],[enrolled_date])
VALUES(1, 1, '2020-09-20'),
(1, 5, '2020-09-20'),
(1, 6, '2020-09-20'),
(1, 7, '2020-09-20'),
(2, 4, '2020-09-20'),
(2, 9, '2020-09-20'),
(3, 3, '2020-09-20'),
(3, 8, '2020-09-20'),
(4, 1, '2020-09-20'),
(4, 5, '2020-09-20'),
(4, 6, '2020-09-20'),
(4, 7, '2020-09-20'),
(5, 2, '2020-09-20'),
(5, 11, '2020-09-20');


select * from [dbo].[enrollment]

INSERT INTO assignment ([student_id],[course_id],[assignment_id],[grade])
VALUES(1, 5, 1, 90),
(1, 5, 2, 95),
(1, 5, 3, 100),
(2, 4, 1, 90),
(2, 4, 2, 95),
(2, 4, 3, 100),
(2, 4, 4, 80),
(2, 4, 5, 75),
(5, 2, 1, 90),
(5, 2, 2, 95),
(5, 2, 3, 100),
(5, 2, 4, 95),
(5, 2, 5, 100);

select * from [dbo].[assignment]

--Change a student's grade by creating a SQL script that updates a student's grade in the assignment table.

select * from assignment

update assignment
set grade=98
where assignment_id=3 and student_id=1 and course_id=5;

-- Update the credit for a course.

SELECT * FROM courses

UPDATE courses
SET Credit = 15 -- old value was 30
WHERE course_id = 8

-- Swap the responsible staff of two students with each other in the student table.

SELECT * FROM students

UPDATE students
SET counselor_id = 5-- old value was 1
WHERE student_id = 1;

UPDATE students
SET counselor_id = 1-- old value was 5
WHERE student_id = 4; 

--Remove a staff member who is not assigned to any student from the staff table.

SELECT * FROM Staff

insert staff ([staff_firstname],[staff_lastname],[staff_region])
values ('Erdem', 'Kartal', 'Wales')

DELETE FROM staff WHERE staff_id = (SELECT TOP 1 sf.staff_id
									FROM staff sf
									left join students s ON s.counselor_id = sf.staff_id
									left join courses c ON sf.staff_id = c.tutor_id
									WHERE s.student_id IS NULL ORDER BY sf.staff_id desc);

--Add a student to the student table and enroll the student you added to any course.

INSERT INTO students ([student_firstname],[student_lastname],[registration_year],[counselor_id], [student_region])
VALUES('Metin', 'Þirin', '2020-09-15', 1, 'England')


SELECT * FROM students


INSERT INTO enrollment([student_id],[course_id],[enrolled_date])
VALUES(21, 1, '2020-09-20')

SELECT * FROM enrollment



