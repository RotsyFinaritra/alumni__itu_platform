-- ============================================================================
-- SCRIPT DE NETTOYAGE - Suppression tables/vues du projet Donation/TeamTask
-- Projet cible : Alumni ITU Platform
-- Date         : 22 février 2026
-- ATTENTION    : Exécuter dans cet ordre (vues d'abord, puis tables filles,
--               puis tables mères) pour éviter les erreurs de FK.
-- MIGRATION     : Ce script supprime AUSSI les tables APJ core qui seront
--               recréées avec la nouvelle structure alumni par le script
--               BDD/2026-02-21-Alumni-1.sql (étape suivante obligatoire).
-- ============================================================================

-- Désactiver les contraintes FK pendant la suppression (optionnel mais sûr)
SET session_replication_role = replica;

-- ============================================================================
-- ÉTAPE 1 : SUPPRESSION DES VUES (aucune dépendance à gérer)
-- ============================================================================

-- Vues donation
DROP VIEW IF EXISTS public.donationlibcpl CASCADE;
DROP VIEW IF EXISTS public.donationlibcpl_materiel CASCADE;
DROP VIEW IF EXISTS public.donationlibcpl_mobilemoney CASCADE;
DROP VIEW IF EXISTS public.donationlibcpl_nonvivre CASCADE;
DROP VIEW IF EXISTS public.donationlibcpl_reste CASCADE;
DROP VIEW IF EXISTS public.donationlibcpl_vivre CASCADE;
DROP VIEW IF EXISTS public.donationreste CASCADE;
DROP VIEW IF EXISTS public.donationsituation CASCADE;
DROP VIEW IF EXISTS public.analyse_donation CASCADE;
DROP VIEW IF EXISTS public.promesselibcpl CASCADE;
DROP VIEW IF EXISTS public.repartitionlib CASCADE;
DROP VIEW IF EXISTS public.repartitionlib_cpl CASCADE;
DROP VIEW IF EXISTS public.repartitiondetailslib CASCADE;
DROP VIEW IF EXISTS public.repartitiondetails_projet CASCADE;
DROP VIEW IF EXISTS public.repartition_sans_donation CASCADE;
DROP VIEW IF EXISTS public.reparttion_avec_donation CASCADE;

-- Vues gestion de projet
DROP VIEW IF EXISTS public.tache_lib CASCADE;
DROP VIEW IF EXISTS public.tachelib CASCADE;
DROP VIEW IF EXISTS public.tachemere_lib CASCADE;
DROP VIEW IF EXISTS public.tachemerelib CASCADE;
DROP VIEW IF EXISTS public.tachemerelibaviser CASCADE;
DROP VIEW IF EXISTS public.tachemere_viser CASCADE;
DROP VIEW IF EXISTS public.tachemere_projet CASCADE;
DROP VIEW IF EXISTS public.tachemere_fille CASCADE;
DROP VIEW IF EXISTS public.tachemere_fonctionnalite CASCADE;
DROP VIEW IF EXISTS public.tachevita CASCADE;
DROP VIEW IF EXISTS public.tachetsyvita CASCADE;
DROP VIEW IF EXISTS public.tachefait CASCADE;
DROP VIEW IF EXISTS public.tacheentamenonfait CASCADE;
DROP VIEW IF EXISTS public.tachenonentame CASCADE;
DROP VIEW IF EXISTS public.tachenonattribue CASCADE;
DROP VIEW IF EXISTS public.tacheentite CASCADE;
DROP VIEW IF EXISTS public.tacheentitegrp CASCADE;
DROP VIEW IF EXISTS public.tacheentitelib CASCADE;
DROP VIEW IF EXISTS public.tacheentitelibgrp CASCADE;
DROP VIEW IF EXISTS public.tacherelation CASCADE;
DROP VIEW IF EXISTS public.tachegitdetailscpl CASCADE;
DROP VIEW IF EXISTS public.tachedefaut_full CASCADE;
DROP VIEW IF EXISTS public.statmere CASCADE;
DROP VIEW IF EXISTS public.nbtacheparetat CASCADE;
DROP VIEW IF EXISTS public.nombre_tache_parmere CASCADE;
DROP VIEW IF EXISTS public.etat_creation_tache CASCADE;
DROP VIEW IF EXISTS public.etatdeslieux CASCADE;
DROP VIEW IF EXISTS public.etatprojetfonctionnalite CASCADE;
DROP VIEW IF EXISTS public.etatprojetfonctionnaliteid CASCADE;
DROP VIEW IF EXISTS public.fonctionnalite_lib CASCADE;
DROP VIEW IF EXISTS public.fonctionnalite_libcomplet CASCADE;
DROP VIEW IF EXISTS public.module_projet_lib CASCADE;
DROP VIEW IF EXISTS public.branche_lib CASCADE;
DROP VIEW IF EXISTS public.traitement_tache CASCADE;
DROP VIEW IF EXISTS public.traitement_projet CASCADE;
DROP VIEW IF EXISTS public.traitement_soustache CASCADE;
DROP VIEW IF EXISTS public.script_non_exec CASCADE;
DROP VIEW IF EXISTS public.script_non_exec_lib CASCADE;
DROP VIEW IF EXISTS public.scriptlib CASCADE;
DROP VIEW IF EXISTS public.scriptupdate CASCADE;
DROP VIEW IF EXISTS public.scriptcpltache CASCADE;
DROP VIEW IF EXISTS public.script_projet_lib CASCADE;
DROP VIEW IF EXISTS public.script_projet_libcomplet CASCADE;
DROP VIEW IF EXISTS public.scriptversionningresponsable CASCADE;
DROP VIEW IF EXISTS public.deploiementlib CASCADE;
DROP VIEW IF EXISTS public.deploiementlibcpl CASCADE;
DROP VIEW IF EXISTS public.deploiementlibcpl_c CASCADE;
DROP VIEW IF EXISTS public.deploiementlibcpl_f CASCADE;
DROP VIEW IF EXISTS public.deploiementlibcpl_s CASCADE;
DROP VIEW IF EXISTS public.deploiementlibcpl_v CASCADE;
DROP VIEW IF EXISTS public.execution_scriptfille_lib CASCADE;
DROP VIEW IF EXISTS public.execution_scriptfille_cplt CASCADE;
DROP VIEW IF EXISTS public.phase_lib CASCADE;
DROP VIEW IF EXISTS public.phase_project_lib CASCADE;
DROP VIEW IF EXISTS public.phase_projet_lib CASCADE;
DROP VIEW IF EXISTS public.phase_projet_ordre CASCADE;
DROP VIEW IF EXISTS public.somme_par_projet CASCADE;
DROP VIEW IF EXISTS public.nbre_page_par_projet CASCADE;
DROP VIEW IF EXISTS public.nombre_fonctionnalite CASCADE;
DROP VIEW IF EXISTS public.nbre_page_parfonctionnalite CASCADE;
DROP VIEW IF EXISTS public.nbre_page_parfonctionnalite_o CASCADE;
DROP VIEW IF EXISTS public.v_status_projets CASCADE;
DROP VIEW IF EXISTS public.v_projet_encours CASCADE;
DROP VIEW IF EXISTS public.v_phase_projets CASCADE;
DROP VIEW IF EXISTS public.v_projet_devis CASCADE;
DROP VIEW IF EXISTS public.v_avancement_tache CASCADE;
DROP VIEW IF EXISTS public.v_tache_estimation CASCADE;
DROP VIEW IF EXISTS public.v_soustache_lib_acheve CASCADE;
DROP VIEW IF EXISTS public.v_soustache_lib_encours CASCADE;
DROP VIEW IF EXISTS public.v_soustache_lib_enpause CASCADE;
DROP VIEW IF EXISTS public.v_soustache_lib_enretard CASCADE;
DROP VIEW IF EXISTS public.v_soustache_lib_noncommence CASCADE;
DROP VIEW IF EXISTS public.v_equipe_projet CASCADE;
DROP VIEW IF EXISTS public.v_projetutilisateur_lib CASCADE;
DROP VIEW IF EXISTS public.v_ressource_lib CASCADE;
DROP VIEW IF EXISTS public.capacitejournaliere CASCADE;
DROP VIEW IF EXISTS public.jourreposferie CASCADE;
DROP VIEW IF EXISTS public.jourreposlib CASCADE;
DROP VIEW IF EXISTS public.jourreposweekend CASCADE;
DROP VIEW IF EXISTS public.absencelib CASCADE;
DROP VIEW IF EXISTS public.absencelib_annulee CASCADE;
DROP VIEW IF EXISTS public.absencelib_cree CASCADE;
DROP VIEW IF EXISTS public.absencelib_visee CASCADE;
DROP VIEW IF EXISTS public.indisponibilitelib CASCADE;
DROP VIEW IF EXISTS public.external_worklib CASCADE;
DROP VIEW IF EXISTS public.external_worklib_annulee CASCADE;
DROP VIEW IF EXISTS public.external_worklib_cree CASCADE;
DROP VIEW IF EXISTS public.external_worklib_visee CASCADE;
DROP VIEW IF EXISTS public.v_timingapplication_lib CASCADE;
DROP VIEW IF EXISTS public.v_timingsoustache_lib CASCADE;
DROP VIEW IF EXISTS public.v_total_ressource_application CASCADE;
DROP VIEW IF EXISTS public.v_total_ressource_tache CASCADE;
DROP VIEW IF EXISTS public.v_allocation_charges CASCADE;
DROP VIEW IF EXISTS public.v_allocation_charges_all CASCADE;
DROP VIEW IF EXISTS public.propositionlib CASCADE;
DROP VIEW IF EXISTS public.previsionvalide CASCADE;
DROP VIEW IF EXISTS public.prevision_cpl CASCADE;
DROP VIEW IF EXISTS public.prevision_complet_cpl CASCADE;
DROP VIEW IF EXISTS public.prevision_complet_cplpositif CASCADE;
DROP VIEW IF EXISTS public.previsionavecmvtcaisse CASCADE;
DROP VIEW IF EXISTS public.decalageprevision CASCADE;
DROP VIEW IF EXISTS public.serveurlib CASCADE;
DROP VIEW IF EXISTS public.connexion_lib CASCADE;
DROP VIEW IF EXISTS public.touslesdate CASCADE;
DROP VIEW IF EXISTS public.generate_series CASCADE;

-- Vues comptabilité
DROP VIEW IF EXISTS public.compta_balance_etat CASCADE;
DROP VIEW IF EXISTS public.compta_compte_lib CASCADE;
DROP VIEW IF EXISTS public.compta_compte_libelle CASCADE;
DROP VIEW IF EXISTS public.compta_compte_sy CASCADE;
DROP VIEW IF EXISTS public.compta_ecriture_fille CASCADE;
DROP VIEW IF EXISTS public.compta_ecriture_lib CASCADE;
DROP VIEW IF EXISTS public.compta_ecriture_mere CASCADE;
DROP VIEW IF EXISTS public.compta_ecriture_sy CASCADE;
DROP VIEW IF EXISTS public.compta_journal_ecriture_lib CASCADE;
DROP VIEW IF EXISTS public.compta_journal_ecriture_view CASCADE;
DROP VIEW IF EXISTS public.compta_journal_sy CASCADE;
DROP VIEW IF EXISTS public.compta_journal_view CASCADE;
DROP VIEW IF EXISTS public.compta_lettrage_lib CASCADE;
DROP VIEW IF EXISTS public.compta_montant CASCADE;
DROP VIEW IF EXISTS public.compta_mouvement_anal_c CASCADE;
DROP VIEW IF EXISTS public.compta_mouvement_anal_v CASCADE;
DROP VIEW IF EXISTS public.compta_mouvement_analytique CASCADE;
DROP VIEW IF EXISTS public.compta_mouvement_detailgen CASCADE;
DROP VIEW IF EXISTS public.compta_mouvement_details_gen_2 CASCADE;
DROP VIEW IF EXISTS public.comptamouvementdetails_gen_2_c CASCADE;
DROP VIEW IF EXISTS public.comptamouvementdetails_gen_2_v CASCADE;
DROP VIEW IF EXISTS public.compta_mouvement_details_gen_3 CASCADE;
DROP VIEW IF EXISTS public.compta_mouvement_general CASCADE;
DROP VIEW IF EXISTS public.compta_report CASCADE;
DROP VIEW IF EXISTS public.compta_sous_ecriture_anal CASCADE;
DROP VIEW IF EXISTS public.compta_sousecriture_cree2 CASCADE;
DROP VIEW IF EXISTS public.compta_sousecriture_ecriture CASCADE;
DROP VIEW IF EXISTS public.compta_sous_ecriture_gen CASCADE;
DROP VIEW IF EXISTS public.compta_sousecriture_lib CASCADE;
DROP VIEW IF EXISTS public.compta_sousecriture_sanspg CASCADE;
DROP VIEW IF EXISTS public.compta_sous_ecriture_sy CASCADE;
DROP VIEW IF EXISTS public.compta_sousecriture_visee CASCADE;
DROP VIEW IF EXISTS public.compta_view_folio CASCADE;
DROP VIEW IF EXISTS public.mouvementcaissecpl CASCADE;
DROP VIEW IF EXISTS public.mouvementcaissecpl_valider CASCADE;
DROP VIEW IF EXISTS public.mouvementcaisse_vise CASCADE;
DROP VIEW IF EXISTS public.mouvementcaissegroupefacture CASCADE;
DROP VIEW IF EXISTS public.mvtcaisseprevisionvise CASCADE;
DROP VIEW IF EXISTS public.mvtcaissesomprevisiongroup CASCADE;
DROP VIEW IF EXISTS public.reportcaisse_devise CASCADE;
DROP VIEW IF EXISTS public.reportsolde CASCADE;
DROP VIEW IF EXISTS public.avoirfclib CASCADE;
DROP VIEW IF EXISTS public.avoirfclib_cpl CASCADE;
DROP VIEW IF EXISTS public.avoirfclib_cpl_grp CASCADE;
DROP VIEW IF EXISTS public.avoirfclib_cpl_visee CASCADE;
DROP VIEW IF EXISTS public.avoirfcfille_grp CASCADE;
DROP VIEW IF EXISTS public.devis_lib CASCADE;
DROP VIEW IF EXISTS public.devis_lib2 CASCADE;
DROP VIEW IF EXISTS public.devis_libcree CASCADE;
DROP VIEW IF EXISTS public.devis_libfait CASCADE;
DROP VIEW IF EXISTS public.devis_libvalideclient CASCADE;
DROP VIEW IF EXISTS public.devis_libvalideintere CASCADE;
DROP VIEW IF EXISTS public.devis_fille_lib CASCADE;
DROP VIEW IF EXISTS public.v_etatcaisse CASCADE;
DROP VIEW IF EXISTS public.v_etat_devis CASCADE;
DROP VIEW IF EXISTS public.v_devis_cpl_lib CASCADE;
DROP VIEW IF EXISTS public.v_devis_libetat CASCADE;
DROP VIEW IF EXISTS public.resultatprevisionneleffectif CASCADE;
DROP VIEW IF EXISTS public.resultatpreveffectiftous CASCADE;
DROP VIEW IF EXISTS public.resultatprevisionnelmvt CASCADE;
DROP VIEW IF EXISTS public.resultatprevisionneltousmvt CASCADE;
DROP VIEW IF EXISTS public.insertion_vente CASCADE;
DROP VIEW IF EXISTS public.vente_cpl CASCADE;
DROP VIEW IF EXISTS public.vente_cpl_eur CASCADE;
DROP VIEW IF EXISTS public.vente_cpl_mga CASCADE;
DROP VIEW IF EXISTS public.vente_cpl_usd CASCADE;
DROP VIEW IF EXISTS public.vente_details_cpl CASCADE;
DROP VIEW IF EXISTS public.vente_details_saisie CASCADE;
DROP VIEW IF EXISTS public.vente_grp_tous CASCADE;
DROP VIEW IF EXISTS public.vente_grp_viser CASCADE;
DROP VIEW IF EXISTS public.vente_lib CASCADE;
DROP VIEW IF EXISTS public.vente_mere_montant CASCADE;
DROP VIEW IF EXISTS public.vente_mf CASCADE;
DROP VIEW IF EXISTS public.ventemontant CASCADE;
DROP VIEW IF EXISTS public.tiers CASCADE;
DROP VIEW IF EXISTS public.client_libcomplet CASCADE;
DROP VIEW IF EXISTS public.client_tmp CASCADE;

-- Vues APJ builder / code génération
DROP VIEW IF EXISTS public.apjclasselib CASCADE;
DROP VIEW IF EXISTS public.apjclasselib2 CASCADE;
DROP VIEW IF EXISTS public.architecturelib CASCADE;
DROP VIEW IF EXISTS public.architecturelibavecpage CASCADE;
DROP VIEW IF EXISTS public.architecturelibbasergrp CASCADE;
DROP VIEW IF EXISTS public.architecturelibbasergrpapj CASCADE;
DROP VIEW IF EXISTS public.architecturelibbasergrpspec CASCADE;
DROP VIEW IF EXISTS public.architecturelibmetiergrp CASCADE;
DROP VIEW IF EXISTS public.architecturelibmetiergrpapj CASCADE;
DROP VIEW IF EXISTS public.architecturelibmetiergrpspec CASCADE;
DROP VIEW IF EXISTS public.architecturelibsanspagegrp CASCADE;
DROP VIEW IF EXISTS public.architecturemetierdefaut CASCADE;
DROP VIEW IF EXISTS public.architecturemetierdefautlib CASCADE;
DROP VIEW IF EXISTS public.baselib CASCADE;
DROP VIEW IF EXISTS public.baselibapj CASCADE;
DROP VIEW IF EXISTS public.baselibspec CASCADE;
DROP VIEW IF EXISTS public.baserelationlib CASCADE;
DROP VIEW IF EXISTS public.basedependanceview CASCADE;
DROP VIEW IF EXISTS public.basedependanceviewlib CASCADE;
DROP VIEW IF EXISTS public.metierlib CASCADE;
DROP VIEW IF EXISTS public.metierlibapj CASCADE;
DROP VIEW IF EXISTS public.metierlibspec CASCADE;
DROP VIEW IF EXISTS public.metier_fmlib CASCADE;
DROP VIEW IF EXISTS public.metierfille_lib CASCADE;
DROP VIEW IF EXISTS public.metierrelationlib CASCADE;
DROP VIEW IF EXISTS public.metierdependanceview CASCADE;
DROP VIEW IF EXISTS public.metierdependanceviewlib CASCADE;
DROP VIEW IF EXISTS public.classelib CASCADE;
DROP VIEW IF EXISTS public.attributclasselib CASCADE;
DROP VIEW IF EXISTS public.page_lib CASCADE;
DROP VIEW IF EXISTS public.page_libapj CASCADE;
DROP VIEW IF EXISTS public.page_libcomplet CASCADE;
DROP VIEW IF EXISTS public.page_libspec CASCADE;
DROP VIEW IF EXISTS public.page_projet CASCADE;
DROP VIEW IF EXISTS public.pagelien CASCADE;
DROP VIEW IF EXISTS public.pageanalyselib CASCADE;
DROP VIEW IF EXISTS public.pageanalyseattributlib CASCADE;
DROP VIEW IF EXISTS public.pagefichelib CASCADE;
DROP VIEW IF EXISTS public.pageficheattributlib CASCADE;
DROP VIEW IF EXISTS public.pagelistelib CASCADE;
DROP VIEW IF EXISTS public.pagelistelib2 CASCADE;
DROP VIEW IF EXISTS public.pagelisteattributlib CASCADE;
DROP VIEW IF EXISTS public.pagerelationlib CASCADE;
DROP VIEW IF EXISTS public.pagesaisielib CASCADE;
DROP VIEW IF EXISTS public.pageattributlib CASCADE;
DROP VIEW IF EXISTS public.pageattributlib2 CASCADE;
DROP VIEW IF EXISTS public.panalysechampfiltrelib CASCADE;
DROP VIEW IF EXISTS public.plistchampfiltrelib CASCADE;
DROP VIEW IF EXISTS public.pagechampfiltre CASCADE;
DROP VIEW IF EXISTS public.pagechampfiltreattribut CASCADE;
DROP VIEW IF EXISTS public.champdynamiquelib CASCADE;
DROP VIEW IF EXISTS public.champdynamique_squl CASCADE;
DROP VIEW IF EXISTS public.champsspeciauxlib CASCADE;
DROP VIEW IF EXISTS public.champsspeciaux_squl CASCADE;
DROP VIEW IF EXISTS public.menudynamiquelib CASCADE;   -- recréée après alumni SQL si besoin
DROP VIEW IF EXISTS public.menu_fils CASCADE;          -- recréée après alumni SQL si besoin
DROP VIEW IF EXISTS public.mappingtypeattributlib CASCADE;
DROP VIEW IF EXISTS public.diagramobjet CASCADE;
DROP VIEW IF EXISTS public.v_diagramclasslibcomplet CASCADE;
DROP VIEW IF EXISTS public.v_classeetfiche CASCADE;
DROP VIEW IF EXISTS public.crcontentlib CASCADE;
DROP VIEW IF EXISTS public.crcontentfillelib CASCADE;
DROP VIEW IF EXISTS public.crdateformu CASCADE;
DROP VIEW IF EXISTS public.conception_pme CASCADE;
DROP VIEW IF EXISTS public.conception_pmlib CASCADE;
DROP VIEW IF EXISTS public.conception_pm_metier CASCADE;
DROP VIEW IF EXISTS public.creation_projetpages CASCADE;
DROP VIEW IF EXISTS public.decomptepage CASCADE;
DROP VIEW IF EXISTS public.actionlib CASCADE;
DROP VIEW IF EXISTS public.actiontachelib CASCADE;
DROP VIEW IF EXISTS public.actiontachelibvalide CASCADE;
DROP VIEW IF EXISTS public.notificationlib CASCADE;
DROP VIEW IF EXISTS public.notificationlibnonlu CASCADE;
DROP VIEW IF EXISTS public.notificationsignalnonvise CASCADE;
DROP VIEW IF EXISTS public.notificationvalide CASCADE;
DROP VIEW IF EXISTS public.notificationgroupdetailsuser CASCADE;
DROP VIEW IF EXISTS public.piecejointe_lib CASCADE;
DROP VIEW IF EXISTS public.piecejointe_libcomplet CASCADE;
DROP VIEW IF EXISTS public.historiqueactiflib CASCADE;
DROP VIEW IF EXISTS public.historique_libelle CASCADE;
DROP VIEW IF EXISTS public.v_historique CASCADE;
DROP VIEW IF EXISTS public.v_histoinsert CASCADE;
DROP VIEW IF EXISTS public.v_historique_creation_tache CASCADE;
DROP VIEW IF EXISTS public.v_historique_fileaccess CASCADE;
DROP VIEW IF EXISTS public.v_historique_log_desc CASCADE;
DROP VIEW IF EXISTS public.v_alertscheduler_now CASCADE;
DROP VIEW IF EXISTS public.entitelib CASCADE;
DROP VIEW IF EXISTS public.attribusentitelib CASCADE;
DROP VIEW IF EXISTS public.relationlib CASCADE;
DROP VIEW IF EXISTS public.canevatachelib CASCADE;
DROP VIEW IF EXISTS public.cheminprojetuserlib CASCADE;
DROP VIEW IF EXISTS public.utilisateuracade_vue CASCADE;
DROP VIEW IF EXISTS public.utilisateur_equipe_cpl CASCADE;
DROP VIEW IF EXISTS public.utilisateurvue_roles CASCADE;

-- Vues APJ core À RECRÉER APRÈS (supprimer les anciennes versions ici)
DROP VIEW IF EXISTS public.utilisateurvalide CASCADE;
DROP VIEW IF EXISTS public.utilisateurvue CASCADE;
DROP VIEW IF EXISTS public.utilisateurrole CASCADE;

-- ============================================================================
-- ÉTAPE 2 : SUPPRESSION DES TABLES (de la fille vers la mère)
-- ============================================================================

-- Tables donation (métier)
DROP TABLE IF EXISTS public.repartitiondetails CASCADE;
DROP TABLE IF EXISTS public.repartition CASCADE;
DROP TABLE IF EXISTS public.donation CASCADE;
DROP TABLE IF EXISTS public.promesse CASCADE;
DROP TABLE IF EXISTS public.entitedonateur CASCADE;
DROP TABLE IF EXISTS public.categoriedonateur CASCADE;
DROP TABLE IF EXISTS public.recepteur CASCADE;
DROP TABLE IF EXISTS public.source CASCADE;

-- Tables gestion de projet (filles d'abord)
DROP TABLE IF EXISTS public.tache_git_details CASCADE;
DROP TABLE IF EXISTS public.tache_git_mere CASCADE;
DROP TABLE IF EXISTS public.timingsoustache CASCADE;
DROP TABLE IF EXISTS public.timingapplication CASCADE;
DROP TABLE IF EXISTS public.tempstravail CASCADE;
DROP TABLE IF EXISTS public.tauxavancementmodule CASCADE;
DROP TABLE IF EXISTS public.tauxavancementprojet CASCADE;
DROP TABLE IF EXISTS public.exceptiontache CASCADE;
DROP TABLE IF EXISTS public.canevatache CASCADE;
DROP TABLE IF EXISTS public.actiontache CASCADE;
DROP TABLE IF EXISTS public.tache CASCADE;
DROP TABLE IF EXISTS public.tachemeredefaut CASCADE;
DROP TABLE IF EXISTS public.tachedefaut CASCADE;
DROP TABLE IF EXISTS public.tachemere CASCADE;
DROP TABLE IF EXISTS public.cheminprojetuser CASCADE;
DROP TABLE IF EXISTS public.dependanceobjet CASCADE;
DROP TABLE IF EXISTS public.entitescript CASCADE;
DROP TABLE IF EXISTS public.execution_scriptfille CASCADE;
DROP TABLE IF EXISTS public.execution_script CASCADE;
DROP TABLE IF EXISTS public.scriptversionning CASCADE;
DROP TABLE IF EXISTS public.script_projet CASCADE;
DROP TABLE IF EXISTS public.script CASCADE;
DROP TABLE IF EXISTS public.deploiement CASCADE;
DROP TABLE IF EXISTS public.pageficheattribut CASCADE;
DROP TABLE IF EXISTS public.pagefiche CASCADE;
DROP TABLE IF EXISTS public.pageanalyseattribut CASCADE;
DROP TABLE IF EXISTS public.pageanalyse CASCADE;
DROP TABLE IF EXISTS public.pagelisteattribut CASCADE;
DROP TABLE IF EXISTS public.pageliste CASCADE;
DROP TABLE IF EXISTS public.pageattribut CASCADE;
DROP TABLE IF EXISTS public.pagerelation CASCADE;
DROP TABLE IF EXISTS public.pagesaisie CASCADE;
DROP TABLE IF EXISTS public.panalysechampfiltre CASCADE;
DROP TABLE IF EXISTS public.plistchampfiltre CASCADE;
DROP TABLE IF EXISTS public.page CASCADE;
DROP TABLE IF EXISTS public.fonctionnalite CASCADE;
DROP TABLE IF EXISTS public.module_projet CASCADE;
DROP TABLE IF EXISTS public.actionprojet CASCADE;
DROP TABLE IF EXISTS public.action CASCADE;            -- recréé par alumni SQL
DROP TABLE IF EXISTS public.restriction CASCADE;       -- recréé par alumni SQL
DROP TABLE IF EXISTS public.projet_equipe CASCADE;
DROP TABLE IF EXISTS public.projetutilisateur CASCADE;
DROP TABLE IF EXISTS public.utilisateur_equipe CASCADE;
DROP TABLE IF EXISTS public.equipe CASCADE;
DROP TABLE IF EXISTS public.work_branche CASCADE;
DROP TABLE IF EXISTS public.work_type CASCADE;
DROP TABLE IF EXISTS public.branche CASCADE;
DROP TABLE IF EXISTS public.phase_project CASCADE;
DROP TABLE IF EXISTS public.phase CASCADE;
DROP TABLE IF EXISTS public.module CASCADE;
DROP TABLE IF EXISTS public.coutprevisionnel CASCADE;
DROP TABLE IF EXISTS public.conception_pm CASCADE;
DROP TABLE IF EXISTS public.creation_projet CASCADE;
DROP TABLE IF EXISTS public.projet CASCADE;

-- Tables RH / présence
DROP TABLE IF EXISTS public.pointage CASCADE;
DROP TABLE IF EXISTS public.absence CASCADE;
DROP TABLE IF EXISTS public.typeabsence CASCADE;
DROP TABLE IF EXISTS public.external_work CASCADE;
DROP TABLE IF EXISTS public.indisponibilite CASCADE;
DROP TABLE IF EXISTS public.disponibilite CASCADE;
DROP TABLE IF EXISTS public.jourrepos CASCADE;
DROP TABLE IF EXISTS public.typerepos CASCADE;
DROP TABLE IF EXISTS public.honoraire CASCADE;
DROP TABLE IF EXISTS public.tauxhonoraire CASCADE;
DROP TABLE IF EXISTS public.cnaps_user CASCADE;

-- Tables comptabilité / finance
DROP TABLE IF EXISTS public.mvtcaisseprevision CASCADE;
DROP TABLE IF EXISTS public.pertegainimprevue CASCADE;
DROP TABLE IF EXISTS public.prevision CASCADE;
DROP TABLE IF EXISTS public.mouvementcaisse CASCADE;
DROP TABLE IF EXISTS public.reportcaisse CASCADE;
DROP TABLE IF EXISTS public.ordonnerpaiement CASCADE;
DROP TABLE IF EXISTS public.caisse CASCADE;
DROP TABLE IF EXISTS public.categoriecaisse CASCADE;
DROP TABLE IF EXISTS public.typecaisse CASCADE;
DROP TABLE IF EXISTS public.motifavoirfc CASCADE;
DROP TABLE IF EXISTS public.avoirfcfille CASCADE;
DROP TABLE IF EXISTS public.avoirfc CASCADE;
DROP TABLE IF EXISTS public.categorieavoirfc CASCADE;
DROP TABLE IF EXISTS public.compta_lettrage CASCADE;
DROP TABLE IF EXISTS public.compta_sous_ecriture_backup CASCADE;
DROP TABLE IF EXISTS public.compta_sous_ecriture CASCADE;
DROP TABLE IF EXISTS public.compta_ecriture_backup CASCADE;
DROP TABLE IF EXISTS public.compta_ecriture CASCADE;
DROP TABLE IF EXISTS public.compta_journal_backup CASCADE;
DROP TABLE IF EXISTS public.compta_journal CASCADE;
DROP TABLE IF EXISTS public.compta_compte_backup CASCADE;
DROP TABLE IF EXISTS public.compta_compte CASCADE;
DROP TABLE IF EXISTS public.compta_classe_compte CASCADE;
DROP TABLE IF EXISTS public.compta_origine CASCADE;
DROP TABLE IF EXISTS public.compta_type_compte CASCADE;
DROP TABLE IF EXISTS public.compta_exercice CASCADE;
DROP TABLE IF EXISTS public.tauxdechange CASCADE;
DROP TABLE IF EXISTS public.devise CASCADE;
DROP TABLE IF EXISTS public.devis_fille CASCADE;
DROP TABLE IF EXISTS public.devis CASCADE;
DROP TABLE IF EXISTS public.proposition CASCADE;

-- Tables commerce / vente
DROP TABLE IF EXISTS public.vente_details CASCADE;
DROP TABLE IF EXISTS public.vente CASCADE;
DROP TABLE IF EXISTS public.client CASCADE;
DROP TABLE IF EXISTS public.niveauclient CASCADE;
DROP TABLE IF EXISTS public.fournisseur CASCADE;
DROP TABLE IF EXISTS public.typefournisseur CASCADE;
DROP TABLE IF EXISTS public.magasin2 CASCADE;
DROP TABLE IF EXISTS public.typemagasin CASCADE;
DROP TABLE IF EXISTS public.point CASCADE;
DROP TABLE IF EXISTS public.as_ingredients CASCADE;
DROP TABLE IF EXISTS public.categorieingredient CASCADE;
DROP TABLE IF EXISTS public.categorie CASCADE;
DROP TABLE IF EXISTS public.ouinon CASCADE;
DROP TABLE IF EXISTS public.typeouinon CASCADE;
DROP TABLE IF EXISTS public.cote CASCADE;
DROP TABLE IF EXISTS public.unite CASCADE;
DROP TABLE IF EXISTS public.qualite CASCADE;

-- Tables APJ builder / code génération
DROP TABLE IF EXISTS public.relationlib CASCADE; -- view already dropped, safety
DROP TABLE IF EXISTS public.metierrelation CASCADE;
DROP TABLE IF EXISTS public.metierfille CASCADE;
DROP TABLE IF EXISTS public.metier CASCADE;
DROP TABLE IF EXISTS public.typeactionmetier CASCADE;
DROP TABLE IF EXISTS public.typemetier CASCADE;
DROP TABLE IF EXISTS public.baserelation CASCADE;
DROP TABLE IF EXISTS public.attribusentite CASCADE;
DROP TABLE IF EXISTS public.entite CASCADE;
DROP TABLE IF EXISTS public.pageficheattribut CASCADE; -- already done, safety
DROP TABLE IF EXISTS public.attributclasse CASCADE;
DROP TABLE IF EXISTS public.typeattributclasse CASCADE;
DROP TABLE IF EXISTS public.attributoracle CASCADE;
DROP TABLE IF EXISTS public.attributpostgres CASCADE;
DROP TABLE IF EXISTS public.attributtype CASCADE;
DROP TABLE IF EXISTS public.classeetfiche CASCADE;
DROP TABLE IF EXISTS public.classe CASCADE;
DROP TABLE IF EXISTS public.typeclasse CASCADE;
DROP TABLE IF EXISTS public.apjclasse CASCADE;
DROP TABLE IF EXISTS public.diagramtablecolonne CASCADE;
DROP TABLE IF EXISTS public.diagramtable CASCADE;
DROP TABLE IF EXISTS public.diagramclasscomposant CASCADE;
DROP TABLE IF EXISTS public.diagramclasscomposanttype CASCADE;
DROP TABLE IF EXISTS public.diagramclasspackage CASCADE;
DROP TABLE IF EXISTS public.diagramclass CASCADE;
DROP TABLE IF EXISTS public.diagramaffichage CASCADE;
DROP TABLE IF EXISTS public.typedependancediagram CASCADE;
DROP TABLE IF EXISTS public.typeliaison CASCADE;
DROP TABLE IF EXISTS public.typerelation CASCADE;
DROP TABLE IF EXISTS public.typebase CASCADE;
DROP TABLE IF EXISTS public.base CASCADE;
DROP TABLE IF EXISTS public.relation CASCADE;
DROP TABLE IF EXISTS public.conception_pm CASCADE; -- safety
DROP TABLE IF EXISTS public.architecture CASCADE;
DROP TABLE IF EXISTS public.champdynamique CASCADE;
DROP TABLE IF EXISTS public.champsspeciaux CASCADE;
DROP TABLE IF EXISTS public.typechampsspeciaux CASCADE;
DROP TABLE IF EXISTS public.boutonchamp CASCADE;
DROP TABLE IF EXISTS public.boutonpage CASCADE;
DROP TABLE IF EXISTS public.panalysechampfiltre CASCADE; -- safety
DROP TABLE IF EXISTS public.plistchampfiltre CASCADE;   -- safety
DROP TABLE IF EXISTS public.typepageanalyse CASCADE;
DROP TABLE IF EXISTS public.typepageliste CASCADE;
DROP TABLE IF EXISTS public.typepagesaisie CASCADE;
DROP TABLE IF EXISTS public.typeplistchampfiltre CASCADE;
DROP TABLE IF EXISTS public.typepage CASCADE;
DROP TABLE IF EXISTS public.typetache CASCADE;
DROP TABLE IF EXISTS public.typeaction CASCADE;
DROP TABLE IF EXISTS public.typescript CASCADE;
DROP TABLE IF EXISTS public.mappingtypeattribut CASCADE;
DROP TABLE IF EXISTS public.menudynamique CASCADE;    -- recréé par alumni SQL
DROP TABLE IF EXISTS public.usermenu CASCADE;          -- recréé par alumni SQL
DROP TABLE IF EXISTS public.crconfig CASCADE;
DROP TABLE IF EXISTS public.crcontentfille CASCADE;
DROP TABLE IF EXISTS public.crcontent CASCADE;
DROP TABLE IF EXISTS public.analyses CASCADE;
DROP TABLE IF EXISTS public.typefichier CASCADE;
DROP TABLE IF EXISTS public.attacher_fichier CASCADE;
DROP TABLE IF EXISTS public.piecejointe CASCADE;
DROP TABLE IF EXISTS public.mailcc CASCADE;            -- recréé par alumni SQL
DROP TABLE IF EXISTS public.mailrapport CASCADE;

-- Tables notification
DROP TABLE IF EXISTS public.notificationsignal CASCADE;
DROP TABLE IF EXISTS public.notificationdetails CASCADE;
DROP TABLE IF EXISTS public.notificationgroupe CASCADE;
DROP TABLE IF EXISTS public.notificationaction CASCADE;
DROP TABLE IF EXISTS public.notification CASCADE;

-- Tables log / historique (donation)
DROP TABLE IF EXISTS public.log_direction CASCADE;
DROP TABLE IF EXISTS public.log_personnel CASCADE;
DROP TABLE IF EXISTS public.log_service CASCADE;
DROP TABLE IF EXISTS public.histoimport CASCADE;
DROP TABLE IF EXISTS public.histoinsert CASCADE;
DROP TABLE IF EXISTS public.historiqueactif CASCADE;
DROP TABLE IF EXISTS public.historique_valeur CASCADE; -- recréé par alumni SQL

-- Tables divers
DROP TABLE IF EXISTS public.alertscheduler CASCADE;
DROP TABLE IF EXISTS public.requete_a_envoyer CASCADE;
DROP TABLE IF EXISTS public.serveur CASCADE;
DROP TABLE IF EXISTS public.connexion CASCADE;
DROP TABLE IF EXISTS public.external_work CASCADE;  -- safety

-- Tables infrastructure géographique
DROP TABLE IF EXISTS public.fokontany CASCADE;
DROP TABLE IF EXISTS public.commune CASCADE;
DROP TABLE IF EXISTS public.district CASCADE;
DROP TABLE IF EXISTS public.region CASCADE;
DROP TABLE IF EXISTS public.province CASCADE;
DROP TABLE IF EXISTS public.ministere CASCADE;
DROP TABLE IF EXISTS public.niveau CASCADE;
DROP TABLE IF EXISTS public.categorieniveau CASCADE;
DROP TABLE IF EXISTS public.pays CASCADE;       -- présent dans donation, sera recréé pour alumni

-- Tables type génériques donation/teamtask
DROP TABLE IF EXISTS public.type CASCADE;

-- type_utilisateur: EXISTS in donation but will be RECREATED for alumni
DROP TABLE IF EXISTS public.type_utilisateur CASCADE;

-- ============================================================================
-- ÉTAPE 2b : SUPPRESSION DES TABLES APJ CORE À RECRÉER
-- Ces tables APJ sont conservées telles quelles dans le dump donation mais
-- doivent être droppées puis recréées avec la structure alumni par le script
-- 2026-02-21-Alumni-1.sql. Sans ce drop, le script alumni échouera (table exists).
-- ORDRE IMPORTANT : supprimer les dépendantes avant les mères.
-- ============================================================================

-- Dépendantes de utilisateur
DROP TABLE IF EXISTS public.paramcrypt CASCADE;           -- recréée par alumni SQL
DROP TABLE IF EXISTS public.annulationutilisateur CASCADE; -- recréée par alumni SQL

-- Table utilisateur : structure donation ≠ structure alumni (colonnes alumni manquantes)
DROP TABLE IF EXISTS public.utilisateur CASCADE;          -- recréée avec prenom/etu/mail/photo/etc.

-- Autres tables APJ core recréées par alumni SQL
DROP TABLE IF EXISTS public.roles CASCADE;                -- recréée par alumni SQL
DROP TABLE IF EXISTS public.historique CASCADE;           -- recréée par alumni SQL
DROP TABLE IF EXISTS public.direction CASCADE;            -- recréée par alumni SQL
DROP TABLE IF EXISTS public.userhomepage CASCADE;         -- recréée par alumni SQL

-- ============================================================================
-- ÉTAPE 3 : RÉACTIVER LES CONTRAINTES FK
-- ============================================================================
SET session_replication_role = DEFAULT;

-- ============================================================================
-- ÉTAPE 4 : SUPPRESSION DES SÉQUENCES INUTILES (optionnel)
-- ============================================================================
-- Décommenter si besoin de nettoyer les séquences orphelines
-- SELECT 'DROP SEQUENCE IF EXISTS public.' || relname || ' CASCADE;'
-- FROM pg_class WHERE relkind = 'S' AND relnamespace = 'public'::regnamespace;

-- ============================================================================
-- RÉSULTAT ATTENDU :
-- Après ce script, la base doit être VIDE (aucune table ne subsiste).
--
-- ÉTAPE SUIVANTE OBLIGATOIRE :
--   Exécuter BDD/2026-02-21-Alumni-1.sql pour créer la structure complète.
--   Ce script crée toutes les tables nécessaires :
--     APJ core  : roles, utilisateur, paramcrypt, historique,
--                 annulationutilisateur, direction, userhomepage,
--                 restriction, historique_valeur, mailcc, action,
--                 menudynamique, usermenu
--     Alumni    : type_utilisateur, type_emploie, promotion, specialite,
--                 competence, diplome, pays, ville, ecole, domaine,
--                 parcours, entreprise, experience, reseaux_sociaux, etc.
-- ============================================================================
