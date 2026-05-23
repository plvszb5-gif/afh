% rebase('layout', title='Кабинет Бухгалтера', role='afh_accountant')

<div class="dashboard-grid">
    <section class="card col-full">
        <div class="card-header">
            <h2 class="section-title">Просроченные членские взносы</h2>
            <a href="/accountant/production_report" class="btn btn-secondary">Отчёты</a>
        </div>
        
        % if overdue:
        <div class="table-wrap">
            <table class="table">
                <thead>
                    <tr>
                        <th>ID фермы</th>
                        <th>Название</th>
                        <th>Год</th>
                        <th>Сумма (₽)</th>
                        <th>Дата оплаты</th>
                        <th>Дней просрочки</th>
                        <th>Действие</th>
                    </tr>
                </thead>
                <tbody>
                    % for row in overdue:
                    <tr>
                        <td>{{row[0]}}</td>
                        <td>{{row[1]}}</td>
                        <td>{{row[2]}}</td>
                        <td>{{row[3]}}</td>
                        <td>{{row[4] if row[4] else '—'}}</td>
                        <td>{{row[5] if row[5] else 0}}</td>
                        <td>
                            <form action="/accountant/update_fee" method="POST" style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;">
                                <input type="hidden" name="payment_number" value="{{row[0]}}">
                                <input type="date" name="payment_date" value="{{row[4]}}" class="form-control" style="min-width:140px;">
                                <select name="payment_status" class="form-control" style="min-width:150px;">
                                    <option value="Ожидает оплаты" {{'selected' if row[6]=='Ожидает оплаты' else ''}}>Ожидает оплаты</option>
                                    <option value="Оплачен" {{'selected' if row[6]=='Оплачен' else ''}}>Оплачен</option>
                                    <option value="Списан" {{'selected' if row[6]=='Списан' else ''}}>Списан</option>
                                </select>
                                <input type="text" name="basis_document_code" placeholder="Код док." class="form-control" style="min-width:120px;" value="{{row[7] if len(row)>7 and row[7] else ''}}">
                                <button type="submit" class="btn btn-primary">💾</button>
                            </form>
                        </td>
                    </tr>
                    % end
                </tbody>
            </table>
        </div>
        % else:
        <p style="padding:20px;text-align:center;color:var(--text-muted);">✅ Нет просроченных взносов</p>
        % end
    </section>

    <section class="card col-full">
        <h2 class="section-title">🛒 Статус коллективных закупок</h2>
        
        % if purchases:
        <div class="table-wrap">
            <table class="table">
                <thead>
                    <tr>
                        <th>Код</th>
                        <th>Название</th>
                        <th>Поставщик</th>
                        <th>План. дата</th>
                        <th>Статус</th>
                        <th>Заказано</th>
                        <th>Отгружено</th>
                        <th>Получено</th>
                    </tr>
                </thead>
                <tbody>
                    % for row in purchases:
                    <tr>
                        <td>{{row[0]}}</td>
                        <td>{{row[1]}}</td>
                        <td>{{row[2]}}</td>
                        <td>{{row[3]}}</td>
                        <td><span class="role-badge" style="background:{{'var(--accent-success)' if row[4]=='Выполнен' else 'var(--accent-warning)'}};color:white;padding:4px 8px;border-radius:4px;">{{row[4]}}</span></td>
                        <td>{{row[5]}}</td>
                        <td>{{row[6]}}</td>
                        <td>{{row[7]}}</td>
                    </tr>
                    % end
                </tbody>
            </table>
        </div>
        % else:
        <p style="padding:20px;text-align:center;color:var(--text-muted);">📭 Нет данных о закупках</p>
        % end
    </section>
</div>