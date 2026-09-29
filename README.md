# Advanced Database Operations — SQL Practical Exercises

This repository contains a MySQL practice project covering four advanced database-operation techniques:

- Auditing changes with triggers
- Updating rows with stored-procedure cursors
- Selecting from tables with prepared (dynamic) SQL
- Handling and logging stored-procedure errors

The exercises are intended for learners who already understand basic SQL and want hands-on experience with database automation, integrity, and diagnostics.

## Why this project is useful

The examples show how to:

- Keep an audit history when employee salaries change.
- Apply a 10% discount to products above a selected price.
- Reuse one procedure to query different tables.
- Catch SQL exceptions and record useful error information.
- Test database behavior with repeatable setup and verification queries.

The learner's notes and additional implementation details are in [`exercises.md`](exercises.md). The course solution script is in [`JqTwM3GnQnKbmIyXE9n2_Module_10/Module_10.sql`](JqTwM3GnQnKbmIyXE9n2_Module_10/Module_10.sql).

## Getting started

### Prerequisites

- MySQL Server 8.0 or a compatible MySQL installation
- A MySQL client such as the `mysql` command-line client, MySQL Shell, or MySQL Workbench
- Permission to create the `module10_db` database, tables, procedures, and triggers

### Run the exercises

1. Clone this repository and open its directory.
2. Start MySQL and connect with an account that can create database objects.
3. Run the course script:

   ```bash
   mysql -u YOUR_USER -p < JqTwM3GnQnKbmIyXE9n2_Module_10/Module_10.sql
   ```

4. Connect to the database to inspect the results:

   ```bash
   mysql -u YOUR_USER -p module10_db
   ```

   ```sql
   SHOW TRIGGERS;
   SHOW PROCEDURE STATUS WHERE Db = 'module10_db';
   SELECT * FROM audit_log;
   SELECT * FROM products;
   SELECT * FROM transactions;
   SELECT * FROM error_log;
   ```

The script creates and uses `module10_db`, so run it in a disposable practice database or remove any existing objects first when repeating the setup.

## What is included

| Topic | Database objects | Demonstrated behavior |
| --- | --- | --- |
| Triggers | `employees`, `audit_log`, `salary_update_trigger` | Logs salary changes before an employee update |
| Cursors | `products`, `discount_high_prices` | Reduces qualifying product prices by 10% |
| Dynamic SQL | `orders`, `customers`, `dynamic_select` | Executes a prepared `SELECT` for a supplied table |
| Error handling | `transactions`, `error_log`, `process_transaction` | Logs a failed transaction, including duplicate-account tests |

For example, after loading the script, the error-handling procedure can be exercised with:

```sql
CALL process_transaction('1234567890', 500);
CALL process_transaction('1234567890', 500);
SELECT * FROM error_log;
```

The second call is expected to fail because `transactions.account_number` is unique; the procedure's handler records the failure in `error_log`.

## Repository contents

- [`exercises.md`](exercises.md) — learner notes, completed snippets, and observations.
- [`JqTwM3GnQnKbmIyXE9n2_Module_10/Module_10.sql`](JqTwM3GnQnKbmIyXE9n2_Module_10/Module_10.sql) — complete setup and test script.
- [`JqTwM3GnQnKbmIyXE9n2_Module_10.zip`](JqTwM3GnQnKbmIyXE9n2_Module_10.zip) — packaged course material.
- `module10_db/` — local MySQL database files generated for this exercise; prefer the SQL script for portable setup.

## Getting help

Start with the SQL comments and verification queries in [`Module_10.sql`](JqTwM3GnQnKbmIyXE9n2_Module_10/Module_10.sql), then compare them with the explanations in [`exercises.md`](exercises.md). For MySQL syntax or server-specific behavior, consult the [MySQL Reference Manual](https://dev.mysql.com/doc/refman/8.0/en/).

If you find an incorrect example or reproducible issue, open a GitHub issue with your MySQL version, the command you ran, and the resulting error message.

## Maintainers and contributions

This repository is maintained by [VoidLance](https://github.com/VoidLance).

Contributions are welcome:

1. Fork the repository and create a focused branch.
2. Keep examples runnable on supported MySQL versions.
3. Update the relevant SQL notes and this README when behavior or setup changes.
4. Open a pull request describing the exercise or correction and how you tested it.

Please do not commit credentials, local configuration, or generated database files from unrelated environments.
