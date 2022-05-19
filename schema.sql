CREATE TABLE reminders (
  id serial PRIMARY KEY,
  task_name varchar(30) NOT NULL,
  due_date date NOT NULL,
  agency text NOT NULL
);

CREATE TABLE example (
  id serial PRIMARY KEY,
  task_name varchar(30) NOT NULL,
  due_date date NOT NULL,
  agency text NOT NULL
);

INSERT INTO example (task_name, due_date, agency)
VALUES ('File Q4 Sales Tax', '2022-01-01', 'State'),
('File Corporate Tax Return', '2022-3-15', 'Federal'),
('File Q1 Sales Tax', '2022-04-01', 'State'),
('File Personal Tax Return', '2022-4-15', 'Federal'),
('Renew City Business Tax', '2022-06-01', 'Local'),
('File Q2 Sales Tax', '2022-07-01', 'State'),
('File Q3 Sales Tax', '2022-10-01', 'State')
;
