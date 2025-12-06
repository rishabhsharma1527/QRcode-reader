from flask_wtf import FlaskForm

class LoginForm(FlaskForm):
    """Empty form class just for CSRF protection"""
    pass

class EmptyForm(FlaskForm):
    """Generic empty form for CSRF on other pages"""
    pass