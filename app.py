import os
import socket

from flask import Flask, jsonify, redirect, request, render_template_string, url_for

API_KEY = os.environ.get("API_KEY")
VERSION = os.environ.get("VERSION", "1.0.0")
PORT = int(os.environ.get("PORT", "5000"))
HOST_NAME = socket.gethostname()

app = Flask(__name__)

if not API_KEY:
    raise RuntimeError("API_KEY environment variable is required")



@app.route("/")
def status_dashboard():
    return render_template_string("""
    <!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Status Dashboard</title>
</head>
<body>
    <h1>Status Dashboard</h1>
    <p>Internal service status dashboard for Acme Internal Tools Ltd.</p>

    <button onclick="checkStatus()">Check Status</button>

    <pre id="result"></pre>

    <script>
        async function checkStatus() {
            const response = await fetch("/api/v1/status");
            const data = await response.json();
            document.getElementById("result").textContent =
                JSON.stringify(data, null, 2);
        }
    </script>
</body>
</html>
""")
    
@app.route("/api/status")
def redirect_status():
    return redirect(url_for(f"api_v1_status")) 

@app.route("/api/secret")    
def redirect_secret():
    return redirect(url_for(f"api_v1_secret"))


@app.route("/api/v1/status")
def api_v1_status():
    return jsonify({
        "status": "ok",
        "hostname": HOST_NAME,
        "version": VERSION
    })


@app.route("/api/v1/secret")
def api_v1_secret():
    request_api_key = request.headers.get("X-API-Key")

    if request_api_key != API_KEY:
        return jsonify({"error": "Unauthorized"}), 401

    return jsonify({"message": "you found the secret"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=PORT)


