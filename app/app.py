import os
from flask import Flask, render_template

app = Flask(__name__)

# @app.route("/")
# def hello_world():
#     name = os.environ.get("NAME", "World")
#     return "Hello {}!".format(name)

@app.route("/")
def home():

    for k, v in os.environ.items():
        print(f'{k}={v}')

    var = 'dog'

    return render_template("index.html", value=var)

@app.route("/about")
def about():    
    return render_template("about.html")

@app.route("/404")
def notfound():    
    return render_template("404.html")
    
@app.route("/coffeesay")
def salvador():
    return "The best `cowsay` fork ever :-)"
    
if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))