<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{title or 'АФХ Система'}}</title>
    <link rel="stylesheet" href="/static/css/base.css">
    <link rel="stylesheet" href="/static/css/main.css">
</head>
<body>
    <a href="#main-content" class="skip-link">Перейти к содержимому</a>

    <header class="app-header" role="banner">
        <div class="container header-inner">
            <a href="/" class="logo">🌾 АФХ Система</a>
            <nav class="nav-links" aria-label="Основная навигация">
                % if role == 'afh_accountant':
                    <a href="/accountant/dashboard" class="nav-link">📊 Дашборд</a>
                    <a href="/accountant/production_report" class="nav-link">📈 Отчёты</a>
                % elif role == 'afh_support_manager':
                    <a href="/support/dashboard" class="nav-link">🛟 Обращения</a>
                % end
                
                % if role:
                    <span class="role-badge">{{ 'Бухгалтер' if role == 'afh_accountant' else 'Поддержка' }}</span>
                    <a href="/logout" class="nav-link" aria-label="Выйти из системы">🚪 Выйти</a>
                % end
            </nav>
        </div>
    </header>

    <main id="main-content" class="container" role="main">
        {{base}}
    </main>

    <footer class="app-footer" role="contentinfo">
        <div class="container">
            <div class="footer-links">
                <a href="#">Политика конфиденциальности</a>
                <a href="#">Техподдержка</a>
                <a href="#">Документация</a>
            </div>
            <p>© 2026 АФХ Система. Все права защищены. v1.2.0</p>
        </div>
    </footer>
</body>
</html>