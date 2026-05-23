import os
from bottle import Bottle, run, request, response, redirect, template, abort, static_file
import psycopg2
from functools import wraps
from dotenv import load_dotenv

load_dotenv()

app = Bottle()

# Конфигурация БД (в production используйте пул соединений, например pgBouncer или SQLAlchemy)
DB_CONFIG = {
    'dbname': os.getenv('DB_NAME', 'afh'),
    'user': os.getenv('DB_USER', 'postgres'),
    'password': os.getenv('DB_PASSWORD', ''),
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': int(os.getenv('DB_PORT', '5432'))
}

SECRET = os.getenv('BOTTLE_SECRET', 'change_this_to_a_long_random_string')

def get_db():
    conn = psycopg2.connect(**DB_CONFIG)
    conn.autocommit = False
    return conn

def require_role(role):
    def decorator(fn):
        @wraps(fn)
        def wrapper(*args, **kwargs):
            current_role = request.get_cookie('role', secret=SECRET)
            if not current_role:
                redirect('/login')
            if current_role != role:
                abort(403, "Доступ запрещен: у вас нет прав для этого раздела.")
            return fn(*args, **kwargs)
        return wrapper
    return decorator

@app.route('/static/<filepath:path>')
def serve_static(filepath):
    return static_file(filepath, root='./static')

@app.route('/login', method=['GET', 'POST'])
def login():
    error = None
    if request.method == 'POST':
        role = request.forms.get('role', '').strip()
        password = request.forms.get('password', '').strip()
        
        if role not in ('afh_accountant', 'afh_support_manager'):
            error = "Недопустимая роль"
        else:
            try:
                conn = get_db()
                cur = conn.cursor()
                cur.execute("SELECT fn_check_role_access(%s, %s)", (role, password))
                is_valid = cur.fetchone()[0]
                cur.close()
                conn.close()
            except Exception as e:
                error = f"Ошибка БД: {e}"
                is_valid = False

            if is_valid:
                response.set_cookie('role', role, secret=SECRET, httponly=True, samesite='Strict', secure=True)
                routes = {'afh_accountant': 'accountant', 'afh_support_manager': 'support'}
                redirect(f'/{routes[role]}/dashboard')
            elif not error:
                error = "Неверная роль или пароль"
                
    # ⚠️ Важно: login.tpl НЕ должен использовать % rebase('layout'), 
    # чтобы не подтягивать хедер/футер на страницу входа.
    return template('login', error=error)

@app.route('/logout')
def logout():
    response.delete_cookie('role', secret=SECRET)
    redirect('/login')

@app.route('/accountant/dashboard')
@require_role('afh_accountant')
def accountant_dashboard():
    conn = get_db()
    cur = conn.cursor()
    try:
        # ИСПРАВЛЕНИЕ:
        # Представление v_overdue_membership_fees возвращает только 6 колонок и не содержит payment_number.
        # Мы используем прямой запрос, чтобы получить все 8 колонок, нужных шаблону:
        # 0: payment_number, 1: farm_name, 2: reporting_year, 3: amount, 
        # 4: payment_date, 5: days_overdue, 6: payment_status, 7: basis_document_code
        cur.execute("""
            SELECT mf.payment_number, m.farm_name, mf.reporting_year, mf.amount, mf.payment_date, 
                   (CURRENT_DATE - mf.payment_date) AS days_overdue, 
                   mf.payment_status, mf.basis_document_code
            FROM membership_fees mf
            JOIN members m ON mf.member_id = m.member_id
            WHERE mf.payment_status IN ('Ожидает оплаты', 'Частично оплачено')
              AND (mf.payment_date IS NULL OR mf.payment_date < CURRENT_DATE - INTERVAL '30 days')
            ORDER BY days_overdue DESC
        """)
        overdue = cur.fetchall()
        
        # Запрос для закупок оставляем без изменений, там всё работает корректно
        cur.execute("SELECT * FROM v_collective_purchase_status ORDER BY planned_date")
        purchases = cur.fetchall()
    finally:
        cur.close()
        conn.close()
    return template('accountant', overdue=overdue, purchases=purchases, role='afh_accountant')

@app.route('/accountant/update_fee', method='POST')
@require_role('afh_accountant')
def update_fee():
    pay_num = request.forms.get('payment_number')
    p_date = request.forms.get('payment_date') or None
    p_status = request.forms.get('payment_status')
    p_doc = request.forms.get('basis_document_code')
    
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""
            UPDATE membership_fees 
            SET payment_date=%s, payment_status=%s, basis_document_code=%s 
            WHERE payment_number=%s
        """, (p_date, p_status, p_doc, pay_num))
        conn.commit()
        redirect('/accountant/dashboard')
    except Exception as e:
        conn.rollback()
        redirect(f'/accountant/dashboard?error={e}')
    finally:
        cur.close()
        conn.close()

@app.route('/accountant/production_report')
@require_role('afh_accountant')
def production_report():
    member_id = request.query.get('member_id', 1)
    year = request.query.get('year', 2024)
    
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("SELECT * FROM fn_get_member_production_report(%s, %s)", (int(member_id), int(year)))
        report = cur.fetchall()
        cols = [desc[0] for desc in cur.description]
    finally:
        cur.close()
        conn.close()
    return template('accountant_report', report=report, cols=cols, member_id=member_id, year=year)

@app.route('/support/dashboard')
@require_role('afh_support_manager')
def support_dashboard():
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("SELECT * FROM v_support_requests_dashboard ORDER BY request_date DESC")
        requests = cur.fetchall()
        cur.execute("SELECT member_id, farm_name FROM members ORDER BY farm_name")
        members = cur.fetchall()
    finally:
        cur.close()
        conn.close()
    return template('support', requests=requests, members=members, role='afh_support_manager')

@app.route('/support/create_request', method='POST')
@require_role('afh_support_manager')
def create_request():
    member_id = request.forms.get('member_id')
    subject = request.forms.get('subject')
    text = request.forms.get('request_text')
    employee = request.forms.get('responsible_employee')
    
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""
            INSERT INTO support_requests (member_id, request_date, subject, request_text, processing_status, responsible_employee)
            VALUES (%s, CURRENT_DATE, %s, %s, 'Новый', %s)
        """, (int(member_id), subject, text, employee))
        conn.commit()
        redirect('/support/dashboard')
    except Exception as e:
        conn.rollback()
        redirect(f'/support/dashboard?error={e}')
    finally:
        cur.close()
        conn.close()

@app.route('/support/update_request', method='POST')
@require_role('afh_support_manager')
def update_request():
    req_id = request.forms.get('request_id')
    status = request.forms.get('processing_status')
    emp = request.forms.get('responsible_employee')
    
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""
            UPDATE support_requests SET processing_status=%s, responsible_employee=%s WHERE request_id=%s
        """, (status, emp, int(req_id)))
        conn.commit()
        redirect('/support/dashboard')
    except Exception as e:
        conn.rollback()
        redirect(f'/support/dashboard?error={e}')
    finally:
        cur.close()
        conn.close()

@app.route('/')
def index():
    redirect('/login')

if __name__ == '__main__':
    run(app, host='0.0.0.0', port=3000, reloader=True)