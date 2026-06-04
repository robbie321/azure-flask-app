# app.py
from flask import Flask
app = Flask(__name__)

@app.route("/")
def index():
    return "Hello from Azure!"

@app.route("/health")
def health():
    return {"status": "ok"}