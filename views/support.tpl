% rebase('layout', title='Кабинет Поддержки', role='afh_support_manager')

<div class="dashboard-grid">
    <section class="card col-half">
        <h2 class="section-title">➕ Новое обращение</h2>
        <form action="/support/create_request" method="POST">
            <div class="form-group">
                <label class="form-label">Ферма</label>
                <select name="member_id" class="form-control" required>
                    % for m in members: <option value="{{m[0]}}">{{m[1]}} (ID: {{m[0]}})</option> % end
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">Тема</label>
                <input type="text" name="subject" class="form-control" required>
            </div>
            <div class="form-group">
                <label class="form-label">Описание</label>
                <textarea name="request_text" class="form-control" rows="3" required></textarea>
            </div>
            <button type="submit" class="btn btn-primary">📤 Создать</button>
        </form>
    </section>

    <section class="card col-half">
        <h2 class="section-title">📋 Активные обращения</h2>
        <div class="table-wrap">
            <table class="table">
                <thead><tr><th>ID</th><th>Дата</th><th>Тема</th><th>Ферма</th><th>Статус</th><th>Обновить</th></tr></thead>
                <tbody>
                    % for row in requests:
                    <tr>
                        <td>{{row[0]}}</td><td>{{row[1]}}</td><td>{{row[2]}}</td><td>{{row[5]}}</td>
                        <td><span class="role-badge" style="background:{{'var(--accent-primary)' if row[3]=='В работе' else 'var(--bg-subtle)'}}">{{row[3]}}</span></td>
                        <td>
                            <form action="/support/update_request" method="POST" style="display:flex; gap:8px;">
                                <input type="hidden" name="request_id" value="{{row[0]}}">
                                <select name="processing_status" class="form-control">
                                    <option>Новый</option><option>В работе</option><option>Решено</option><option>Закрыт</option>
                                </select>
                                <button type="submit" class="btn btn-secondary">✅</button>
                            </form>
                        </td>
                    </tr>
                    % end
                    % if not requests: <tr><td colspan="6" class="text-center"> Обращений нет</td></tr> % end
                </tbody>
            </table>
        </div>
    </section>
</div>