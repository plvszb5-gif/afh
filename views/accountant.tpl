<!DOCTYPE html>
<html lang="ru">
<head><meta charset="UTF-8"><title>Кабинет Бухгалтера</title></head>
<body style="font-family:sans-serif; padding:20px;">
  <h1>📊 Кабинет Бухгалтера</h1>
  <a href="/logout">Выйти</a> | <a href="/accountant/production_report">📈 Отчет по производству</a>
  
  <h2>⚠️ Просроченные членские взносы</h2>
  <table border="1" cellpadding="5">
    <tr><th>ID фермы</th><th>Название</th><th>Год</th><th>Сумма</th><th>Дата оплаты</th><th>Дней просрочки</th><th>Действие</th></tr>
    % for row in overdue:
      <tr>
        <td>{{row[0]}}</td><td>{{row[1]}}</td><td>{{row[2]}}</td><td>{{row[3]}}</td><td>{{row[4]}}</td><td>{{row[5]}}</td>
        <td>
          <form action="/accountant/update_fee" method="POST">
            <input type="hidden" name="payment_number" value="{{row[0]}}"> <!-- Assuming index 0 is payment_number based on view -->
            <input type="date" name="payment_date" value="{{row[4]}}">
            <select name="payment_status">
              <option>Ожидает оплаты</option><option>Оплачен</option><option>Списан</option>
            </select>
            <input type="text" name="basis_document_code" placeholder="Код документа">
            <button>Сохранить</button>
          </form>
        </td>
      </tr>
    % end
  </table>

  <h2>🛒 Статус коллективных закупок</h2>
  <table border="1" cellpadding="5">
    <tr><th>Код</th><th>Название</th><th>Поставщик</th><th>План. дата</th><th>Статус</th><th>Заказано</th><th>Отгружено</th><th>Получено</th></tr>
    % for row in purchases:
      <tr>
        <td>{{row[0]}}</td><td>{{row[1]}}</td><td>{{row[2]}}</td><td>{{row[3]}}</td><td>{{row[4]}}</td><td>{{row[5]}}</td><td>{{row[6]}}</td><td>{{row[7]}}</td>
      </tr>
    % end
  </table>
</body>
</html>