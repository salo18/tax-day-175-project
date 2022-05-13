CREATE TABLE reminders (
  id serial PRIMARY KEY,
  task_name varchar(30) NOT NULL,
  due_date date NOT NULL,
  agency text NOT NULL
);
