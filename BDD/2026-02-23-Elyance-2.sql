INSERT INTO roles (idrole, descrole, rang) VALUES ('utilisateur', 'Utilisateur', 2);

UPDATE utilisateur SET idrole = 'utilisateur' WHERE idrole = 'alumni' OR idrole = 'etudiant';

DELETE FROM roles WHERE idrole IN ('etudiant', 'alumni');