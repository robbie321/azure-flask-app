import os
from flask import Flask
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)

db_host = os.environ.get("DB_HOST")
db_name = os.environ.get("DB_NAME", "flaskappdb")
db_user = os.environ.get("DB_USER", "flaskadmin")
db_pass = os.environ.get("DB_PASS")

app.config["SQLALCHEMY_DATABASE_URI"] = (
    f"postgresql://{db_user}:{db_pass}@{db_host}/{db_name}?sslmode=require"
)

db = SQLAlchemy(app)

class Item(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)

@app.route("/")
def home():
    with app.app_context():
        db.create_all()
    item_count = Item.query.count()
    return f"<h1>Flask on Azure</h1><p>Database connected. Items in DB: {item_count}</p>"

if __name__ == "__main__":
    app.run()