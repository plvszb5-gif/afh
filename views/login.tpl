<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Вход в АФХ</title>
    <link rel="stylesheet" href="/static/css/base.css">
    <link rel="stylesheet" href="/static/css/main.css">
</head>
<body style="background:var(--bg-subtle); display:flex; align-items:center; justify-content:center; min-height:100vh;">
    <div class="card" style="max-width:480px; width:100%;">
        <h1 class="text-center">🔐 Авторизация</h1>
        % if error:
            <div style="background:#F8D7DA; color:#721C24; padding:12px; border-radius:8px; margin-bottom:16px;">{{error}}</div>
        % end
        <form method="POST" action="/login">
            <div class="form-group">
                <label class="form-label">Роль</label>
                <select name="role" class="form-control" required>
                    <option value="afh_accountant">Бухгалтер</option>
                    <option value="afh_support_manager">Оператор поддержки</option>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">Пароль</label>
                <input type="password" name="password" class="form-control" required autocomplete="current-password">
            </div>
            <button type="submit" class="btn btn-primary" style="width:100%;">Войти</button>
        </form>
    </div>
</body>
</html>