<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <title>Вход в систему АФХ</title>
    <style>
        body { font-family: Arial, sans-serif; max-width: 400px; margin: 50px auto; padding: 20px; }
        h2 { color: #333; }
        label { display: block; margin: 10px 0 5px; }
        select, input { width: 100%; padding: 8px; margin-bottom: 15px; }
        button { background: #4CAF50; color: white; padding: 10px 20px; border: none; cursor: pointer; }
        button:hover { background: #45a049; }
        .error { color: red; margin-bottom: 15px; }
    </style>
</head>
<body>
    <h2>Авторизация</h2>
    
    % if error:
        <div class="error">{{error}}</div>
    % end
    
    <form method="POST" action="/login">
        <label for="role">Роль:</label>
        <select name="role" id="role" required>
            <option value="">-- Выберите роль --</option>
            <option value="afh_accountant">Бухгалтер</option>
            <option value="afh_support_manager">Оператор поддержки</option>
        </select>
        
        <label for="password">Пароль:</label>
        <input type="password" name="password" id="password" required placeholder="Введите пароль">
        
        <button type="submit">Войти</button>
    </form>
</body>
</html>