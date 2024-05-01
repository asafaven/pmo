from flask import Flask, render_template
app = Flask(__name__)

# two decorators, same function
@app.route('/')
def index():
    return render_template('index.html', the_title='Index Home Page')

if __name__ == '__main__':
    port = 6000
    app.run(debug=True, host='0.0.0.0', port=port)