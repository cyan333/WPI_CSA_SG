CREATE TABLE MENUS(
ID NUMBER PRIMARY KEY NOT NULL,
PARENT_ID NUMBER,
POSITION NUMBER
);

CREATE TABLE CONTENTS (
ID NUMBER PRIMARY KEY NOT NULL,
CONTENT VARCHAR NOT NULL,
CONTENT_TYPE VARCHAR NOT NULL, --title, image, text, etc
MENU_ID NUMBER NOT NULL,
POSITION NUMBER --Discribe the position of contents under a menu article
);

CREATE TABLE 