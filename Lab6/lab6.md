# Лабораторна робота №6

**Тема:** Міграції схем бази даних за допомогою Prisma ORM  
**Виконав:** Вовк Андрій, Троценко Максим, група ІО-41

## Мета роботи

Ознайомитися з підходом до керування змінами схеми бази даних за допомогою міграцій Prisma ORM. Для цього потрібно підключити Prisma до існуючої PostgreSQL-бази даних, створеної та нормалізованої у попередніх лабораторних роботах, зчитати поточну схему, внести декілька змін і застосувати їх як окремі міграції.

## Вихідна схема бази даних

Основою для виконання лабораторної роботи є нормалізована схема бази даних предметної області «Інтернет-магазин гітар», отримана в лабораторній роботі №5.

Початкова схема містить такі таблиці:

- `Customer` — клієнти магазину;
- `Category` — категорії товарів;
- `Brand` — бренди товарів;
- `Product` — товари магазину;
- `CustomerOrder` — замовлення клієнтів;
- `OrderItem` — позиції замовлень;
- `Rent` — оренда інструментів;
- `StudioBooking` — записи до студії самозапису;
- `InstrumentBuyIn` — операції викупу вживаних інструментів;
- `RepairService` — послуги ремонту;
- `SetUpService` — послуги налаштування інструментів.

Перед початком роботи у PostgreSQL було виконано SQL-скрипт з лабораторної роботи №5:

```text
../Lab5/normalization.sql
```

Також для перевірки роботи схеми було виконано скрипт із тестовими даними:

```text
../Lab5/test_data.sql
```
<div align="center">
  <img src="media/tables.png" alt="список таблиць у pgAdmin перед початком роботи з Prisma.">
  <p><em>список таблиць у pgAdmin перед початком роботи з Prisma.</em></p>
</div>

## Ініціалізація Prisma

У директорії лабораторної роботи було створено Node.js-проєкт та встановлено Prisma:

```bash
npm init -y
npm install prisma --save-dev
npx prisma init --datasource-provider postgresql
```

Після виконання цих команд було створено:

- `package.json`;
- `.env`;
- директорію `prisma/`;
- файл `prisma/schema.prisma`.

<div align="center">
  <img src="media/terminal1.png" alt="результат виконання команд ініціалізації Prisma в терміналі">
  <img src="media/terminal2.png" alt="результат виконання команд ініціалізації Prisma в терміналі">
  <img src="media/terminal3.png" alt="результат виконання команд ініціалізації Prisma в терміналі">
  <p><em>результат виконання команд ініціалізації Prisma в терміналі</em></p>
</div>


## Налаштування підключення до PostgreSQL

У файлі `.env` було вказано підключення до локальної бази даних PostgreSQL:

```env
DATABASE_URL="postgresql://postgres:password123@localhost:5432/postgres"
```

Якщо PostgreSQL запущений у Docker з попередніх лабораторних робіт, параметри підключення відповідають таким значенням:

- користувач: `postgres`;
- пароль: `password123`;
- хост: `localhost`;
- порт: `5432`;
- база даних: `postgres`.

## Аналіз існуючої схеми

Для зчитування поточної структури бази даних було виконано команду:

```bash
npx prisma db pull
```

Ця команда виконала introspection існуючої PostgreSQL-схеми та автоматично створила Prisma-моделі у файлі:

```text
prisma/schema.prisma
```

Після цього у `schema.prisma` з'явилися моделі, які відповідають таблицям з лабораторної роботи №5. Оскільки таблиці в PostgreSQL були створені без подвійних лапок, Prisma зчитала їх у нижньому регістрі: `customer`, `category`, `brand`, `product`, `customerorder`, `orderitem`, `rent`, `studiobooking`, `instrumentbuyin`, `repairservice`, `setupservice`.

<div align="center">
  <img src="media/npx_prisma_db_pull.png" alt="виконання `npx prisma db pull` без помилок">
  <p><em>виконання `npx prisma db pull` без помилок</em></p>
</div>

<div align="center">
  <img src="media/fragment_from_file.png" alt="фрагмент файлу `schema.prisma` після зчитування схеми з бази даних">
  <p><em>фрагмент файлу `schema.prisma` після зчитування схеми з бази даних</em></p>
</div>


## Заплановані зміни схеми

Для демонстрації механізму міграцій було заплановано три зміни:

1. Додати нову таблицю `review` для відгуків клієнтів на товари.
2. Додати до таблиці `product` поле `isavailable`, яке показує, чи товар доступний для продажу.
3. Додати до таблиці `customer` поле `createdat`, яке зберігає дату реєстрації клієнта.

Кожна зміна виконується окремою міграцією, щоб історія змін схеми була зрозумілою.

## Початкова baseline-міграція

Оскільки база даних уже існувала до початку роботи з Prisma Migrate, спочатку було створено початкову міграцію `0_init`. Вона описує схему, яка вже була в PostgreSQL після лабораторної роботи №5.

Для цього було створено SQL-файл:

```text
prisma/migrations/0_init/migration.sql
```

Після цього міграцію було позначено як уже застосовану:

```bash
npx prisma migrate resolve --applied 0_init
```

Цей крок потрібен, щоб Prisma не намагалася заново створювати таблиці, які вже існують у базі даних.

## Міграція 1. Додавання таблиці `review`

### Опис зміни

У систему додано можливість зберігати відгуки клієнтів про товари. Один товар може мати багато відгуків, і один клієнт може залишити багато відгуків.

До `schema.prisma` було додано модель:

```prisma
model review {
  reviewid   Int      @id @default(autoincrement())
  productid  Int
  customerid Int
  rating     Int
  comment    String?
  createdat  DateTime @default(now()) @db.Timestamp(6)

  product  product  @relation(fields: [productid], references: [productid], onDelete: Cascade, onUpdate: NoAction)
  customer customer @relation(fields: [customerid], references: [customerid], onDelete: Cascade, onUpdate: NoAction)
}
```

Також до моделей `product` і `customer` було додано зворотні зв'язки:

```prisma
review review[]
```

Для створення та застосування міграції було виконано команду:

```bash
npx prisma migrate dev --name add-review-table
```

<div align="center">
  <img src="media/review.png" alt="виконання міграції add-review-table у терміналі">
  <p><em>виконання міграції add-review-table у терміналі</em></p>
</div>

<div align="center">
  <img src="media/review_in_pgadmin.png" alt="створена таблиця review у pgAdmin">
  <p><em>створена таблиця review у pgAdmin</em></p>
</div>

## Міграція 2. Додавання поля `isavailable` до `product`

### Опис зміни

У таблицю товарів додано поле `isavailable`, яке дозволяє явно позначати доступність товару. Це поле відрізняється від `stockquantity`: товар може бути фізично на складі, але тимчасово недоступний для продажу.

До моделі `product` було додано поле:

```prisma
isavailable Boolean @default(true)
```

Після зміни моделі було виконано команду:

```bash
npx prisma migrate dev --name add-product-availability
```

<div align="center">
  <img src="media/isavailable.png" alt="виконання міграції add-product-availability у терміналі">
  <p><em>виконання міграції add-product-availability у терміналі</em></p>
</div>

<div align="center">
  <img src="media/isavailable_in_product.png" alt="колонка isavailable у таблиці product у pgAdmin">
  <p><em>колонка isavailable у таблиці product у pgAdmin</em></p>
</div>

## Міграція 3. Додавання поля `createdat` до `customer`

### Опис зміни

Для зберігання дати реєстрації клієнта до таблиці `customer` було додано поле `createdat`.

До моделі `customer` було додано поле:

```prisma
createdat DateTime @default(now()) @db.Timestamp(6)
```

Після зміни моделі було виконано команду:

```bash
npx prisma migrate dev --name add-customer-created-at
```

<div align="center">
  <img src="media/createdat.png" alt="виконання міграції add-customer-created-at у терміналі">
  <p><em>виконання міграції add-customer-created-at у терміналі</em></p>
</div>

<div align="center">
  <img src="media/createdat_in_customer.png" alt="колонка createdat у таблиці customer у pgAdmin">
  <p><em>колонка createdat у таблиці customer у pgAdmin</em></p>
</div>

## Структура створених міграцій

Після виконання команд Prisma у директорії `prisma/migrations/` було створено окремі папки для початкової схеми та кожної наступної зміни:

```text
prisma/migrations/
├── 0_init/
│   └── migration.sql
├── ..._add-review-table/
│   └── migration.sql
├── ..._add-product-availability/
│   └── migration.sql
└── ..._add-customer-created-at/
    └── migration.sql
```

Кожна папка містить SQL-файл, який описує конкретну зміну схеми бази даних.

<div align="center">
  <img src="media/strukt_of_migrations.png" alt="структура папки prisma/migrations">
  <p><em>структура папки prisma/migrations</em></p>
</div>

## Перевірка через pgAdmin

Для візуальної перевірки схеми було використано pgAdmin. У структурі таблиць перевірено, що після міграцій у базі даних з'явилися нова таблиця та нові колонки.

Було перевірено:

- наявність таблиці `review`;
- наявність нового поля `isavailable` у `product`;
- наявність нового поля `createdat` у `customer`.

Скріншоти цих перевірок наведені в описі відповідних міграцій.

## Повторна перевірка схеми

Після застосування всіх міграцій було виконано перевірку статусу:

```bash
npx prisma migrate status
```

Ця команда показує, що всі міграції застосовані, а схема бази даних відповідає поточному файлу `schema.prisma`.

<div align="center">
  <img src="media/migrate_status.png" alt="перевірка статусу міграцій Prisma">
  <p><em>перевірка статусу міграцій Prisma</em></p>
</div>

## Результати роботи

У результаті виконання лабораторної роботи було:

- ініціалізовано Prisma ORM у проєкті;
- підключено Prisma до існуючої PostgreSQL-бази даних;
- зчитано поточну схему бази даних за допомогою `npx prisma db pull`;
- створено baseline-міграцію `0_init` для вже існуючої схеми;
- створено нову таблицю `review`;
- додано поле `isavailable` до таблиці `product`;
- додано поле `createdat` до таблиці `customer`;
- застосовано зміни через окремі Prisma-міграції;
- перевірено результат через pgAdmin та `npx prisma migrate status`.

## Висновок

У ході виконання лабораторної роботи було розглянуто процес керування змінами схеми бази даних за допомогою Prisma ORM. На основі нормалізованої PostgreSQL-схеми з лабораторної роботи №5 Prisma зчитала існуючі таблиці та зв'язки у файл `schema.prisma`. Після цього було внесено декілька змін до моделі даних і застосовано їх як окремі міграції.

Використання Prisma дозволяє зберігати історію змін схеми у вигляді SQL-файлів у директорії `prisma/migrations/`, що робить процес розвитку бази даних контрольованим і відтворюваним.
