import os
import json
from flask import Flask, render_template

app = Flask(__name__)

@app.route("/")
def home():
    
    if 'stage' in os.environ:
        var = os.environ['stage']
    else:
        var = 'foobar'

    return render_template("index.html", value=var)

@app.route("/about")
def about():    
    return render_template("about.html")

@app.route("/404")
def notfound():    
    return render_template("404.html")
    
@app.route("/coffeesay")
def salvador():
    return "The best `cowsay` fork ever (well it will be :-))"

@app.route("/webstore")
def redirect_to_webstore():
    external_url = "https://ui-pcf4i4lcra-nw.a.run.app/"  
    return redirect(external_url)    
    
if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))