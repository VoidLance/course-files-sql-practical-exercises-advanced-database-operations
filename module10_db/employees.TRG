TYPE=TRIGGERS
triggers='CREATE DEFINER=`workbench_user`@`localhost` TRIGGER salary_update_trigger\nBEFORE UPDATE ON employees\nFOR EACH ROW\nBEGIN\n    -- Check if the salary is changing\n    IF OLD.salary <> NEW.salary THEN\n        INSERT INTO audit_log (employee_id, change_date, old_salary, new_salary)\n        VALUES (OLD.id, NOW(), OLD.salary, NEW.salary);\n    END IF;\nEND'
sql_modes=1411383296
definers='workbench_user@localhost'
client_cs_names='utf8mb4'
connection_cl_names='utf8mb4_0900_ai_ci'
db_cl_names='utf8mb4_unicode_ci'
created=1783173810668066
sql_path='CURRENT_SCHEMA'
