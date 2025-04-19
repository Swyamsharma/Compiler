import re
import random
import sys
import os # Added
import socket # Added
import requests
from PyQt6.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, QLabel, 
                             QLineEdit, QPushButton, QTextEdit, QMessageBox, QTableWidget, QTableWidgetItem,
                             QSizePolicy, QListWidget, QListWidgetItem)
import psycopg2
import google.generativeai as genai # Added
import ollama # Added

def tokenize(sentence):
    tokens = sentence.lower().split()
    i = 0
    result = []
    while i < len(tokens):
        if i + 1 < len(tokens) and tokens[i] + " " + tokens[i + 1] in ["roll numbers", "roll number", "more than", "less than", "equal to"]:
            result.append(tokens[i] + " " + tokens[i + 1])
            i += 2
        else:
            result.append(tokens[i])
            i += 1
    return result


class SQLParser:
    def __init__(self, tokens):
        self.tokens = tokens
        self.pos = 0
        self.tables = ["Student", "Course"]
        self.attributes = {
            "Student": ["roll", "name", "cpi"],
            "Course": ["course_id", "course_name", "credits"]
        }

    def current_token(self):
        return self.tokens[self.pos] if self.pos < len(self.tokens) else None

    def advance(self):
        self.pos += 1

    def parse(self):
        self.request()
        query_type = self.query_type()
        details = self.details(query_type)
        return details

    def request(self):
        if self.current_token() == "please":
            self.advance()
        else:
            raise ValueError("Expected 'please'")

    def query_type(self):
        token = self.current_token()
        if token in ["give", "show", "update", "add", "remove"]:
            self.advance()
            return token
        raise ValueError("Expected 'give', 'show', 'update', 'add', or 'remove'")

    def details(self, query_type):
        if query_type in ["give", "show"]:
            return self.select_details(query_type)
        elif query_type == "update":
            return self.update_details()
        elif query_type == "add":
            return self.insert_details()
        elif query_type == "remove":
            return self.delete_details()
        raise ValueError("Invalid query type")

    def select_details(self, query_type):
        if query_type == "give" and self.current_token() == "me":
            self.advance()
        elif query_type == "show" and self.current_token() == "me":
            self.advance()

        target = self.target()
        if self.current_token() != "of":
            raise ValueError("Expected 'of'")
        self.advance()
        if self.current_token() != "the":
            raise ValueError("Expected 'the'")
        self.advance()

        table = self.table_name()
        condition = ""
        if self.current_token() == "whose":
            condition = " where " + self.condition(table)
        elif self.current_token() == "where":
            self.advance()
            condition = " where " + self.condition(table)

        return f"select {target} from {table}{condition}"

    def target(self):
        if self.current_token() == "all":
            self.advance()
            if self.current_token() != "the":
                raise ValueError("Expected 'the'")
            self.advance()
            if self.current_token() != "information":
                raise ValueError("Expected 'information'")
            self.advance()
            return "*"
        if self.current_token() == "the":
            self.advance()
        return self.attribute_list()

    def attribute_list(self):
        attrs = [self.attribute()]
        while self.current_token() == "and":
            self.advance()
            attrs.append(self.attribute())
        return ", ".join(attrs)

    def attribute(self):
        token = self.current_token()
        if token in ["name", "roll", "cpi", "roll numbers", "roll number", "course_id", "course_name", "credits"]:
            self.advance()
            return "roll" if token in ["roll numbers", "roll number"] else token
        raise ValueError(f"Invalid attribute: {token}")

    def table_name(self):
        token = self.current_token()
        if token in ["students", "student"]:
            self.advance()
            return "Student"
        elif token in ["courses", "course"]: 
            self.advance()
            return "Course"
        raise ValueError(f"Invalid table: {token}")

    def condition(self, table):
        attr = self.attribute()
        if attr not in self.attributes[table]:
            raise ValueError(f"Attribute '{attr}' not valid for table '{table}'")
        if self.current_token() != "is":
            raise ValueError("Expected 'is'")
        self.advance()

        comp_op = self.comparison_op()
        val = self.value()

        if attr in ["name", "course_name"]:
            if comp_op != "=":
                raise ValueError(f"Comparison with '{attr}' must use 'equal to', not 'more than' or 'less than'")
            if val.replace('.', '').isdigit():
                raise ValueError(f"Value for '{attr}' must be a non-numeric string")
            return f"{attr} {comp_op} '{val}'"
        else:
            if not val.replace('.', '').isdigit():
                raise ValueError(f"Value for '{attr}' must be numeric")
            return f"{attr} {comp_op} {val}"

    def comparison_op(self):
        token = self.current_token()
        if token == "more than":
            self.advance()
            return ">"
        elif token == "less than":
            self.advance()
            return "<"
        elif token == "equal to":
            self.advance()
            return "="
        raise ValueError("Invalid comparison operator")

    def update_details(self):
        if self.current_token() != "the":
            raise ValueError("Expected 'the'")
        self.advance()

        attr1 = self.attribute()
        if self.current_token() != "of":
            raise ValueError("Expected 'of'")
        self.advance()
        if self.current_token() != "the":
            raise ValueError("Expected 'the'")
        self.advance()

        table = self.table_name()
        if attr1 not in self.attributes[table]:
            raise ValueError(f"Attribute '{attr1}' not valid for table '{table}'")

        if self.current_token() != "having":
            raise ValueError("Expected 'having'")
        self.advance()

        attr2 = self.attribute()
        if attr2 not in self.attributes[table]:
            raise ValueError(f"Attribute '{attr2}' not valid for table '{table}'")
        if attr2 in ["name", "course_name"]:
            raise ValueError("Condition with 'no' must use a numeric field, not name or course_name")
        if self.current_token() != "no":
            raise ValueError("Expected 'no'")
        self.advance()

        num1 = self.value()
        if not num1.replace('.', '').isdigit():
            raise ValueError("Condition value after 'no' must be numeric")
        
        if self.current_token() != "to":
            raise ValueError("Expected 'to'")
        self.advance()

        num2 = self.value()
        if attr1 in ["name", "course_name"]:
            if num2.replace('.', '').isdigit():
                raise ValueError(f"Value for '{attr1}' must be a non-numeric string")
            set_value = f"'{num2}'"
        else:
            set_value = f"'{num2}'" if not num2.replace('.', '').isdigit() else num2
        
        cond_value = num1
        return f"update {table} set {attr1}={set_value} where {attr2} = {cond_value}"

    def insert_details(self):
        if self.current_token() != "a":
            raise ValueError("Expected 'a'")
        self.advance()

        table = self.table_name()
        if self.current_token() != "with":
            raise ValueError("Expected 'with'")
        self.advance()

        values = self.value_list(table)
        columns = ", ".join(self.attributes[table])
        values_str = ", ".join(values)
        return f"insert into {table} ({columns}) values ({values_str})"

    def value_list(self, table):
        values = []
        for attr in self.attributes[table]:
            if attr not in self.current_token():
                raise ValueError(f"Expected attribute '{attr}' in insert statement")
            self.advance()
            val = self.value()
            if attr in ["name", "course_name"]:
                if val.replace('.', '').isdigit():
                    raise ValueError(f"Value for '{attr}' must be a non-numeric string")
                values.append(f"'{val}'")
            else:
                if not val.replace('.', '').isdigit():
                    raise ValueError(f"Value for '{attr}' must be numeric")
                values.append(val)
        return values

    def delete_details(self):
        if self.current_token() != "the":
            raise ValueError("Expected 'the'")
        self.advance()

        table = self.table_name()
        if self.current_token() != "where":
            raise ValueError("Expected 'where'")
        self.advance()

        condition = self.condition(table)
        return f"delete from {table} where {condition}"

    def value(self):
        token = self.current_token()
        if token is None:
            raise ValueError("Expected a value")
        self.advance()
        return token

def execute_sql_query(query):
    try:
        conn = psycopg2.connect(
            dbname="student",
            user="postgres",
            password="postgres",
            host="localhost",
            port="5432"
        )
        cursor = conn.cursor()
        
        if query.strip().lower().startswith("select"):
            cursor.execute(query)
            results = cursor.fetchall()
            column_names = [desc[0] for desc in cursor.description]
            conn.close()
            return column_names, results, None
        elif query.strip().lower().startswith("update"):
            cursor.execute(query)
            conn.commit()
            where_clause = query.split("where")[1].strip()
            table = query.split("set")[0].replace("update", "").strip()
            select_query = f"SELECT * FROM {table} WHERE {where_clause}"
            cursor.execute(select_query)
            results = cursor.fetchall()
            column_names = [desc[0] for desc in cursor.description]
            conn.close()
            return column_names, results, "Update executed successfully!"
        elif query.strip().lower().startswith("insert"):
            cursor.execute(query)
            conn.commit()

            table = query.split("into")[1].split()[0].strip()
            values_part = query.split("values")[1].strip()
            values = values_part.strip("()").split(", ")
            primary_key = values[0]

            attributes = {"Student": ["roll", "name", "cpi"], "Course": ["course_id", "course_name", "credits"]}
            primary_key_name = attributes[table][0]
            select_query = f"SELECT * FROM {table} WHERE {primary_key_name} = {primary_key}"
            cursor.execute(select_query)
            results = cursor.fetchall()
            if not results:
                conn.close()
                return None, None, "Insert executed, but record not found (possible duplicate primary key)."
            column_names = [desc[0] for desc in cursor.description]
            conn.close()
            return column_names, results, "Insert executed successfully!"
        elif query.strip().lower().startswith("delete"):
            table = query.split("from")[1].split("where")[0].strip()
            condition = query.split("where")[1].strip()
            select_query = f"SELECT COUNT(*) FROM {table} WHERE {condition}"
            cursor.execute(select_query)
            rows_before = cursor.fetchone()[0]

            cursor.execute(query)
            conn.commit()

            rows_affected = cursor.rowcount

            cursor.execute(select_query)
            rows_after = cursor.fetchone()[0]

            conn.close()
            if rows_affected == 0:
                return None, None, "No rows matched the condition for deletion."
            return None, None, f"Delete executed successfully! {rows_affected} row(s) deleted."
        else:
            conn.close()
            return None, None, "Unsupported query type"
    except psycopg2.Error as e:
        conn.close()
        return None, None, f"Database Error: {e}"
    except Exception as e:
        conn.close()
        return None, None, f"Error: {e}"

# --- Pre-validation and Translation Logic ---

QUERY_KEYWORDS = ["please", "give", "show", "update", "add", "remove", "student", "students", "course", "courses", "roll", "cpi", "name", "credits", "course_id"]

def is_likely_query(sentence):
    """Basic check for relevant keywords."""
    text = sentence.lower()
    return any(keyword in text for keyword in QUERY_KEYWORDS)

# Configure Gemini
try:
    GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY')
    if not GEMINI_API_KEY:
        print("Warning: GEMINI_API_KEY environment variable not set. Gemini fallback disabled.", file=sys.stderr)
        genai.configure(api_key="DUMMY_KEY_SO_IT_DOESNT_CRASH") # Avoid crash if key missing
        gemini_model = None
    else:
        genai.configure(api_key=GEMINI_API_KEY)
        # Updated model name as requested
        gemini_model = genai.GenerativeModel('gemini-2.0-flash') 
except Exception as e:
    print(f"Error configuring Gemini: {e}", file=sys.stderr)
    gemini_model = None

# Schema definition for LLMs
SCHEMA_INFO = """
Database Schema:
Table: Student
Columns: roll (INTEGER, PRIMARY KEY), name (TEXT), cpi (REAL)

Table: Course
Columns: course_id (INTEGER, PRIMARY KEY), course_name (TEXT), credits (INTEGER)
"""

def check_internet(host="8.8.8.8", port=53, timeout=3):
    """Check for internet connectivity."""
    try:
        socket.setdefaulttimeout(timeout)
        socket.socket(socket.AF_INET, socket.SOCK_STREAM).connect((host, port))
        return True
    except socket.error as ex:
        print(f"Internet check failed: {ex}", file=sys.stderr)
        return False

def translate_with_parser(sentence):
    """Attempts translation using the custom parser."""
    try:
        tokens = tokenize(sentence)
        parser = SQLParser(tokens)
        sql = parser.parse()
        # Basic validation
        sql_lower = sql.lower().strip()
        if sql_lower and any(sql_lower.startswith(kw) for kw in ["select", "update", "insert", "delete"]):
             return sql.strip() # Return cleaned SQL
        else:
            raise ValueError(f"Parser generated invalid/non-SQL: {sql}")
    except ValueError as e:
        print(f"Parser failed: {e}", file=sys.stderr)
        raise # Re-raise to signal failure to the orchestrator

def translate_with_gemini(sentence):
    """Attempts translation using the Gemini API."""
    if not gemini_model or not GEMINI_API_KEY or GEMINI_API_KEY == "DUMMY_KEY_SO_IT_DOESNT_CRASH":
        raise ConnectionError("Gemini API not configured or key missing.")
    
    prompt = f"""
Translate the following English query into a single, valid SQL statement based on the provided schema.
Return ONLY the SQL query, nothing else.

{SCHEMA_INFO}

English Query: "{sentence}"

SQL Query:
"""
    try:
        response = gemini_model.generate_content(prompt)
        sql = response.text.strip()
        # Clean up potential markdown/fencing
        if sql.startswith("```sql"):
            sql = sql[6:]
        if sql.endswith("```"):
            sql = sql[:-3]
        sql = sql.strip()
        # Stricter validation: Check if starts with SQL keyword
        sql_lower = sql.lower()
        if sql_lower and any(sql_lower.startswith(kw) for kw in ["select", "update", "insert", "delete"]):
             return sql
        else:
            raise ValueError(f"Fallback 1 (Gemini) returned invalid/non-SQL: {sql}")
    except Exception as e:
        print(f"Gemini API error: {e}", file=sys.stderr)
        raise ConnectionError(f"Gemini API error: {e}")

def translate_with_llama(sentence, model_name='llama3'):
    """Attempts translation using a local Ollama model."""
    prompt = f"""
Translate the following English query into a single, valid SQL statement based on the provided schema.
Return ONLY the SQL query, nothing else.

{SCHEMA_INFO}

English Query: "{sentence}"

SQL Query:
"""
    try:
        response = ollama.chat(model=model_name, messages=[
            {'role': 'user', 'content': prompt}
        ])
        sql = response['message']['content'].strip()
        # Clean up potential markdown/fencing
        if sql.startswith("```sql"):
            sql = sql[6:]
        if sql.endswith("```"):
            sql = sql[:-3]
        sql = sql.strip()
         # Stricter validation: Check if starts with SQL keyword
        sql_lower = sql.lower()
        if sql_lower and any(sql_lower.startswith(kw) for kw in ["select", "update", "insert", "delete"]):
             return sql
        else:
            raise ValueError(f"Fallback 2 (Llama) returned invalid/non-SQL: {sql}")
    except Exception as e:
        # Catch potential connection errors if ollama isn't running
        print(f"Ollama ({model_name}) error: {e}", file=sys.stderr)
        raise ConnectionError(f"Ollama ({model_name}) error: {e}")


def translate_to_sql(sentence):
    """Orchestrates translation using parser, Gemini, and Llama fallbacks."""
    # 1. Try Parser
    try:
        sql = translate_with_parser(sentence)
        print("Translation successful: Parser")
        return sql, "Success" # Generic success type
    except ValueError as e:
        print(f"Parser failed: {e}", file=sys.stderr)
        # Proceed to fallbacks

    # 2. Check Internet and Try Fallback 1 (Gemini)
    if check_internet():
        try:
            sql = translate_with_gemini(sentence)
            print("Translation successful: Fallback 1 (Online)")
            return sql, "Success" # Generic success type
        except ConnectionError as e:
            print(f"Fallback 1 (Online) failed: {e}", file=sys.stderr)
            # Proceed to Llama if Gemini fails even with internet
        except Exception as e: # Catch other potential Gemini errors
             print(f"Fallback 1 (Online) failed unexpectedly: {e}", file=sys.stderr)

    # 3. Try Fallback 2 (Llama - either no internet or Fallback 1 failed)
    try:
        sql = translate_with_llama(sentence)
        print("Translation successful: Fallback 2 (Offline/Backup)")
        return sql, "Success" # Generic success type
    except ConnectionError as e:
        print(f"Fallback 2 (Offline/Backup) failed: {e}", file=sys.stderr)
    except Exception as e: # Catch other potential Llama errors
        print(f"Fallback 2 (Offline/Backup) failed unexpectedly: {e}", file=sys.stderr)


    # 4. All methods failed
    print("Translation failed: All methods exhausted.")
    return None, "Failed"

# --- End Pre-validation and Translation Logic ---

def generate_random_queries(num_per_type=10):
    attributes = ["name", "roll", "cpi", "course_id", "course_name", "credits"]
    student_attrs = attributes[:3]
    course_attrs = attributes[3:]
    numeric_student_attrs = ["roll", "cpi"]
    numeric_course_attrs = ["course_id", "credits"]
    comparison_ops = ["more than", "less than", "equal to"]
    names = ["Sanya", "Aarav", "Neha", "Rohan", "Kavya", "John", "Alice", "Bob"]
    course_names = ["Math", "Physics", "Chemistry", "Biology", "History"]
    
    queries = {"select": [], "update": [], "insert": [], "delete": []}

    # SELECT queries (Student)
    for _ in range(num_per_type // 2): # Half student, half course
        query_type = random.choice(["give", "show"])
        attr_count = random.randint(1, 3)
        attrs = random.sample(student_attrs, attr_count)
        attr_str = " and ".join(attrs) if len(attrs) > 1 else attrs[0]
        me_str = "me " if query_type == "give" else ""
        
        if random.choice([True, False]):
            cond_attr = random.choice(student_attrs)
            if cond_attr == "name":
                comp_op = "equal to"
                cond_value = random.choice(names)
            else:
                comp_op = random.choice(comparison_ops)
                cond_value = str(random.randint(1, 10))
            sentence = f"Please {query_type} {me_str}the {attr_str} of the students where {cond_attr} is {comp_op} {cond_value}"
        else:
            sentence = f"Please {query_type} {me_str}the {attr_str} of the students"
        queries["select"].append(sentence)

    # SELECT queries (Course)
    for _ in range(num_per_type - (num_per_type // 2)):
        query_type = random.choice(["give", "show"])
        attr_count = random.randint(1, 3)
        attrs = random.sample(course_attrs, attr_count)
        attr_str = " and ".join(attrs) if len(attrs) > 1 else attrs[0]
        me_str = "me " if query_type == "give" else ""

        if random.choice([True, False]):
            cond_attr = random.choice(course_attrs)
            if cond_attr == "course_name":
                comp_op = "equal to"
                cond_value = random.choice(course_names)
            else: # course_id or credits
                comp_op = random.choice(comparison_ops)
                cond_value = str(random.randint(1, 100 if cond_attr == "course_id" else 5))
            sentence = f"Please {query_type} {me_str}the {attr_str} of the courses where {cond_attr} is {comp_op} {cond_value}"
        else:
            sentence = f"Please {query_type} {me_str}the {attr_str} of the courses"
        queries["select"].append(sentence)


    # UPDATE queries (Student)
    for _ in range(num_per_type):
        attr1 = random.choice(student_attrs)
        attr2 = random.choice(numeric_student_attrs) # roll or cpi
        num1 = str(random.uniform(1, 9999) if attr2 == "roll" else random.uniform(0, 10))[:5]
        if attr1 == "name":
            num2 = random.choice(names)
        else:
            num2 = str(random.uniform(0, 9999) if attr1 == "roll" else random.uniform(0, 10))[:5]
        sentence = f"Please update the {attr1} of the student having {attr2} no {num1} to {num2}"
        queries["update"].append(sentence)
        # Note: Update for Course table is not implemented in the parser, so only generating student updates.

    # INSERT queries
    for _ in range(num_per_type):
        table_choice = random.choice(["students", "courses"])
        if table_choice == "students":
            roll = str(random.randint(1000, 9999))
            name = random.choice(names)
            cpi = str(random.uniform(0, 10))[:4]
            sentence = f"Please add a student with roll {roll} name {name} cpi {cpi}"
        else: # courses
            course_id = str(random.randint(1, 100))
            course_name = random.choice(course_names)
            credits = str(random.randint(1, 5))
            sentence = f"Please add a course with course_id {course_id} course_name {course_name} credits {credits}"
        queries["insert"].append(sentence)

    # DELETE queries
    for _ in range(num_per_type):
        table_choice = random.choice(["students", "courses"])
        if table_choice == "students":
            attr = random.choice(numeric_student_attrs) # roll or cpi
            comp_op = random.choice(comparison_ops)
            val = str(random.randint(1000, 9999) if attr == "roll" else random.uniform(0, 10))[:4]
            sentence = f"Please remove the student where {attr} is {comp_op} {val}"
        else: # courses
            attr = random.choice(numeric_course_attrs) # course_id or credits
            comp_op = random.choice(comparison_ops)
            val = str(random.randint(1, 100) if attr == "course_id" else random.randint(1, 5))
            sentence = f"Please remove the course where {attr} is {comp_op} {val}"
        queries["delete"].append(sentence)

    return queries

class ResultsWindow(QMainWindow):
    def __init__(self, column_names, results, message):
        super().__init__()
        self.setWindowTitle("Query Results")
        self.setGeometry(200, 200, 600, 400)

        self.central_widget = QWidget()
        self.setCentralWidget(self.central_widget)
        self.layout = QVBoxLayout(self.central_widget)

        if message:
            self.message_label = QLabel(message)
            self.layout.addWidget(self.message_label)

        if column_names and results:
            self.table = QTableWidget()
            self.table.setRowCount(len(results))
            self.table.setColumnCount(len(column_names))
            self.table.setHorizontalHeaderLabels(column_names)

            for row_idx, row in enumerate(results):
                for col_idx, item in enumerate(row):
                    self.table.setItem(row_idx, col_idx, QTableWidgetItem(str(item)))

            self.table.resizeColumnsToContents()
            self.layout.addWidget(self.table)
        elif not message:
            self.message_label = QLabel("No results found.")
            self.layout.addWidget(self.message_label)

class SQLTranslatorWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("English to SQL Translator")
        self.setGeometry(50, 50, 1000, 600) # Increased size

        self.central_widget = QWidget()
        self.setCentralWidget(self.central_widget)
        
        # Main horizontal layout
        self.main_layout = QHBoxLayout(self.central_widget)

        # Left panel (Input/Output)
        self.left_panel_widget = QWidget()
        self.left_layout = QVBoxLayout(self.left_panel_widget)
        self.left_panel_widget.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Preferred) # Allow left panel to expand

        self.input_label = QLabel("Enter English Query:")
        self.left_layout.addWidget(self.input_label)
        self.input_text = QLineEdit()
        self.left_layout.addWidget(self.input_text)

        self.translate_button = QPushButton("Translate and Execute")
        self.translate_button.clicked.connect(self.translate_and_execute)
        self.left_layout.addWidget(self.translate_button)

        self.random_button = QPushButton("Generate Random Query")
        self.random_button.clicked.connect(self.generate_random)
        self.left_layout.addWidget(self.random_button)

        self.output_label = QLabel("SQL Output:")
        self.left_layout.addWidget(self.output_label)
        self.output_text = QTextEdit()
        self.output_text.setReadOnly(True)
        self.left_layout.addWidget(self.output_text)
        
        self.main_layout.addWidget(self.left_panel_widget, 2) # Give left panel more stretch factor

        # Right panel (Example Queries)
        self.right_panel_widget = QWidget()
        self.right_layout = QVBoxLayout(self.right_panel_widget)
        self.right_panel_widget.setMinimumWidth(350) # Set a minimum width for examples
        self.right_panel_widget.setSizePolicy(QSizePolicy.Policy.Fixed, QSizePolicy.Policy.Preferred) # Fixed width

        example_queries = generate_random_queries(num_per_type=10)

        # SELECT Examples
        self.select_label = QLabel("<b>SELECT Examples (Click to use):</b>")
        self.right_layout.addWidget(self.select_label)
        self.select_examples_list = QListWidget()
        self.select_examples_list.addItems(example_queries["select"])
        self.select_examples_list.itemClicked.connect(self.on_example_clicked)
        self.right_layout.addWidget(self.select_examples_list)

        # UPDATE Examples
        self.update_label = QLabel("<b>UPDATE Examples (Click to use):</b>")
        self.right_layout.addWidget(self.update_label)
        self.update_examples_list = QListWidget()
        self.update_examples_list.addItems(example_queries["update"])
        self.update_examples_list.itemClicked.connect(self.on_example_clicked)
        self.right_layout.addWidget(self.update_examples_list)

        # INSERT Examples
        self.insert_label = QLabel("<b>INSERT Examples (Click to use):</b>")
        self.right_layout.addWidget(self.insert_label)
        self.insert_examples_list = QListWidget()
        self.insert_examples_list.addItems(example_queries["insert"])
        self.insert_examples_list.itemClicked.connect(self.on_example_clicked)
        self.right_layout.addWidget(self.insert_examples_list)

        # DELETE Examples
        self.delete_label = QLabel("<b>DELETE Examples (Click to use):</b>")
        self.right_layout.addWidget(self.delete_label)
        self.delete_examples_list = QListWidget()
        self.delete_examples_list.addItems(example_queries["delete"])
        self.delete_examples_list.itemClicked.connect(self.on_example_clicked)
        self.right_layout.addWidget(self.delete_examples_list)

        self.main_layout.addWidget(self.right_panel_widget, 1) # Give right panel less stretch factor

    def on_example_clicked(self, item):
        """Sets the text of the clicked example query into the input field."""
        self.input_text.setText(item.text())

    def translate_and_execute(self):
        query = self.input_text.text().strip()
        if not query:
            QMessageBox.warning(self, "Input Error", "Please enter a query!")
            return
        
        sql, error = translate_to_sql(query)
        self.output_text.setText(f"Input: {query}\nOutput: {sql if sql else error}")
        
        if sql:
            column_names, results, message = execute_sql_query(sql)
            self.results_window = ResultsWindow(column_names, results, message)
            self.results_window.show()

    def translate_and_execute(self):
        query = self.input_text.text().strip()
        if not query:
            QMessageBox.warning(self, "Input Error", "Please enter a query!")
            return

        # Pre-validation check
        if not is_likely_query(query):
            self.output_text.setText(f"Input: {query}\nError: not a valid query")
            QMessageBox.warning(self, "Input Error", "Input does not appear to be a valid database query.")
            return

        # Use the translation orchestrator
        sql, status = translate_to_sql(query) 
        
        if status == "Success" and sql:
            # Removed the "Translated by" part
            self.output_text.setText(f"Input: {query}\nOutput SQL: {sql}") 
            column_names, results, message = execute_sql_query(sql)
            self.results_window = ResultsWindow(column_names, results, message)
            self.results_window.show()
        else:
            # Generic failure message
            self.output_text.setText(f"Input: {query}\nTranslation Failed") 
            QMessageBox.critical(self, "Translation Error", "Could not translate the query.")


    def generate_random(self):
        # Pick a random query from any category for the input field
        all_examples = generate_random_queries(1) # Generate one of each type
        random_category = random.choice(list(all_examples.keys()))
        random_query = all_examples[random_category][0]

        self.input_text.setText(random_query)
        
        # Use the translation orchestrator
        sql, status = translate_to_sql(random_query) 

        if status == "Success" and sql:
             # Removed the "Translated by" part
            self.output_text.setText(f"Input: {random_query}\nOutput SQL: {sql}")
            # Automatically execute the generated random query for demonstration
            column_names, results, message = execute_sql_query(sql)
            self.results_window = ResultsWindow(column_names, results, message)
            self.results_window.show()
        else:
             # Generic failure message for random generation
            self.output_text.setText(f"Input: {random_query}\nTranslation Failed")

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = SQLTranslatorWindow()
    window.show()
    sys.exit(app.exec())
