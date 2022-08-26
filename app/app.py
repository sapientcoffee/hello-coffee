from flask import Flask, render_template

app = Flask(__name__)

@app.route("/")
def home():
    return render_template("index.html")

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
    app.run(debug=True)