CREATE TABLE pets (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  species_id INTEGER,
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES humans(id),
  FOREIGN KEY(species_id) REFERENCES species(id)  
);

CREATE TABLE species (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

CREATE TABLE humans (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  house_id INTEGER,

  FOREIGN KEY (house_id) REFERENCES houses(id)
);

CREATE TABLE houses (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  kingdom_id INTEGER,

  FOREIGN KEY (kingdom_id) REFERENCES kingdoms(id)
);

CREATE TABLE kingdoms (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  continent_id INTEGER,

  FOREIGN KEY (continent_id) REFERENCES continents(id)
);

CREATE TABLE continents (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

INSERT INTO
  continents (id, name)
VALUES
  (1, "Westeros"),
  (2, "Essos");

INSERT INTO
  species (id, name)
VALUES
  (1, "Dire Wolf"),
  (2, "Dragon"),
  (3, "Cat");

INSERT INTO
  kingdoms (id, name, continent_id)
VALUES
  (1, "The North", 1),
  (2, "The Crownlands", 1),
  (3, "The Westlands", 1),
  (4, "Meereen", 2);

INSERT INTO
  houses (id, name, kingdom_id)
VALUES
  (1, "Stark", 1),
  (2, "Mormont", 1),
  (3, "Targaryen", 2),
  (4, "Lannister", 3),
  (5, "Clegane", 3),
  (6, "Loraq", 4);

INSERT INTO
  humans (id, name, house_id)
VALUES
  (1, "Arya", 1),
  (2, "Rob", 1),
  (3, "Jorah", 2),
  (4, "Daenerys", 3),
  (5, "Tyrion", 4),
  (6, "Sandor", 5),
  (7, "Hizdar", 6);


INSERT INTO
  pets (id, name, species_id, owner_id)
VALUES
  (1, "Nymeria", 1, 1),
  (2, "Grey Wind", 1, 2),
  (3, "Drogon", 2, 4),
  (4, "Rheagal", 2, 4),
  (5, "Viserion", 2, 4),
  (6, "Stray Cat", 3, null);
