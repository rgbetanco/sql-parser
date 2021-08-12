from flask import Flask, redirect, url_for, render_template,request
import socket

app = Flask(__name__)

TCP_HOST = '192.168.11.165'
TCP_PORT = 6666

@app.route("/", methods=["POST","GET"])
def index():
    if request.method == "POST":
        sql_statement = request.form["sql_statement"]

        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((TCP_HOST, TCP_PORT))
        outdata = sql_statement
        s.send(outdata.encode())
        print('send: ' + outdata)

        while True:
            receive_data = s.recv(1024)
            if len(receive_data) == 0: # connection closed
                s.close()
                print('server closed connection.')
                break
            result = receive_data.decode()
            print('recv: ' + result)

        return result
    else:
        return render_template("index.html")

if __name__=="__main__":
    app.run(host="0.0.0.0", debug=True, port=8000)