import re
import bcrypt


def user_exists(users_collection, username, email):
    # Check if a user with the given username exists
    username_query = users_collection.where('username', '==', username).stream()
    for _ in username_query:
        return True

    # Check if a user with the given email exists
    email_query = users_collection.where('email', '==', email).stream()
    for _ in email_query:
        return True

    return False


def valid_signup_fields(data):
    required_fields = {'username', 'email', 'password', 'name', 'contactNumber'}

    if not all(field in data for field in required_fields):
        print("Missing required fields")
        return False

    email_regex = r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    if not re.match(email_regex, data['email']):
        print("Invalid email format")
        return False

    password = data['password']
    if len(password) < 8:
        print("Password too short")
        return False
    if not re.search(r'[A-Za-z]', password):
        print("Password missing a letter")
        return False
    if not re.search(r'[0-9]', password):
        print("Password missing a number")
        return False

    print("Password format is valid")
    return True


def valid_login_fields(data):
    required_fields = {'username', 'password'}

    if not all(field in data for field in required_fields):
        print("Missing required fields")
        return False

    return True


def verify_credentials(users_collection, username, password):
    user_ref = users_collection.where('username', '==', username).get()
    if not user_ref:
        print("User not found")
        return False, None

    user_data = user_ref[0].to_dict()
    stored_password_hash = user_data.get('password')

    if bcrypt.checkpw(password.encode('utf-8'), stored_password_hash.encode('utf-8')):
        return True, user_data

    print("Invalid password")
    return False, None


def clean_signup_fields(data):
    return {k: v.strip() if isinstance(v, str) else v for k, v in data.items()}


def hash_password(password):
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
    return hashed_password.decode('utf-8')


def valid_vehicle_fields(data):
    required_fields = {'make', 'model', 'year', 'licensePlate', 'vin', 'imageUrl', 'username'}

    if not all(field in data for field in required_fields):
        print("Missing required fields")
        return False

    if not isinstance(data['year'], int) or data['year'] < 1886 or data[
        'year'] > 9999:  # Assuming vehicles from year 1886 onwards
        print("Invalid year")
        return False

    return True


def clean_vehicle_fields(data):
    return {k: v.strip() if isinstance(v, str) else v for k, v in data.items()}