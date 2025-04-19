import random

# Sample list of course names for variety
course_names = [
    "Mathematics", "Physics", "Chemistry", "Biology", "Computer Science",
    "History", "Geography", "Economics", "English Literature", "Philosophy",
    "Psychology", "Sociology", "Political Science", "Art History", "Statistics",
    "Calculus", "Linear Algebra", "Organic Chemistry", "World History", "Ethics"
]

# Use the same roll numbers as in the Student table (from your previous script)
roll_numbers = random.sample(range(1000, 9999), 500)  # 4-digit roll numbers

# Function to generate a random course record
def generate_course(course_id):
    course_name = random.choice(course_names)
    credits = random.randint(1, 5)  # Credits between 1 and 5
    return (course_id, course_name, credits)

# Function to generate a random enrollment record
def generate_enrollment(roll, course_id):
    grade = random.randint(50, 100)  # Grade between 50 and 100
    return (roll, course_id, grade)

# Generate 50 unique course IDs
course_ids = random.sample(range(1, 1000), 50)  # Course IDs between 1 and 999

# Generate 50 course records
courses = [generate_course(course_id) for course_id in course_ids]

# Generate 500 enrollment records (one per student, randomly assigned to a course)
enrollments = []
for roll in roll_numbers:
    course_id = random.choice(course_ids)  # Randomly assign a course to each student
    enrollments.append(generate_enrollment(roll, course_id))

# SQL CREATE TABLE statements
create_course_table_sql = """
CREATE TABLE Course (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    credits INT CHECK (credits >= 1 AND credits <= 5)
);
"""

create_enrollment_table_sql = """
CREATE TABLE Enrollment (
    roll INT,
    course_id INT,
    grade INT CHECK (grade >= 0 AND grade <= 100),
    PRIMARY KEY (roll, course_id),
    FOREIGN KEY (roll) REFERENCES Student(roll),
    FOREIGN KEY (course_id) REFERENCES Course(course_id)
);
"""

# Generate SQL INSERT statements for Course
course_insert_statements = [
    f"INSERT INTO Course (course_id, course_name, credits) VALUES ({course[0]}, '{course[1]}', {course[2]});"
    for course in courses
]

# Generate SQL INSERT statements for Enrollment
enrollment_insert_statements = [
    f"INSERT INTO Enrollment (roll, course_id, grade) VALUES ({enrollment[0]}, {enrollment[1]}, {enrollment[2]});"
    for enrollment in enrollments
]

# Combine all SQL statements for Course
course_full_sql = create_course_table_sql + "\n" + "\n".join(course_insert_statements[:10]) + "\n-- ... (40 more rows follow) ..."

# Combine all SQL statements for Enrollment
enrollment_full_sql = create_enrollment_table_sql + "\n" + "\n".join(enrollment_insert_statements[:10]) + "\n-- ... (490 more rows follow) ..."

# Print the first 10 rows as a sample for Course
print("SQL Command to Create and Populate Course Table (Sample of first 10 rows):")
print(course_full_sql)
print(f"\nTotal Course rows generated: {len(courses)}")

# Print the first 10 rows as a sample for Enrollment
print("\nSQL Command to Create and Populate Enrollment Table (Sample of first 10 rows):")
print(enrollment_full_sql)
print(f"\nTotal Enrollment rows generated: {len(enrollments)}")

# Write all rows to files
with open("course_data.sql", "w") as f:
    f.write(create_course_table_sql + "\n" + "\n".join(course_insert_statements))
print("Full 50 Course rows written to 'course_data.sql'")

with open("enrollment_data.sql", "w") as f:
    f.write(create_enrollment_table_sql + "\n" + "\n".join(enrollment_insert_statements))
print("Full 500 Enrollment rows written to 'enrollment_data.sql'")