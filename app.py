from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    name = os.environ.get('NAME', 'World')
    return f'Hello from Jenkins CI/CD, {name}!' # <-- This line is changed

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
