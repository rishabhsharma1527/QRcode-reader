"""
Multi-page QR Code Generator and Scanner with login.

Run:
  python app.py
Open in browser:
  http://127.0.0.1:5000

Features:
- Login system (demo account: demo/password123)
- Generate QR codes
- Scan with camera
- Upload and scan QR images
"""

from flask import Flask, render_template, request, send_file, redirect, url_for, flash
from flask_login import LoginManager, login_user, logout_user, login_required, current_user
from flask_wtf.csrf import CSRFProtect
import qrcode
from io import BytesIO
from users import User, init_demo_user, get_user
from forms import LoginForm

app = Flask(__name__)
app.config['SECRET_KEY'] = 'dev-key-please-change-in-production'  # Change this!
csrf = CSRFProtect(app)

# Setup Flask-Login
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

@login_manager.user_loader
def load_user(username):
    return get_user(username)

# Create demo user
init_demo_user()

@app.route('/')
def home():
    """Redirect to login if not authenticated, otherwise to QR generator."""
    if current_user.is_authenticated:
        return redirect(url_for('generate_qr'))
    # Render the login page with a WTForms form so CSRF token is available
    form = LoginForm()
    return render_template('login.html', form=form)

@app.route('/login', methods=['GET', 'POST'])
def login():
    """Handle user login."""
    if current_user.is_authenticated:
        return redirect(url_for('generate_qr'))
    
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        user = get_user(username)
        
        if user and user.verify_password(password):
            login_user(user)
            flash('Logged in successfully.', 'success')
            return redirect(url_for('generate_qr'))
        
        flash('Invalid username or password', 'error')
    
    form = LoginForm()
    return render_template('login.html', form=form)

@app.route('/logout')
def logout():
    """Handle user logout."""
    logout_user()
    flash('You have been logged out.', 'success')
    return redirect(url_for('login'))

@app.route('/generate', methods=['GET', 'POST'])
@login_required
def generate_qr():
    """Show QR generator page and handle QR code generation."""
    from forms import EmptyForm
    form = EmptyForm()
    if request.method == 'GET':
        return render_template('generate.html', form=form)
    
    text = request.form.get('data', '').strip()
    if not text:
        return redirect(url_for('generate_qr'))

    # Create QR image (Pillow image)
    img = qrcode.make(text)

    # Put image into an in-memory bytes buffer and return
    buf = BytesIO()
    img.save(buf, format='PNG')
    buf.seek(0)

    # send_file will prompt the browser to download the PNG named 'qr.png'
    return send_file(buf, mimetype='image/png', as_attachment=True, download_name='qr.png')

@app.route('/scan')
@login_required
def scan_qr():
    """Show QR scanner page with camera access."""
    # scan page doesn't need a CSRF form since it doesn't POST to server
    return render_template('scan.html')

@app.route('/upload')
@login_required
def upload_qr():
    """Show QR upload page for scanning from files."""
    # upload page uses client-side scanning and doesn't POST to server
    return render_template('upload.html')

if __name__ == '__main__':
    # debug=True is convenient while editing locally; remove for production.
    app.run(debug=True, port=5000)
