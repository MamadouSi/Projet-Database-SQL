##########################################  Mod?le conceptuel de donn?es (MCD) ########################################
## 3- Cr?ation des tables qui correspondent ? mon mod?le conceptuel de donn?es :
CREATE TABLE client
(
    cin varchar(20) PRIMARY KEY NOT NULL,
    nom varchar(50),
    prenom varchar(50),
    sexe varchar(1),
    date_nai Date,
    ville varchar(50),
    adresse varchar(30),
    tel varchar(50)
    
);




CREATE TABLE commande
(
    num_cd int,
    cin varchar(20),
    date_cd date,
    PRIMARY KEY (cin, num_cd),
    unique(num_cd),
    FOREIGN KEY (cin) REFERENCES client(cin)
    
);



CREATE TABLE societe
(
    num_sc int,
    nom varchar(50),
    spe varchar(250),
    PRIMARY KEY (num_sc)
    
);

CREATE TABLE categorie
(
    code int,
    nom varchar(50),
    designation varchar(250),
    type_categorie varchar(2),
    PRIMARY KEY (code)
    
);

CREATE TABLE article
(
    num_art int,
    nom varchar(50),
    designation varchar(50),
    categ int,
    prix int,
    PRIMARY KEY (num_art,categ),
    unique(num_art),
    FOREIGN KEY (categ) REFERENCES categorie(code)

    
);


CREATE TABLE vendeur
(
    matricule varchar(10),
    nom varchar(50),
    prenom varchar(50),
    grade varchar(30),
    num_sc int,
    PRIMARY KEY (matricule ,num_sc),
    unique(matricule),
    FOREIGN KEY (num_sc) REFERENCES societe(num_sc)

    
);
drop table vendeur;


CREATE TABLE facture
(
    num_facture int,
    date_facture date,
    mat varchar(10),
    PRIMARY KEY (num_facture,mat),
    unique(num_facture),
    FOREIGN KEY (mat) REFERENCES vendeur(matricule)
       

);



CREATE TABLE liste_commande
(
    num_facture int,
    num_art int,
    num_cd int,
    PRIMARY KEY(num_facture, num_art,num_cd),
    FOREIGN KEY (num_facture) REFERENCES facture(num_facture),
    FOREIGN KEY(num_art) REFERENCES article(num_art),
    FOREIGN KEY(num_cd) REFERENCES commande(num_cd)
    
);


## 4- Alimenter ces tables par des jeux de donn?es 

##Instertion dans la table client 
INSERT INTO client VALUES ('A01213','SIDIBE','Mamadou','M','16/02/02','Oujda','HAY Qods Rue 25 Porte 1','06xxxxxxxxxxx'); 
INSERT INTO client VALUES ('B018957','KEITA','Kissima','M','18/09/00','Casa','HAY Rabi Rue 75 Porte 7','07xxxxxxxxxxx'); 
INSERT INTO client VALUES ('C04142','DIALLO','Fatoumata','F','25/03/99','Rabat','Doha Rue 02 Porte 5','05xxxxxxxxxxx'); 

##Instertion dans la table commande
INSERT INTO commande VALUES (16,'A01213','16/02/22'); 
INSERT INTO commande VALUES (18,'B018957','30/01/22');
INSERT INTO commande VALUES (25,'C04142','10/04/22'); 


##Instertion dans la table facture
INSERT INTO facture VALUES (01,'16/02/22','FX0648'); 
INSERT INTO facture VALUES (02,'30/01/22','FX0648'); 
INSERT INTO facture VALUES (04,'10/04/22','SR0489'); 




##Insertion dans la table categorie 
INSERT INTO categorie VALUES (3,'Soins et Beaut?','Produits de soins debeaute pour le visage et le corps de tr?s bonne qualit?','B'); 
INSERT INTO categorie VALUES (2,'Musculation','Produits pour la pratique dexercice physique et de sport a la maison et dehors','B'); 
INSERT INTO categorie VALUES (1,'Alimentaire','Produits alimentaire de toute sorte frais et de premiere qualit?','A'); 

##Insertion dans la table societe
INSERT INTO societe VALUES (201,'Alpha','Premiere division de lentreprise pour la gestion de tout type de vente et premiere tete daffiche de la societe'); 
INSERT INTO societe VALUES (864,'Beta','sp?cialisaer dans la vente de produits alimentaire mais aussi tres polyvalent dans les autres dommines'); 

##Insertion dans la table vendeur
INSERT INTO vendeur VALUES ('FX0648','DIALLO','Ahmed','Grade 3',201); 
INSERT INTO vendeur VALUES ('SR0489','SIDIBE','Youssouf','Grade 2',864); 

##Insertion dans la table article
INSERT INTO article VALUES (16,'Parfun Dior Sauvage','Parfum pour homme de la marque Dior ',3,35); 
INSERT INTO article VALUES (78,'Alt?res 50kg','Alt?eres de musculation au nombre de 5 par kit',2,300); 
INSERT INTO article VALUES (25,'Riz Blanc','Sac de riz blanc de 25kg ',1,150); 
INSERT INTO article VALUES (07,'Spagetti','1kg de pate fraiche 1er choix ',1,12);

##Insertion dans la table liste_commande
INSERT INTO liste_commande VALUES (01,16,16); 
INSERT INTO liste_commande VALUES (02,16,18); 
INSERT INTO liste_commande VALUES (02,78,18); 
INSERT INTO liste_commande VALUES (04,25,25); 

##5-Ecrire une requ?te permettant d?appliquer la jointure Left Join Commenter cette requ?te :
select client.cin,client.nom,client.prenom,commande.num_cd,liste_commande.num_facture,article.nom as nom_article from client
left join commande on client.cin=commande.cin
left join   liste_commande on commande.num_cd=liste_commande.num_cd
left join article on article.num_art=liste_commande.num_art;


##6-Cr?er une vue mat?rialis?e sur cette requ?te (question 5) avec un rafraichissement p?riodique des donn?es dans toutes les 10 minutes.
CREATE MATERIALIZED VIEW CLIENT_CD_FCT_ART
REFRESH FORCE START WITH SYSDATE NEXT sysdate+1/144 AS
select client.cin,client.nom,client.prenom,commande.num_cd,liste_commande.num_facture,article.nom as nom_article from client
left join commande on client.cin=commande.cin
left join   liste_commande on commande.num_cd=liste_commande.num_cd
left join article on article.num_art=liste_commande.num_art;


##7- Cr?er un Index simple sur la colonne nom et pr?nom de la table client et la colonne nom de la table article;
CREATE INDEX index_NOM_PRENOM_CLIENT on client(nom,prenom);
CREATE INDEX index_NOM_ARTICLE on article(nom);

##8-Exemple de transaction bas? sur le MCD ;
BEGIN
UPDATE article  SETprix =125 where num_art=25;
UPDATE vendeur SET grade='GRADE X' where matricule='FX0648';
END;

##9-----------------Transaction-----------------

##10-----------------
create table effectif_ville (ville varchar2(30), effectif int);

create or replace procedure eff_ville is
cursor c1 is 
    select ville,count(*) as eff from client group by ville;
begin 
delete from effectif_ville;
for c in c1
    loop
        insert into effectif_ville values(c.ville,c.eff);
    end loop;
commit;
end;

Exec  eff_ville;


update client set ville='Casa' where cin ='A01213';


##11-------------------------------------------------
CREATE TABLE historiques_article
(

    date_op date,
    num_art int,
    nom varchar(50),
    designation varchar(50),
    categ int,
    prix int
   
);


CREATE OR REPLACE TRIGGER historiqueArticle
AFTER DELETE OR UPDATE ON article FOR EACH ROW
BEGIN
    IF DELETING OR UPDATING THEN
        INSERT INTO historiques_article VALUES (SYSDATE, :OLD.num_art, :OLD.nom, :OLD.designation, :OLD.categ, :OLD.prix);
    END IF;
END;


 
 
 update article set prix=145 where num_art=25;
 
 
 ##12-------------------------------------------------
CREATE TYPE T_lst_cmd ;

CREATE TYPE Tcommande ;

CREATE TYPE LISTE_Tcommande AS TABLE OF REF Tcommande;


CREATE TYPE Tclient AS OBJECT(cin varchar(20), nom varchar(50), prenom varchar(50),sexe varchar(1), date_nai Date, ville varchar(50),adresse varchar(30),tel varchar(50), cmd LISTE_Tcommande);

CREATE TYPE Tcommande AS OBJECT(clt REF Tclient, num_cd int,cin varchar(20),date_cd date,lst_cmd REF T_lst_cmd);

##----------------------------------------------------

CREATE TYPE Tfacture;

CREATE TYPE Tsociete;


CREATE TYPE LISTE_Tfacture AS TABLE OF REF Tfacture ;

CREATE TYPE Tvendeur AS OBJECT(factures LISTE_Tfacture, sct REF Tsociete, matricule varchar(10),nom varchar(50),prenom varchar(50),grade varchar(30),num_sc int);

CREATE TYPE Tfacture AS OBJECT(vds REF Tvendeur, num_facture int,date_facture date,mat varchar(10), lst_cmd REF T_lst_cmd);

CREATE TYPE LISTE_Tvendeur AS TABLE OF REF Tvendeur ;

CREATE TYPE TSociete AS OBJECT(vendeurs  LISTE_Tvendeur  ,num_sc number,nom varchar(50), spe varchar(250));
##---------------------------------------------------



CREATE TYPE Tarticle ;

CREATE TYPE LISTE_Tarticle AS TABLE OF REF Tarticle ;

CREATE TYPE Tcategorie AS OBJECT(articles LISTE_Tarticle, code int,nom varchar(50),designation varchar(250),type_categorie varchar(2));

CREATE TYPE Tarticle AS OBJECT(ctg REF Tcategorie, num_art int,nom varchar(50),designation varchar(50),categ int,prix int, lst_cmd REF T_lst_cmd);
##-----------------------------------------------------

CREATE TYPE T_lst_cmd AS OBJECT (cmd LISTE_Tcommande,art LISTE_Tarticle,fct LISTE_Tfacture);



