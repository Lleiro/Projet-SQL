-- update intégrités de la base
update personnages set titre='Une réception depuis longtemps attendue' where numLivre='1' and numChap=12;
update personnages set titre='Fuite vers le gué' where numLivre='1' and numChap=12;
update personnages set titre=concat(titre, 'livre:', numLivre, 'chapitre:', numChap) where titre='Le pont du destin de Gondor';

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

insert into personnageMieux (nomPers,anNaiss,nomType) select distinct(nomPers),anNaiss,nomType from Personnages;

insert into type (nomType, imberbe, tailleMoy) select distinct(nomType), imberbe, tailleMoy from Personnages;

insert into coeffCar (nomPers, numChap, numLivre, traitCar, coefCar) select nomPers, numChap, numLivre, traitCar, coefCar from Personnages;

insert into titre (titre, numChap, numLivre) select distinct(titre), numChap, numLivre from Personnages;


-- PARTIE 2 : OPTIMISATIONS

-- Question 3 :

-- relation Personnages
explain analyze insert into Personnages values('Jack Daniel', 'humain', 2634, 160, false, 'jovial', 0.61, 2, 1, 'Le pont du destin de Gondor');

-- Insert on personnages  (cost=0.00..0.01 rows=1 width=181) (actual time=0.200..0.200 rows=0 loops=1)
-- ->  Result  (cost=0.00..0.01 rows=1 width=181) (actual time=0.001..0.001 rows=1 loops=1)
-- Planning time: 0.042 ms
-- Execution time: 0.225 ms
-- (4 rows)


-- relations normalisées
explain analyze insert into personnageMieux values('Jack Daniel', 2634, 'humain');

-- Insert on personnagemieux  (cost=0.00..0.01 rows=1 width=66) (actual time=0.044..0.045 rows=0 loops=1)
-- ->  Result  (cost=0.00..0.01 rows=1 width=66) (actual time=0.001..0.002 rows=1 loops=1)
-- Planning time: 0.035 ms
-- Execution time: 0.064 ms
-- (4 rows)

explain analyze insert into coeffCar values('Jack Daniel', 2, 1, 'jovial', 0.61);

-- Insert on coeffcar  (cost=0.00..0.01 rows=1 width=106) (actual time=0.111..0.111 rows=0 loops=1)
-- ->  Result  (cost=0.00..0.01 rows=1 width=106) (actual time=0.001..0.003 rows=1 loops=1)
-- Planning time: 0.059 ms
-- Execution time: 0.184 ms
-- (4 rows)


-- Question 4 :

-- relation Personnages
explain analyze update Personnages set imberbe = true, tailleMoy=112 where nomType = 'hobbit';

-- Update on personnages  (cost=0.00..70.14 rows=505 width=94) (actual time=4.566..4.566 rows=0 loops=1)
-- ->  Seq Scan on personnages  (cost=0.00..70.14 rows=505 width=94) (actual time=0.023..0.650 rows=505 loops=1)
-- Filter: (nomtype = 'hobbit'::text)
-- Rows Removed by Filter: 1187
-- Planning time: 0.123 ms
-- Execution time: 4.600 ms
-- (6 rows)


-- relations normalisées
explain analyze update type set imberbe = true, tailleMoy=112 where nomType = 'hobbit';

-- Update on type  (cost=0.15..8.17 rows=1 width=47) (actual time=0.048..0.049 rows=0 loops=1)
--   ->  Index Scan using type_pkey on type  (cost=0.15..8.17 rows=1 width=47) (actual time=0.014..0.016 rows=1 loops=1)
--         Index Cond: (nomtype = 'hobbit'::text)
-- Planning time: 0.104 ms
-- Execution time: 0.093 ms
-- (5 rows)


-- Question 5 :

-- relation Personnages
explain analyze delete from Personnages where numChap = 13 and numLivre = '3';

--  Delete on personnages  (cost=0.00..74.38 rows=1 width=6) (actual time=0.415..0.416 rows=0 loops=1)
--    ->  Seq Scan on personnages  (cost=0.00..74.38 rows=1 width=6) (actual time=0.037..0.368 rows=2 loops=1)
--          Filter: ((numchap = 13) AND (numlivre = '3'::text))
--          Rows Removed by Filter: 1690
--  Planning time: 0.192 ms
--  Execution time: 0.440 ms
-- (6 rows)


-- relations normalisées
explain analyze delete from personnageMieux where nomPers in (select nomPers from coeffCar where numChap = 13 and numLivre = '3');

-- Delete on personnagemieux  (cost=38.38..39.99 rows=1 width=12) (actual time=0.321..0.321 rows=0 loops=1)
--   ->  Hash Semi Join  (cost=38.38..39.99 rows=1 width=12) (actual time=0.319..0.319 rows=0 loops=1)
--         Hash Cond: (personnagemieux.nompers = coeffcar.nompers)
--         ->  Seq Scan on personnagemieux  (cost=0.00..1.48 rows=48 width=14) (actual time=0.008..0.045 rows=49 loops=1)
--         ->  Hash  (cost=38.36..38.36 rows=1 width=14) (actual time=0.244..0.244 rows=2 loops=1)
--               Buckets: 1024  Batches: 1  Memory Usage: 9kB
--               ->  Seq Scan on coeffcar  (cost=0.00..38.36 rows=1 width=14) (actual time=0.013..0.226 rows=2 loops=1)
--                     Filter: ((numchap = 13) AND (numlivre = '3'::text))
--                     Rows Removed by Filter: 1690
-- Planning time: 0.313 ms
-- Execution time: 0.355 ms
-- (11 rows)



explain analyze delete from coeffCar where numChap = 13 and numLivre = '3';

-- Delete on coeffcar  (cost=0.00..38.36 rows=1 width=6) (actual time=0.257..0.258 rows=0 loops=1)
--   ->  Seq Scan on coeffcar  (cost=0.00..38.36 rows=1 width=6) (actual time=0.019..0.240 rows=2 loops=1)
--         Filter: ((numchap = 13) AND (numlivre = '3'::text))
--         Rows Removed by Filter: 1690
-- Planning time: 0.104 ms
-- Execution time: 0.278 ms
-- (6 rows)

-- PARTIE 3 : TRANSACTIONS

-- Question 1 :

-- exemple de perte de lecture impropre
-- user1
begin;
select numChap from personnageMieux;
-- user2
begin;
select numChap from personnageMieux;
-- user1
update personnageMieux set numChap = 5 where nomPers = 'Jack Daniel';
commit;
-- user2
update personnageMieux set numChap = 6 where nomPers = 'Jack Daniel';
commit;
-- user1
select numChap from personnageMieux;
-- user2
select numChap from personnageMieux;

-- Question 2 :

-- Question 3 :

-- Question 4 :

-- Question 5 :


/***********
* Partie 3 *
************/

/**** 1 ****/
/* Lecure impropre*/
-- user1
begin;
select * from R1;
insert into R1 values('Jean-Michel', 2, '1', 'courageux');
-- user2
select * from R1;
-- user1
rollback;
-- user2
select * from R1;


/**** 2 ****/
/* Perte de mise à jour */
-- user1
begin;
select numChap from R1;
-- user2
begin;
select numChap from R1;
-- user1
update R1 set numChap = numChap+1 where nomPers = 'Jean-Michel';
commit;
-- user2
update R1 set numChap = numChap+5 where nomPers = 'Jean-Michel';
commit;
-- user1
select numChap from R1;
-- user2
select numChap from R1;


/**** 3 ****/
/* Lecure non reproductible*/
-- user1
begin;
-- user2
select * from R1;
-- user1
insert into R1 values('Jean-Michel', 2, '1', 'courageux');
-- user2
select * from R1;
-- user1
commit;
-- user2
select * from R1;


/**** 4 ****/
/* Interblocage */
-- user1
begin;
-- user2
begin;
-- user1
update R1 set numChap = numChap+5 where nomPers = 'Jean-Michel';
-- user2
update CARACTERISTIQUE set nomType = "Hobbbbit" where nomType = 'hobbit';
-- user1
update CARACTERISTIQUE set nomType = "Manchot" where nomType = 'hobbit';
-- user2
update R1 set numChap = numChap+8 where nomPers = 'Jean-Michel';
-- user1
commit;
-- user2
commit;


-- fin de fichier
