from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash

class User(UserMixin):
    def __init__(self, username):
        self.username = username
        self.id = username  # Use username as the ID
        self._password_hash = None

    @property
    def password(self):
        raise AttributeError('Password is not readable')

    @password.setter
    def password(self, password):
        self._password_hash = generate_password_hash(password)

    def verify_password(self, password):
        return check_password_hash(self._password_hash, password)

# For demo purposes, store users in memory
# In production, use a proper database
users = {}

def init_demo_user():
    """Create a demo user"""
    user = User('demo')
    user.password = 'password123'  # In production, use proper password management
    users[user.username] = user

def get_user(username):
    return users.get(username)