from flask import Flask, render_template
# import os

app = Flask(__name__)

@app.route("/")
def index():
    pagetitle = "HomePage"
    return render_template("index.html",
                            mytitle=pagetitle,
                            mycontent="Hello World")

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=8080)