import os
from flask import Flask, render_template, request, redirect
import mysql.connector
from mysql.connector import Error

DB_HOST = os.environ.get("DB_HOST", "db")
DB_USER = os.environ.get("DB_USER", "myuser")
DB_PASSWORD = os.environ.get("DB_PASSWORD", "mypassword")
DB_NAME = os.environ.get("DB_NAME", "mydb")

def get_conn():
    return mysql.connector.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME
    )

app = Flask(__name__)
app._db_initialized = False

def init_db():
    try:
        conn = get_conn()
        cursor = conn.cursor()
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS people (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(100),
                age INT,
                ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        conn.commit()
        cursor.close()
        conn.close()
        print("Database initialized.")
    except Exception as e:
        print("DB init error:", e)

try:
    app.before_first_request(init_db)
except AttributeError:
    @app.before_request
    def before_any_request():
        if not app._db_initialized:
            init_db()
            app._db_initialized = True

@app.route("/", methods=["GET", "POST"])
def index():
    conn = get_conn()
    cursor = conn.cursor()

    if request.method == "POST":
        name = request.form.get("name")
        age = request.form.get("age")
        if name and age:
            cursor.execute("INSERT INTO people (name, age) VALUES (%s, %s)", (name, age))
            conn.commit()
        return redirect("/")  # refresh page to show update

    cursor.execute("SELECT name, age, ts FROM people ORDER BY ts DESC")
    people = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template("index.html", people=people)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

# For Flask 2.x compatibility
try:
    app.before_first_request(init_db)
except AttributeError:
    # For Flask 3.x — run init once on the first request
    @app.before_request
    def before_any_request():
        if not app._db_initialized:
            init_db()
            app._db_initialized = True

@app.route("/", methods=["GET", "POST"])
def index():
    try:
        conn = get_conn()
        cursor = conn.cursor()

        if request.method == "POST":
            cursor.execute("INSERT INTO visits () VALUES ()")
            conn.commit()

        cursor.execute("SELECT COUNT(*) FROM visits")
        count = cursor.fetchone()[0]
        cursor.close()
        conn.close()

        return render_template("index.html", visits=count)
    except Error as e:
        return f"DB error: {e}", 500

@app.route("/api/visits")
def visits():
    try:
        conn = get_conn()
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM visits")
        count = cursor.fetchone()[0]
        cursor.close()
        conn.close()
        return jsonify({"visits": count})
    except Error as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

