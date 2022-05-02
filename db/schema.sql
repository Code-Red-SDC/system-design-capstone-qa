DROP DATABASE IF EXISTS qa;
CREATE DATABASE qa;

\c qa;

CREATE TABLE question_info (
  id SERIAL PRIMARY KEY,
  product_id INTEGER,
  body VARCHAR(1024),
  date_written BIGINT,
  asker_name VARCHAR(40),
  asker_email VARCHAR(40),
  reported BOOLEAN,
  helpful INTEGER
);

CREATE TABLE answers (
  id SERIAL PRIMARY KEY,
  question_id INTEGER REFERENCES question_info(id) ON DELETE CASCADE,
  body VARCHAR(1024),
  date_written BIGINT,
  answerer_name VARCHAR(40),
  answerer_email VARCHAR(40),
  reported BOOLEAN,
  helpful INTEGER
);

CREATE TABLE answer_photos (
  id SERIAL PRIMARY KEY,
  answer_id INTEGER REFERENCES answers(id) ON DELETE CASCADE,
  url VARCHAR(200)
);

\copy question_info FROM './csv/questions.csv' WITH (FORMAT CSV, DELIMITER ",", HEADER);
\copy answers FROM './csv/answers.csv' WITH (FORMAT CSV, DELIMITER ",", HEADER);
\copy answer_photos FROM './csv/answers_photos.csv' WITH (FORMAT CSV, DELIMITER ",", HEADER);

CREATE INDEX idx_qi_product_id ON question_info(product_id);
CREATE INDEX idx_a_question_id ON answers(question_id);
CREATE INDEX idx_ap_answer_photos ON answer_photos(answer_id);

UPDATE question_info SET date_written=date_written/1000;
ALTER TABLE question_info ALTER date_written TYPE TIMESTAMP WITHOUT TIME ZONE USING to_timestamp(date_written) AT TIME ZONE 'UTC';

UPDATE answers SET date_written=date_written/1000;
ALTER TABLE answers ALTER date_written TYPE TIMESTAMP WITHOUT TIME ZONE USING to_timestamp(date_written) AT TIME ZONE 'UTC';

SELECT setval('question_info_id_seq', (SELECT MAX(id) FROM question_info));
SELECT setval('answers_id_seq', (SELECT MAX(id) FROM answers));
SELECT setval('answer_photos_id_seq', (SELECT MAX(id) FROM answer_photos));

-- psql -U postgres -f db/schema.sql