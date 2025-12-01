# Copy the code from this file to your Flask matchmaking server

from flask import Flask, request, jsonify
import random
import string

matchmaking = {}

app = Flask(__name__)

def get_client_ip():
    if request.headers.get("X-Forwarded-For"):
        return request.headers.get("X-Forwarded-For").split(",")[0]
    return request.remote_addr

@app.route("/register", methods=["POST"])
def register():
    code = ''.join(random.choices(string.digits, k=4))
    remote_addr = get_client_ip()
    matchmaking[code] = remote_addr
    return jsonify({"code": code, "success": True})

@app.route("/resolve", methods=["GET"])
def resolve():
    code = request.args.get("code")
    if code in matchmaking:
        host_addr = matchmaking[code]
        return jsonify({"address": host_addr})
    return jsonify({"error": "Code not found"}), 404

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

