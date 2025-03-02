from ddtrace import tracer
from flask import Flask, request
import os
import redis
import time
import uuid

# print(os.getenv("REDIS_HOST"))

r = redis.Redis(
    host=os.getenv("REDIS_HOST") or "localhost",
    port=6379,
    db=0,
    decode_responses=True,
    password=os.getenv("REDIS_PASSWORD"),
)
DELAY = 1
app = Flask(__name__)

@app.route("/users", methods = ['POST'])
def create_user():
    json_data = request.get_json()
    username = json_data.get("username")
    time.sleep(DELAY)
    id = str(uuid.uuid4())
    r.set(id, username)
    return [username, id]

@app.route("/users")
def get_users():
    time.sleep(DELAY)
    with tracer.trace("DELAY"):
        time.sleep(DELAY)
    users = []
    for key in r.scan_iter("*"):
        users.append(key)
    return users

@app.route("/users", methods = ['DELETE'])
def delete_users():
    for key in r.scan_iter("*"):
        r.delete(key)
    return []

@app.route("/delay/<seconds>")
def set_delay(seconds):
    global DELAY
    DELAY = float(seconds)
    return "Read Users delay set to " + str(DELAY) + " seconds."

# OLD

@app.route("/users/create/<username>")
def create_user_get(username):
    time.sleep(DELAY)
    id = str(uuid.uuid4())
    r.set(id, username)
    return [username, id]

@app.route("/users/delete")
def delete_users_get():
    for key in r.scan_iter("*"):
        r.delete(key)
    return []


if __name__ == "__main__":
    # app.run(host="0.0.0.0", port=8080, debug=True)
    app.run(host="0.0.0.0", port=8080)