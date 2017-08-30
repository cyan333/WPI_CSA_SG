CREATE TABLE ARTICLES (
  ID INTEGER PRIMARY KEY NOT NULL,
  TITLE VARCHAR(30) NOT NULL,
  CONTENT VARCHAR,
  PARENT_ID INTEGER,
  POSITION INTEGER NOT NULL
);

CREATE TABLE CACHE (
  ID INTEGER PRIMARY KEY NOT NULL,
  NAME VARCHAR(30),
  TYPE VARCHAR(10) NOT NULL,
  MAPPING_ID INTEGER,
  VALUE VARCHAR
);