<!DOCTYPE html>
<html lang="ru">
<head><meta charset="UTF-8"><title>Кабинет Поддержки</title></head>
<body style="font-family:sans-serif; padding:20px;">
  <h1>🛟 Кабинет Оператора Поддержки</h1>
  <a href="/logout">Выйти</a>
  
  <h2>➕ Создать обращение</h2>
  <form action="/support/create_request" method="POST" style="margin-bottom:20px;">
    <select name="member_id" required>
      % for m in members:
        <option value="{{m[0]}}">{{m[1]}} (ID: {{m[0]}})</option>
      % end
    </select>
    <input type="text" name="subject" placeholder="Тема обращения" required style="width:300px;">
    <textarea name="request_text" placeholder="Текст обращения" required style="width:300px;height:60px;"></textarea><br>
    <input type="text" name="responsible_employee" placeholder="ID сотрудника">
    <button>Создать</button>
  </form>

  <h2>📋 Панель обращений</h2>
  <table border="1" cellpadding="5">
    <tr><th>ID</th><th>Дата</th><th>Тема</th><th>Ферма</th><th>Телефон</th><th>Статус</th><th>Сотрудник</th><th>Дней открыто</th><th>Обновить</th></tr>
    % for row in requests:
      <tr>
        <td>{{row[0]}}</td><td>{{row[1]}}</td><td>{{row[2]}}</td><td>{{row[5]}}</td><td>{{row[6]}}</td><td>{{row[3]}}</td><td>{{row[9]}}</td><td>{{row[10]}}</td>
        <td>
          <form action="/support/update_request" method="POST">
            <input type="hidden" name="request_id" value="{{row[0]}}">
            <select name="processing_status">
              <option>Новый</option><option>В работе</option><option>Решено</option><option>Закрыт</option>
            </select>
            <input type="text" name="responsible_employee" value="{{row[9]}}" size="10">
            <button>Обновить</button>
          </form>
        </td>
      </tr>
    % end
  </table>
</body>
</html>