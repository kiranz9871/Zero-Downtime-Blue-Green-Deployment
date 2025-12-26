from flask import Flask
import os

app = Flask(__name__)

import logging
logging.basicConfig(level=logging.INFO)

@app.route("/")
def home():
    app.logger.info("Home endpoint hit")
    return "Version 2 - GREEN", 200


@app.route("/health")
def health():
    return "OK", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8001)

