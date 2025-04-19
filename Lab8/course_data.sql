
CREATE TABLE Course (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    credits INT CHECK (credits >= 1 AND credits <= 5)
);

INSERT INTO Course (course_id, course_name, credits) VALUES (94, 'Ethics', 3);
INSERT INTO Course (course_id, course_name, credits) VALUES (644, 'Philosophy', 1);
INSERT INTO Course (course_id, course_name, credits) VALUES (632, 'Biology', 3);
INSERT INTO Course (course_id, course_name, credits) VALUES (269, 'Ethics', 1);
INSERT INTO Course (course_id, course_name, credits) VALUES (245, 'English Literature', 2);
INSERT INTO Course (course_id, course_name, credits) VALUES (640, 'Psychology', 2);
INSERT INTO Course (course_id, course_name, credits) VALUES (874, 'Linear Algebra', 4);
INSERT INTO Course (course_id, course_name, credits) VALUES (551, 'Psychology', 5);
INSERT INTO Course (course_id, course_name, credits) VALUES (255, 'Calculus', 5);
INSERT INTO Course (course_id, course_name, credits) VALUES (2, 'Philosophy', 4);
INSERT INTO Course (course_id, course_name, credits) VALUES (601, 'English Literature', 4);
INSERT INTO Course (course_id, course_name, credits) VALUES (90, 'Art History', 1);
INSERT INTO Course (course_id, course_name, credits) VALUES (820, 'Sociology', 2);
INSERT INTO Course (course_id, course_name, credits) VALUES (419, 'Art History', 5);
INSERT INTO Course (course_id, course_name, credits) VALUES (954, 'English Literature', 5);
INSERT INTO Course (course_id, course_name, credits) VALUES (115, 'Philosophy', 5);
INSERT INTO Course (course_id, course_name, credits) VALUES (732, 'World History', 5);
INSERT INTO Course (course_id, course_name, credits) VALUES (164, 'World History', 3);
INSERT INTO Course (course_id, course_name, credits) VALUES (193, 'Calculus', 4);
INSERT INTO Course (course_id, course_name, credits) VALUES (703, 'History', 5);
INSERT INTO Course (course_id, course_name, credits) VALUES (596, 'Computer Science', 5);
INSERT INTO Course (course_id, course_name, credits) VALUES (838, 'Physics', 2);
INSERT INTO Course (course_id, course_name, credits) VALUES (16, 'Physics', 1);
INSERT INTO Course (course_id, course_name, credits) VALUES (474, 'Geography', 4);
INSERT INTO Course (course_id, course_name, credits) VALUES (817, 'Calculus', 2);
INSERT INTO Course (course_id, course_name, credits) VALUES (105, 'Psychology', 4);
INSERT INTO Course (course_id, course_name, credits) VALUES (988, 'Chemistry', 2);
INSERT INTO Course (course_id, course_name, credits) VALUES (844, 'Mathematics', 3);
INSERT INTO Course (course_id, course_name, credits) VALUES (704, 'English Literature', 2);
INSERT INTO Course (course_id, course_name, credits) VALUES (847, 'Ethics', 1);
INSERT INTO Course (course_id, course_name, credits) VALUES (289, 'Chemistry', 2);
INSERT INTO Course (course_id, course_name, credits) VALUES (351, 'Computer Science', 4);
INSERT INTO Course (course_id, course_name, credits) VALUES (914, 'Ethics', 2);
INSERT INTO Course (course_id, course_name, credits) VALUES (432, 'English Literature', 3);
INSERT INTO Course (course_id, course_name, credits) VALUES (972, 'Computer Science', 3);
INSERT INTO Course (course_id, course_name, credits) VALUES (409, 'Art History', 1);
INSERT INTO Course (course_id, course_name, credits) VALUES (961, 'Organic Chemistry', 4);
INSERT INTO Course (course_id, course_name, credits) VALUES (357, 'Physics', 5);
INSERT INTO Course (course_id, course_name, credits) VALUES (777, 'Sociology', 5);
INSERT INTO Course (course_id, course_name, credits) VALUES (75, 'Chemistry', 3);
INSERT INTO Course (course_id, course_name, credits) VALUES (331, 'Mathematics', 4);
INSERT INTO Course (course_id, course_name, credits) VALUES (967, 'Philosophy', 5);
INSERT INTO Course (course_id, course_name, credits) VALUES (389, 'Computer Science', 4);
INSERT INTO Course (course_id, course_name, credits) VALUES (560, 'History', 4);
INSERT INTO Course (course_id, course_name, credits) VALUES (727, 'History', 5);
INSERT INTO Course (course_id, course_name, credits) VALUES (994, 'English Literature', 3);
INSERT INTO Course (course_id, course_name, credits) VALUES (293, 'Statistics', 4);
INSERT INTO Course (course_id, course_name, credits) VALUES (112, 'Biology', 2);
INSERT INTO Course (course_id, course_name, credits) VALUES (95, 'History', 2);
INSERT INTO Course (course_id, course_name, credits) VALUES (995, 'Organic Chemistry', 3);