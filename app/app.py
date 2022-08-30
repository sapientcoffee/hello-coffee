import os
import json
from flask import Flask, render_template

app = Flask(__name__)
# os.getenv('name_of_variable')
# os.environ
# os.environ['name_of_variable']

# @app.route("/")
# def hello_world():
#     name = os.environ.get("NAME", "World")
#     return "Hello {}!".format(name)

@app.route("/")
def home():


    # Iterate loop to read and print all environment variables
    print("The keys and values of all environment variables:")
    for key in os.environ:
        print(key, '=>', os.environ[key])

    # Print the value of the particular environment variable
    print("The value of HOME is: ", os.environ['HOME'])
    
    var = 'v60'

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