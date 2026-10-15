---
type: review-note
area: databases
course: "[[SQL — содержание]]"
topic: select-filter-functions-dates-joins
status: active
tags:
  - learning/review
  - sql
aliases:
  - Повторение SQL
---

# Подробное повторение курса SQL

Эта заметка предназначена для детального повторения всех пройденных запросов. Она охватывает PostgreSQL, подключение к БД, `SELECT`, сортировку, `WHERE`, текстовые функции, `NULL`, `CASE`, даты и интервалы, приведение типов, `DISTINCT` и соединения таблиц.

> [!tip] Как повторять SQL
> 1. Сначала прочитай объяснение темы.
> 2. Закрой готовые решения и напиши запрос самостоятельно.
> 3. Перед запуском проговори, какие строки и столбцы ожидаешь получить.
> 4. После запуска проверь количество строк, `NULL`, сортировку и дубли.
> 5. Перепиши запрос ещё раз без подсказки.

> [!warning] Подключение к БД
> Параметры учебного подключения из исходного конспекта здесь не повторяются. Пароли и строки подключения нельзя хранить в публичных заметках. Используй `<DB_HOST>`, `<DB_NAME>`, `<DB_USER>` и менеджер секретов.

## Карта пройденного материала

```text
Таблица и строка
  ↓
SELECT и FROM
  ↓
ORDER BY
  ↓
WHERE и логические условия
  ↓
Текстовые функции и NULL
  ↓
CASE и вычисляемые столбцы
  ↓
Дата, время и интервалы
  ↓
Приведение типов и DISTINCT
  ↓
JOIN нескольких таблиц
```

---

## 1. База данных и безопасное подключение

**База данных** — организованное хранилище данных. В реляционной БД данные представлены таблицами.

| Термин | Смысл |
|---|---|
| Таблица | Набор данных об одной сущности |
| Строка | Одна запись |
| Столбец | Один атрибут записи |
| Первичный ключ | Уникально определяет строку |
| Внешний ключ | Связывает строку с другой таблицей |
| Схема | Пространство имён для объектов БД |

Для подключения обычно нужны хост, порт, имя БД, пользователь и пароль. Перед работой проверь, что подключение учебное и у пользователя нет лишних прав.

### Проверь себя

1. Чем строка отличается от столбца?
2. Для чего нужен первичный ключ?
3. Что связывает внешний ключ?
4. Почему учебному пользователю не нужны административные права?

Исходные заметки: [[1. Введение в БД]], [[2. Подключение к БД]].

---

## 2. `SELECT`, `FROM`, алиасы и сортировка

Минимальная форма запроса:

```sql
select column_name
from table_name;
```

```sql
select id, username, email
from users;
```

`SELECT` определяет столбцы результата, `FROM` — источник строк.

### Почему `SELECT *` используют осторожно

- возвращаются лишние столбцы;
- увеличивается объём передачи;
- результат меняется при изменении таблицы;
- сложнее понять назначение запроса;
- возможен случайный вывод чувствительных данных.

### Алиасы

```sql
select
    u.username as login,
    u.date_joined as created_at
from users as u;
```

`AS` для алиаса обычно можно опустить, но явное написание улучшает читаемость столбцов.

### Сортировка

```sql
select id, username, date_joined
from users
order by date_joined desc, id asc;
```

- `ASC` — по возрастанию, используется по умолчанию;
- `DESC` — по убыванию;
- критерии применяются слева направо;
- без `ORDER BY` порядок строк не гарантирован.

### Логический порядок изученных частей

```text
FROM / JOIN → WHERE → SELECT → DISTINCT → ORDER BY
```

Поэтому алиас из `SELECT` обычно доступен в `ORDER BY`, но недоступен в `WHERE` того же уровня запроса.

### Проверь себя

1. Что определяют `SELECT` и `FROM`?
2. Почему порядок строк без `ORDER BY` не гарантирован?
3. Как работает сортировка по двум столбцам?
4. Почему алиас результата нельзя использовать в `WHERE` того же запроса?

Исходные материалы: [[1. SELECT и сортировка]], [[Практика 1. Задача 1]].

---

## 3. `WHERE`, сравнения и логика

`WHERE` оставляет строки, для которых условие истинно.

```sql
select id, username, score
from users
where score > 100;
```

### Операторы сравнения

| Оператор | Смысл |
|---|---|
| `=` | равно |
| `<>` или `!=` | не равно |
| `>` | больше |
| `<` | меньше |
| `>=` | больше или равно |
| `<=` | меньше или равно |

### `AND`, `OR`, `NOT`

```sql
select id, username, company_id, score
from users
where is_active = 1
  and (score > 500 or company_id = 7);
```

`AND` имеет более высокий приоритет, чем `OR`. Для сложных условий используй скобки, даже если формальный приоритет уже даёт нужный результат.

### `NULL`

`NULL` означает отсутствие известного значения. Это не `0`, не пустая строка и не `false`.

```sql
where last_name is null
where company_id is not null
```

Выражения `company_id = null` и `company_id <> null` не работают ожидаемым образом. Используй `IS NULL` и `IS NOT NULL`.

SQL использует трёхзначную логику: `TRUE`, `FALSE`, `UNKNOWN`. В `WHERE` остаются только строки с результатом `TRUE`.

### Вычисление в условии

```sql
select
    is_active,
    is_active + 1 as new_col
from users
where is_active + 1 = 2;
```

Алиас `new_col` создаётся позже `WHERE`, поэтому выражение приходится повторить или вынести в подзапрос.

### Проверь себя

1. Чем `NULL` отличается от нуля?
2. Почему `= NULL` неверно?
3. Каков приоритет `AND` и `OR`?
4. Какие строки остаются после `WHERE`?
5. Когда нужны скобки?

Исходные материалы: [[1. Фильтрация данных с WHERE]], [[Практика 2. Задача 1]], [[Практика 2. Задача 2]].

---

## 4. Текстовые функции и шаблоны

### Регистр и длина

```sql
select
    lower(first_name) as lower_first_name,
    upper(last_name) as upper_last_name,
    initcap(username) as title_username,
    length(username) as length_username
from users;
```

- `lower()` — нижний регистр;
- `upper()` — верхний регистр;
- `initcap()` — заглавная первая буква слов;
- `length()` — число символов.

Строки пишутся в одинарных кавычках: `'text'`. Двойные кавычки обозначают идентификатор с особым регистром или символами: `"Column Name"`.

### `LIKE` и `ILIKE`

```sql
where name like 'New%'
where name ilike '%new%'
```

- `%` — любое количество символов;
- `_` — ровно один символ;
- `LIKE` учитывает регистр;
- PostgreSQL `ILIKE` не учитывает регистр.

### Части строки

```sql
select
    left(username, 3),
    right(email, 5),
    position('@' in email)
from users;
```

Домен почты:

```sql
select
    email,
    right(email, length(email) - position('@' in email)) as domain
from users;
```

Для точной проверки домена лучше проверять окончание вместе с `@`:

```sql
where lower(email) like '%@bk.ru'
```

Шаблон `'%bk.ru%'` слишком широкий: он допускает символы и после домена.

### Проверь себя

1. Чем `LIKE` отличается от `ILIKE`?
2. Что означают `%` и `_`?
3. Почему строку нужно заключать в одинарные кавычки?
4. Как получить часть строки после `@`?
5. Почему `'%bk.ru%'` может дать лишние строки?

Исходные материалы: [[1. Лекции]], [[Практика 3. Задача 1]], [[Практика 3. Задача 2]], [[Практика 3. Задача 3]].

---

## 5. Объединение строк, `NULL`, `CASE`

### Конкатенация

```sql
select first_name || ' ' || last_name
from users;
```

Если один операнд `||` равен `NULL`, результат также будет `NULL`.

```sql
select concat(first_name, ' ', last_name)
from users;
```

`concat()` игнорирует `NULL`. `concat_ws()` дополнительно принимает разделитель:

```sql
select concat_ws(' ', first_name, last_name)
from users;
```

### `COALESCE` и `NULLIF`

```sql
select coalesce(first_name, last_name, 'Дорогой друг')
from users;
```

`COALESCE` возвращает первый аргумент, который не равен `NULL`.

```sql
select nullif(concat_ws(' ', first_name, last_name), '')
from users;
```

`NULLIF(a, b)` возвращает `NULL`, если `a = b`, иначе возвращает `a`.

### `CASE`

```sql
select
    id,
    username,
    score,
    case
        when score > 300 then 'Мастер'
        when score > 150 then 'Эксперт'
        when score > 75 then 'Продвинутый'
        else 'Новичок'
    end as group_user
from users;
```

Условия проверяются сверху вниз. Первое истинное условие завершает `CASE`, поэтому сначала идут более высокие пороги.

### Проверь себя

1. Как `||` реагирует на `NULL`?
2. Чем `concat()` отличается от `concat_ws()`?
3. Что возвращает `COALESCE`?
4. Для чего нужен `NULLIF`?
5. Почему порядок ветвей `CASE` важен?

Исходные материалы: [[1. Операторы SQL]], [[Практика 4. Задача 1]], [[Практика 4. Задача 2]], [[Практика 4. Задача 3]].

---

## 6. Даты, время и интервалы PostgreSQL

### Основные функции

```sql
select
    date_joined,
    to_char(date_joined, 'YYYY-MM') as formatted_month,
    date_trunc('month', date_joined) as month_start,
    extract(year from date_joined) as registration_year,
    now() as current_moment
from users;
```

| Функция | Результат |
|---|---|
| `to_char()` | Текстовое представление |
| `date_trunc()` | Дата/время, обрезанные до периода |
| `extract()` | Числовая часть даты или интервала |
| `make_date()` | Дата из года, месяца и дня |
| `now()` | Текущие дата и время транзакции |

### Интервалы

```sql
select date_joined + interval '3 days'
from users;
```

Разность timestamp даёт interval. Для полного числа часов можно использовать секунды эпохи:

```sql
select extract(epoch from (now() - date_joined)) / 3600 as hours_passed
from users;
```

### Полуоткрытые интервалы дат

Для timestamp надёжнее использовать `>=` начала и `<` следующей границы:

```sql
where date_joined >= date '2021-04-01'
  and date_joined <  date '2021-05-01'
```

Это включает весь апрель. Запись `between '2021-04-01' and '2021-04-30'` для timestamp обычно пропускает события 30 апреля после `00:00:00`.

Для года:

```sql
where date_joined >= date '2021-01-01'
  and date_joined <  date '2022-01-01'
```

Такой фильтр обычно лучше `to_char(date_joined, 'YYYY') = '2021'`: он сохраняет тип даты и лучше подходит для использования индекса.

### Проверь себя

1. Чем `to_char()` отличается от `date_trunc()`?
2. Как получить начало месяца?
3. Что возвращает `now()`?
4. Почему для timestamp полезен полуоткрытый интервал?
5. Как выбрать весь календарный год?
6. Почему фильтрация через `to_char()` может быть менее эффективной?

Исходные материалы: [[1.  Лекция]], практические задачи 5.1–5.8.

---

## 7. Приведение типов и `DISTINCT`

Целочисленное деление целых чисел возвращает целую часть. Хотя бы один операнд нужно привести к дробному типу:

```sql
select 5::numeric / 2;
select cast(5 as numeric) / 2;
select 5 * 1.0 / 2;
```

`::type` — краткая PostgreSQL-форма, `CAST(value AS type)` — стандартная форма SQL.

`DISTINCT` удаляет одинаковые строки результата:

```sql
select distinct company_id
from users;
```

Если выбрано несколько столбцов, уникальность определяется всей комбинацией:

```sql
select distinct company_id, is_active
from users;
```

### Проверь себя

1. Почему `5 / 2` может вернуть `2`?
2. Назови два способа приведения типа.
3. По чему определяется уникальность при нескольких столбцах?
4. Почему `DISTINCT` не следует использовать для сокрытия ошибочного `JOIN`?

Исходный материал: [[1. Дополнительные приёмы SQL]].

---

## 8. Соединение таблиц

### Виды `JOIN`

| JOIN | Какие строки сохраняет |
|---|---|
| `INNER JOIN` | Только совпавшие с обеих сторон |
| `LEFT JOIN` | Все слева и совпавшие справа |
| `RIGHT JOIN` | Все справа и совпавшие слева |
| `FULL JOIN` | Все строки обеих таблиц |

```sql
select
    u.id,
    u.username,
    c.problem_id
from users as u
join coderun as c
  on c.user_id = u.id;
```

### Связь один-ко-многим

Если пользователь отправил несколько решений, после `JOIN` его строка повторится для каждого `coderun`. Это не дубль SQL, а результат отношения один-ко-многим.

### Пользователи без решений

```sql
select u.id, u.username
from users as u
left join coderun as c
  on c.user_id = u.id
where c.id is null;
```

### `ON` и `WHERE` при внешнем соединении

Условие в `ON` определяет совпадение, сохраняя строки внешней стороны. Условие правой таблицы в `WHERE` может удалить строки с `NULL` и фактически превратить `LEFT JOIN` в `INNER JOIN`.

```sql
select u.id, c.problem_id
from users as u
left join coderun as c
  on c.user_id = u.id
 and c.created_at >= date '2021-04-01';
```

### Несколько таблиц

```sql
select
    u.username,
    p.name as problem_name
from coderun as c
join users as u
  on u.id = c.user_id
join problem as p
  on p.id = c.problem_id;
```

Не подменяй отсутствующий ключ значением через `coalesce()` в `ON`, если это не формализованное бизнес-правило: можно создать ложную связь.

### Проверь себя

1. Чем `INNER JOIN` отличается от `LEFT JOIN`?
2. Почему одна строка пользователя может повториться?
3. Как найти строки без пары?
4. Чем условия в `ON` отличаются от условий в `WHERE`?
5. Почему `RIGHT JOIN` часто переписывают как `LEFT JOIN`?
6. Как соединить три таблицы через таблицу связей?

Исходные материалы: [[1. Лекция. Часть 1]], [[2. Лекция. Часть 2]], [[3. Лекция. Часть 3]], [[Практика 6. Задача 1]], [[Практика 6. Задача 2]].

---

## 9. Все практические задачи курса — исправленные решения

### Практика 1. Выбор столбцов и сортировка

```sql
select id, username, email, date_joined
from users
order by date_joined desc, id asc;
```

### Практика 2.1. Фамилия отсутствует или score больше 100

```sql
select id, username, score
from users
where last_name is null
   or score > 100
order by id;
```

### Практика 2.2. Активный пользователь и одно из двух условий

```sql
select id, username, company_id, score
from users
where is_active = 1
  and (score > 500 or company_id = 7)
order by id;
```

### Практика 3.1. Регистр и длина

```sql
select
    id,
    username,
    first_name,
    last_name,
    lower(first_name) as lower_first_name,
    upper(last_name) as upper_last_name,
    length(username) as length_username
from users
order by length_username desc, id;
```

### Практика 3.2. Домен электронной почты

```sql
select
    id,
    username,
    email,
    right(email, length(email) - position('@' in email)) as domain
from users
order by id;
```

### Практика 3.3. Точный домен `bk.ru`

```sql
select id, username, email
from users
where lower(email) like '%@bk.ru'
order by id;
```

### Практика 4.1. Текст с идентификатором

```sql
select
    id,
    username,
    concat('Идентификатор пользователя равен ', id) as text_user_id
from users
order by id;
```

### Практика 4.2. Приветственное имя

```sql
select
    id,
    username,
    first_name,
    last_name,
    coalesce(first_name, last_name, 'Дорогой друг') as display_name
from users
order by id;
```

### Практика 4.3. Группа по score

```sql
select
    id,
    username,
    score,
    case
        when score > 300 then 'Мастер'
        when score > 150 then 'Эксперт'
        when score > 75 then 'Продвинутый'
        else 'Новичок'
    end as group_user
from users
order by id;
```

### Практика 5.1. Начало месяца

```sql
select
    id, username, email, date_joined,
    date_trunc('month', date_joined) as registration_month_start
from users
order by date_joined desc, id;
```

### Практика 5.2. Формат `DD Mon YYYY`

```sql
select
    id, username, email, date_joined,
    to_char(date_joined, 'DD Mon YYYY') as formatted_date
from users
order by date_joined desc, id;
```

### Практика 5.3. Формат `YYYY-MM`

```sql
select
    id, username, email, date_joined,
    to_char(date_joined, 'YYYY-MM') as formatted_date
from users
order by date_joined desc, id;
```

### Практика 5.4. Первые 45 суток от даты

```sql
select id, username, date_joined
from users
where date_joined >= date '2022-01-01'
  and date_joined <  date '2022-01-01' + interval '45 days'
order by date_joined desc, id;
```

### Практика 5.5. Регистрация в 2021 году

```sql
select id, username, date_joined
from users
where date_joined >= date '2021-01-01'
  and date_joined <  date '2022-01-01'
order by id;
```

### Практика 5.6. Домен `bk.ru` и 2022 год

```sql
select id, username, email, date_joined
from users
where lower(email) like '%@bk.ru'
  and date_joined >= date '2022-01-01'
  and date_joined <  date '2023-01-01'
order by id;
```

### Практика 5.7. 2021 год или score больше 100

```sql
select id, username, email, date_joined, score
from users
where (date_joined >= date '2021-01-01'
   and date_joined <  date '2022-01-01')
   or score > 100
order by id;
```

### Практика 5.8. Один из доменов и 2021 год

```sql
select id, username, email, date_joined
from users
where (lower(email) like '%@bk.ru'
    or lower(email) like '%@yandex.ru')
  and date_joined >= date '2021-01-01'
  and date_joined <  date '2022-01-01'
order by id;
```

### Практика 6.1. Отправки кода за апрель 2021 года

```sql
select
    u.id,
    u.username,
    u.date_joined,
    c.problem_id
from users as u
join coderun as c
  on c.user_id = u.id
where c.created_at >= date '2021-04-01'
  and c.created_at <  date '2021-05-01'
order by u.id, c.problem_id;
```

### Практика 6.2. Языки, задачи и сложность

Решение основано на ожидаемых ключах таблицы связи `languagetoproblem`:

```sql
select
    l.name as language_name,
    p.name as problem_name,
    p.complexity as complexity
from language as l
join languagetoproblem as ltp
  on ltp.language_id = l.id
join problem as p
  on p.id = ltp.problem_id
order by problem_name;
```

Если реальные имена ключей отличаются, сначала посмотри схему таблиц и скорректируй только поля в `ON`.

---

## 10. Самостоятельный тренажёр

Напиши без просмотра решений:

1. Выведи активных пользователей, отсортированных по score и id.
2. Найди пользователей без компании и без фамилии.
3. Выведи логин в нижнем регистре и его длину.
4. Получи домен email как вычисляемый столбец.
5. Найди точные домены `bk.ru` и `yandex.ru`.
6. Сформируй полное имя через `concat_ws()`.
7. Выбери display name через `coalesce()`.
8. Раздели пользователей на четыре группы через `CASE`.
9. Выведи начало месяца регистрации.
10. Выбери весь 2022 год полуоткрытым интервалом.
11. Посчитай часы с момента регистрации.
12. Получи уникальные пары `company_id`, `is_active`.
13. Найди пользователей без отправок кода.
14. Соедини `coderun`, `users` и `problem`.
15. Объясни, почему после `JOIN` стало больше строк.

Для каждого запроса сначала запиши ожидаемые столбцы, условие и сортировку обычными словами.

---

## 11. Типичные ошибки, которые нельзя закреплять

- `NULL` — отсутствие значения, а не ноль.
- Для `NULL` используются `IS NULL` и `IS NOT NULL`.
- Строковое значение должно быть в одинарных кавычках.
- Алиас из `SELECT` недоступен в `WHERE` того же уровня.
- `AND` выполняется раньше `OR`; сложную логику оформляй скобками.
- `LIKE '%bk.ru%'` не гарантирует точный домен.
- Условие второй ветви display name должно проверять `last_name`, а не повторно `first_name`.
- Практика 4.1 требует алиас `text_user_id`; `coalesce()` с одним заведомо непустым выражением не нужен.
- Фильтрация года через `to_char()` удобна, но диапазон дат обычно точнее и эффективнее.
- `BETWEEN` включителен с обеих сторон и опасен для последнего дня диапазона timestamp.
- Без `ORDER BY` порядок строк не гарантируется.
- `DISTINCT` не исправляет неправильную связь таблиц.
- Условие правой таблицы в `WHERE` может разрушить смысл `LEFT JOIN`.
- `COALESCE` в ключе соединения может создать ложную пару.
- После связи один-ко-многим увеличение количества строк ожидаемо.

---

## 12. Итоговый тест без подсказок

1. Что делают `SELECT` и `FROM`?
2. Почему `SELECT *` нежелателен в рабочих запросах?
3. Для чего нужны алиасы?
4. Как работает сортировка по двум полям?
5. Каков логический порядок `FROM`, `WHERE`, `SELECT`, `ORDER BY`?
6. Почему алиас нельзя использовать в `WHERE`?
7. Чем `NULL` отличается от пустой строки?
8. Что возвращает сравнение с `NULL`?
9. Каков приоритет `AND` и `OR`?
10. Чем `LIKE` отличается от `ILIKE`?
11. Что означают `%` и `_`?
12. Как получить домен email?
13. Как `||` работает с `NULL`?
14. Чем `concat()` отличается от `concat_ws()`?
15. Что возвращает `coalesce()`?
16. Что делает `nullif()`?
17. Как работает `CASE`?
18. Почему порядок `WHEN` важен?
19. Чем `to_char()` отличается от `date_trunc()`?
20. Что возвращает `extract()`?
21. Что такое `interval`?
22. Как выбрать весь календарный месяц?
23. Почему полуоткрытый интервал удобен для timestamp?
24. Как выбрать весь год без `to_char()`?
25. Как получить дробный результат деления?
26. Чем `::numeric` отличается от `CAST(... AS numeric)`?
27. Как работает `DISTINCT` для нескольких столбцов?
28. Чем `INNER JOIN` отличается от `LEFT JOIN`?
29. Что сохраняют `RIGHT JOIN` и `FULL JOIN`?
30. Для чего нужен `ON`?
31. Как найти строки без пары?
32. Чем условие в `ON` отличается от условия в `WHERE`?
33. Почему после `JOIN` появляются повторяющиеся пользователи?
34. Как соединить три таблицы?
35. Почему нельзя бездумно применять `DISTINCT` после `JOIN`?
36. Какие ошибки были исправлены в практиках 4.1 и 4.2?
37. Почему исходный фильтр апреля через `BETWEEN` неполон?
38. Как проверить точный домен почты?
39. Что нужно проверить перед выполнением запроса?
40. Как доказать, что результат запроса соответствует условию?

> [!question] Правило самопроверки
> Для каждого ответа напиши короткий SQL-пример. Для `JOIN` дополнительно нарисуй по две строки каждой таблицы и вручную предскажи результат.

---

## 13. Чек-лист готовности продолжить курс

- [ ] Я выбираю только необходимые столбцы.
- [ ] Я явно задаю сортировку.
- [ ] Я понимаю логический порядок выполнения запроса.
- [ ] Я правильно использую `NULL`.
- [ ] Я расставляю скобки в сложных условиях.
- [ ] Я умею работать с `LIKE` и `ILIKE`.
- [ ] Я применяю основные текстовые функции.
- [ ] Я различаю `||`, `concat`, `concat_ws`, `coalesce` и `nullif`.
- [ ] Я могу написать многоуровневый `CASE`.
- [ ] Я умею форматировать и округлять дату.
- [ ] Я фильтрую timestamp полуоткрытым интервалом.
- [ ] Я умею приводить типы и получать дробное деление.
- [ ] Я понимаю область действия `DISTINCT`.
- [ ] Я различаю `INNER`, `LEFT`, `RIGHT` и `FULL JOIN`.
- [ ] Я понимаю разницу между `ON` и `WHERE`.
- [ ] Я могу найти строки без пары.
- [ ] Я могу соединить три таблицы.
- [ ] Я самостоятельно решил все 19 задач курса.
- [ ] Я выполнил самостоятельный тренажёр.
- [ ] Я ответил на итоговый тест SQL-примерами.

После выполнения чек-листа возвращайся к [[SQL — содержание]] и продолжай курс с первой ещё не пройденной темы.

## Связанные заметки

- [[SQL и базы данных]]
- [[Анализ журналов]]
- [[SIEM, журналы событий и мониторинг]]
- [[Проекты]]
- [[SQL — содержание]]
- [[Главная]]
