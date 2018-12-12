-- CREATION TABLE DE LA RELATION NORMALISES

CREATE TABLE personnageMieux
(
    nomPers TEXT PRIMARY KEY,
    anNaiss SMALLINT,
    nomType TEXT
);

CREATE TABLE type
(
    nomType TEXT PRIMARY KEY,
    imberbe BOOLEAN,
    tailleMoy FLOAT
);

CREATE TABLE coeffCar
(
  nomPers TEXT NOT NULL,
  numChap SMALLINT NOT NULL,
  numLivre TEXT NOT NULL,
  traitCar TEXT NOT NULL,
  coefCar FLOAT constraint coef_constraint check(coefCar between 0 and 1),
  PRIMARY KEY (nomPers, numChap, numLivre, traitCar)
);

CREATE TABLE titre
(
  numChap SMALLINT NOT NULL,
  numLivre TEXT NOT NULL,
  titre TEXT,
  PRIMARY KEY (numChap, numLivre)
);

-- INSERTION DES DONNEES

insert into personnageMieux (nomPers,anNaiss,nomType) select nomPers,anNaiss,nomType from Personnages;

insert into type (nomType, imberbe, tailleMoy) select nomType, imberbe, tailleMoy from Personnages;

insert into coeffCar (nomPers, numChap, numLivre, traitCar, coefCar) select nomPers, numChap, numLivre, traitCar, coefCar from Personnages;

insert into titre (numChap, numLivre, titre) select numChap, numLivre, titre from Personnages;




-- fin de fichier
