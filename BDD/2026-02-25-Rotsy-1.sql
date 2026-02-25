-- Vue pivot pour VisibiliteConfig (PageUpdate APJ)
-- Transforme les lignes EAV de visibilite_utilisateur en une ligne plate par utilisateur
-- COALESCE → 1 = visible par défaut si aucune préférence définie
-- DROP VIEW v_visibilite_config;
CREATE OR REPLACE VIEW v_visibilite_config AS
SELECT
    CAST(u.refuser AS VARCHAR(10)) AS idutilisateur,
    CAST(COALESCE(MAX(CASE WHEN v.nomchamp = 'mail'        THEN v.visible END), 1) AS VARCHAR(2)) AS visimail,
    CAST(COALESCE(MAX(CASE WHEN v.nomchamp = 'teluser'     THEN v.visible END), 1) AS VARCHAR(2)) AS visiteluser,
    CAST(COALESCE(MAX(CASE WHEN v.nomchamp = 'adruser'     THEN v.visible END), 1) AS VARCHAR(2)) AS visiadruser,
    CAST(COALESCE(MAX(CASE WHEN v.nomchamp = 'photo'       THEN v.visible END), 1) AS VARCHAR(2)) AS visiphoto,
    CAST(COALESCE(MAX(CASE WHEN v.nomchamp = 'prenom'      THEN v.visible END), 1) AS VARCHAR(2)) AS visiprenom,
    CAST(COALESCE(MAX(CASE WHEN v.nomchamp = 'nomuser'     THEN v.visible END), 1) AS VARCHAR(2)) AS visinomuser,
    CAST(COALESCE(MAX(CASE WHEN v.nomchamp = 'loginuser'   THEN v.visible END), 1) AS VARCHAR(2)) AS visiloginuser,
    CAST(COALESCE(MAX(CASE WHEN v.nomchamp = 'idpromotion' THEN v.visible END), 1) AS VARCHAR(2)) AS visiidpromotion
FROM utilisateur u
LEFT JOIN visibilite_utilisateur v ON u.refuser = v.idutilisateur
GROUP BY u.refuser;
