--University Registration Database

--create database University

create table staff (
staff_id int not null identity(1,1),
staff_firstname varchar(255) not null,
staff_lastname varchar(255) not null,
staff_region varchar(255) not null constraint valid_region check (staff_region in ('England', 'Scotland', 'Wales', 'Northern Ireland')),
PRIMARY KEY (staff_id)
);

create table students (
student_id int not null identity(1,1),
student_firstname varchar(255) not null, 
student_lastname varchar(255) not null, 
registration_year date not null,
counselor_id int not null,
student_region varchar(255) not null constraint valid_region2 check (student_region in ('England', 'Scotland', 'Wales', 'Northern Ireland')),
CONSTRAINT fk_counselor_id FOREIGN KEY (counselor_id) REFERENCES staff (staff_id),
PRIMARY KEY (student_id)
);

create table courses (
course_id int not null identity(1,1),
title varchar(255) not null, 
credit int not null constraint valid_credit check (credit in (15, 30)),
quota int not null,
tutor_id int not null,
CONSTRAINT fk_tutor_id FOREIGN KEY (tutor_id) REFERENCES staff (staff_id),
PRIMARY KEY (course_id)
);

create table enrollment (
student_id int not null,
course_id int not null,
enrolled_date date not null,
final_grade int,
CONSTRAINT fk1_student_id FOREIGN KEY (student_id) REFERENCES students (student_id),
CONSTRAINT fk2_course_id FOREIGN KEY (course_id) REFERENCES courses (course_id),
PRIMARY KEY (student_id, course_id)
);

create table assignment (
assignment_id int not null,
student_id int not null,
course_id int not null,
grade int not null constraint valid_grade check (grade between 0 and 100), 
CONSTRAINT fk_student_course FOREIGN KEY (student_id, course_id) REFERENCES enrollment (student_id, course_id),
PRIMARY KEY (assignment_id, student_id, course_id)
);

