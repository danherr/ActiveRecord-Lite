CREATE TABLE cats (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES human(id)
);

CREATE TABLE humans (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  house_id INTEGER
);

CREATE TABLE houses (
  id INTEGER PRIMARY KEY,
  address VARCHAR(255) NOT NULL,
  country_id INTEGER
);

CREATE TABLE countries (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

INSERT INTO
  countries (id, name)
VALUES
  (1, "United States"),
  (2, "New Fake Island");

INSERT INTO
  houses (id, address, country_id)
VALUES
  (1, "26th and Guerrero", 1), (2, "Dolores and Market", 2);

INSERT INTO
  humans (id, fname, lname, house_id)
VALUES
  (1, "Devon", "Watts", 1),
  (2, "Matt", "Rubens", 1),
  (3, "Ned", "Ruggeri", 2),
  (4, "Catless", "Human", NULL);

INSERT INTO
  cats (id, name, owner_id)
VALUES
  (1, "Breakfast", 1),
  (2, "Earl", 2),
  (3, "Haskell", 3),
  (4, "Markov", 3),
  (5, "Stray Cat", NULL);
