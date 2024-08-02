from flask import Flask, request, jsonify
import requests
import firebase_admin
from firebase_admin import credentials, firestore
from flask_cors import CORS as Cors
import helpers as h
import jwt
import datetime
import secrets

app = Flask(__name__)
Cors(app)
app.config['SECRET_KEY'] = secrets.token_hex(32)

cred = credentials.Certificate('mobiledev-final-firebase-adminsdk-xo0h5-73c2730903.json')
firebase_admin.initialize_app(cred,{'storageBucket' : 'mobiledev-final.appspot.com'})
db = firestore.client()
users = db.collection("users")
vehicles = db.collection("vehicles")


@app.route('/', methods=['GET'])
def home():
    return "<h1>Vehicle Management System</h1><p>This site is a prototype API for managing vehicles.</p>"


# User Routes
@app.route('/signup', methods=['POST'])
def signup():
    data = request.get_json()

    try:
        if h.user_exists(users, data.get('username'), data.get('email')):
            return jsonify({"msg": "User already exists"}), 400

        if not h.valid_signup_fields(data):
            return jsonify({"msg": "One or more fields are not as expected. Check that "
                                   "no required fields are missing and that password and "
                                   "email are valid"}), 400

        cleaned_data = h.clean_signup_fields(data)
        hashed_password = h.hash_password(cleaned_data.get('password'))
        cleaned_data['password'] = hashed_password

        # Use the username as the document ID
        username = cleaned_data.get('username')
        users.document(username).set(cleaned_data)

        return jsonify({"msg": "User created successfully", "userId": username}), 201

    except Exception as e:
        print(e)
        return jsonify({"msg": "An error occurred"}), 500


@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()

    if not h.valid_login_fields(data):
        return jsonify({"msg": "Invalid input data"}), 400

    username = data.get('username')
    password = data.get('password')
    verified, user_data = h.verify_credentials(users, username, password)

    if verified:
        # Generate JWT token
        token = jwt.encode({
            'user': username,
            'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=24)  # Token expires in 24 hours
        }, app.config['SECRET_KEY'], algorithm='HS256')

        return jsonify({"msg": "Login successful", "token": token}), 200
    else:
        return jsonify({"msg": "Invalid credentials"}), 401


@app.route('/update_user', methods=['PATCH'])
def update_user():
    token = None
    if 'Authorization' in request.headers:
        token = request.headers['Authorization'].split(" ")[1]

    if not token:
        return jsonify({'msg': 'Token is missing!'}), 401

    try:
        data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])
        username = data['user']
    except jwt.ExpiredSignatureError:
        return jsonify({'msg': 'Token has expired!'}), 401
    except jwt.InvalidTokenError:
        return jsonify({'msg': 'Token is invalid!'}), 401

    data = request.get_json()

    try:
        user_ref = users.document(username)
        user_ref.update(data)
        return jsonify({"msg": "User updated successfully"}), 200
    except Exception as e:
        print(e)
        return jsonify({"msg": "An error occurred"}), 500


@app.route('/view_user', methods=['GET'])
def view_user():
    token = None
    if 'Authorization' in request.headers:
        token = request.headers['Authorization'].split(" ")[1]

    if not token:
        return jsonify({'msg': 'Token is missing!'}), 401

    try:
        data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])
        username = data['user']
        user_ref = users.where('username', '==', username).stream()

        user_doc = None
        for doc in user_ref:
            user_doc = doc
            break

        if user_doc:
            user_data = user_doc.to_dict()
            response = {
                "imageurl": user_data.get("imageurl", ""),
                "name": user_data.get("name", ""),
                "contactNumber": user_data.get("contactNumber", ""),
                "email": user_data.get("email", "")
            }
            return jsonify(response), 200
        else:
            return jsonify({"error": "User not found"}), 404
    except jwt.ExpiredSignatureError:
        return jsonify({'msg': 'Token has expired!'}), 401
    except jwt.InvalidTokenError:
        return jsonify({'msg': 'Token is invalid!'}), 401


# Vehicle Routes
@app.route('/register_vehicle', methods=['POST'])
def register_vehicle():
    data = request.get_json()

    try:
        if not h.valid_vehicle_fields(data):
            return jsonify({"msg": "One or more fields are not as expected. Check that "
                                   "no required fields are missing and that year is valid"}), 400

        user_ref = users.where('username', '==', data.get('username')).get()
        if not user_ref:
            return jsonify({"msg": "User does not exist"}), 400

        cleaned_data = h.clean_vehicle_fields(data)

        vehicle_ref = vehicles.add(cleaned_data)
        return jsonify({"msg": "Vehicle registered successfully", "vehicleId": vehicle_ref[1].id}), 201

    except Exception as e:
        print(e)
        return jsonify({"msg": "An error occurred"}), 500


@app.route('/view_vehicle', methods=['GET'])
def view_vehicle():
    vehicle_id = request.args.get('vehicleId')
    vehicle_ref = vehicles.document(vehicle_id).get()

    if vehicle_ref.exists:
        return jsonify({"msg": "Vehicle found", "vehicle": vehicle_ref.to_dict()}), 200
    else:
        return jsonify({"msg": "Vehicle not found"}), 404


@app.route('/update_vehicle', methods=['PATCH'])
def update_vehicle():
    vehicle_id = request.args.get('vehicleId')
    data = request.get_json()

    try:
        vehicle_ref = vehicles.document(vehicle_id)
        vehicle_ref.update(data)
        return jsonify({"msg": "Vehicle updated successfully"}), 200
    except Exception as e:
        print(e)
        return jsonify({"msg": "An error occurred"}), 500


@app.route('/delete_vehicle', methods=['DELETE'])
def delete_vehicle():
    vehicle_id = request.args.get('vehicleId')
    vehicle_ref = vehicles.document(vehicle_id)
    vehicle_ref.delete()
    return jsonify({"msg": "Vehicle deleted successfully"}), 200


@app.route('/list_user_vehicles', methods=['GET'])
def list_user_vehicles():
    token = None
    if 'Authorization' in request.headers:
        token = request.headers['Authorization'].split(" ")[1]

    if not token:
        return jsonify({'msg': 'Token is missing!'}), 401

    try:
        data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])
        username = data.get('user')  # Use .get to avoid KeyError
        if not username:
            return jsonify({'msg': 'Username not found in token!'}), 401
    except jwt.ExpiredSignatureError:
        return jsonify({'msg': 'Token has expired!'}), 401
    except jwt.InvalidTokenError:
        return jsonify({'msg': 'Token is invalid!'}), 401

    # Find the user document by username
    user_query = users.where('username', '==', username).get()
    if not user_query:
        return jsonify({"msg": "User not found"}), 404

    user_ref = user_query[0]  # Assuming username is unique and we only get one document

    user_vehicles = vehicles.where('username', '==', username).get()

    return jsonify({"msg": "User vehicles found", "vehicles": [vehicle.to_dict() for vehicle in user_vehicles]}), 200


if __name__ == '__main__':
    app.run(debug=True)
