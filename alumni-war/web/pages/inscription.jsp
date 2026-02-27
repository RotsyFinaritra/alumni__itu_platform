    <style>
        .field, .input-wrap {
            width: 100%;
        }
        .input-wrap input,
        .input-wrap select {
            width: 100%;
            min-width: 0;
            box-sizing: border-box;
            display: block;
            background: var(--input-bg, #fff);
            color: #1b1f26;
            border: 0;
            outline: 0;
            height: 36px;
            font-size: 13px;
            padding: 0 8px;
            border-radius: 4px;
        }
        .input-wrap select {
            appearance: none;
            -webkit-appearance: none;
            -moz-appearance: none;
        }
        .input-wrap select:focus, .input-wrap input:focus {
            outline: none;
        }
        .input-wrap {
            display: flex;
            align-items: center;
            background: var(--input-bg);
            border: 1px solid var(--border);
            border-radius: 4px;
            height: 36px;
            overflow: hidden;
        }
        .input-wrap .icon {
            display: grid;
            place-items: center;
            color: #9aa0a6;
            margin-left: 8px;
            margin-right: 8px;
        }
        /* Pour les champs côte à côte (flex) */
        #etu-promo-fields > div {
            display: flex;
            gap: 10px;
            width: 100%;
        }
        #etu-promo-fields label {
            width: 100%;
        }
    </style>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Inscription</title>
    <link href="${pageContext.request.contextPath}/assets/css/refontlogin.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/api-global-style.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/refontSidebar.css" rel="stylesheet">

    <style>
        .input-wrap input[type="text"],
        .input-wrap input[type="email"],
        .input-wrap input[type="password"],
        .input-wrap input[type="tel"],
        .input-wrap input[type="file"],
        .input-wrap select {
            width: 100%;
            box-sizing: border-box;
        }
        .input-wrap input[type="file"] {
            font-size: 12px;
            cursor: pointer;
        }
    </style>
</head>
<body>
<div class="page">
    <div class="frame">
        <section class="panel-left" style="overflow: scroll;">
            <header class="brand">
            </header>
            <main class="card">
                <h1>Inscription</h1>
                <p class="subtitle">Créez votre compte</p>

                            <%
                                String inscriptionError = (String) session.getAttribute("errorInscription");
                                if (inscriptionError != null) {
                                    session.removeAttribute("errorInscription");
                            %>
                            <div style="color: red; margin-bottom: 10px;">
                                <%= inscriptionError %>
                            </div>
                            <%
                                }
                                String success = (String) session.getAttribute("successInscription");
                                if (success != null) {
                                    session.removeAttribute("successInscription");
                            %>
                            <div style="color: green; margin-bottom: 10px;">
                                <%= success %>
                            </div>
                            <%
                                }

                                // Récupération de la liste des types d'utilisateur via le framework
                                java.sql.Connection cType = null;
                                bean.TypeUtilisateur[] typesUtilisateur = null;
                                try {
                                    cType = new utilitaire.UtilDB().GetConn();
                                    bean.TypeUtilisateur tu = new bean.TypeUtilisateur();
                                    typesUtilisateur = (bean.TypeUtilisateur[]) bean.CGenUtil.rechercher(tu, null, null, cType, "");
                                } catch (Exception e) {
                                    e.printStackTrace();
                                } finally {
                                    if (cType != null) try { cType.close(); } catch (Exception ex) {}
                                }
                            %>

                <form class="form" action="testRegister.jsp" method="post" enctype="multipart/form-data">
                    <!-- Type d'utilisateur EN PREMIER -->
                    <label class="field">
                        <span class="label">Type d'utilisateur <span style="color: red;">*</span></span>
                        <span class="input-wrap">
                            <span class="icon" aria-hidden="true">
                                <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M12 12a5 5 0 1 0-5-5 5 5 0 0 0 5 5zm0 2c-5.33 0-8 2.67-8 6a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1c0-3.33-2.67-6-8-6z"/></svg>
                            </span>
                            <select name="idtypeutilisateur" id="idtypeutilisateur-select" required onchange="toggleIdentificationFields()">
                                <option value="">Sélectionner un type</option>
                                <%
                                    if (typesUtilisateur != null) {
                                        for (int i = 0; i < typesUtilisateur.length; i++) {
                                            bean.TypeUtilisateur tu = typesUtilisateur[i];
                                %>
                                    <option value="<%= tu.getId() %>"><%= tu.getLibelle() %></option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                        </span>
                    </label>

                    <!-- Champ d'identification (ETU ou Code Enseignant) -->
                    <div id="identification-container">
                        <!-- Conteneur pour ETU (visible par défaut pour étudiants/alumni) -->
                        <label class="field" id="etu-field" style="display: none;">
                            <span class="label">Numéro étudiant (ETU) <span style="color: red;">*</span></span>
                            <span class="input-wrap">
                                <span class="icon" aria-hidden="true">
                                    <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M3 6v12a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2zm2 0h14v12H5V6zm7 2a2 2 0 1 1-2 2 2 2 0 0 1 2-2z"/></svg>
                                </span>
                                <input type="text" name="etu" id="etu-input" placeholder="Ex: ETU001234" />
                            </span>
                        </label>

                        <!-- Conteneur pour Code Enseignant (visible pour enseignants) -->
                        <label class="field" id="prof-field" style="display: none;">
                            <span class="label">Code Enseignant <span style="color: red;">*</span></span>
                            <span class="input-wrap">
                                <span class="icon" aria-hidden="true">
                                    <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>
                                </span>
                                <input type="text" name="prof_code" id="prof-code-input" placeholder="Ex: ENS001" list="enseignants-list" />
                                <datalist id="enseignants-list"></datalist>
                            </span>
                        </label>
                    </div>

                    <div class="alert" style="background: #e8f4fd; border-left: 4px solid #0095DA; padding: 12px; margin-bottom: 15px; border-radius: 4px;">
                        <strong>ℹ️ Information importante :</strong> <span id="alert-text">Votre numéro étudiant (ETU) sera votre identifiant de connexion.</span>
                    </div>

                    <label class="field">
                        <span class="label">Nom <span style="color: red;">*</span></span>
                        <span class="input-wrap">
                            <span class="icon" aria-hidden="true">
                                <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M12 12a5 5 0 1 0-5-5 5 5 0 0 0 5 5zm0 2c-5.33 0-8 2.67-8 6a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1c0-3.33-2.67-6-8-6z"/></svg>
                            </span>
                            <input type="text" name="nomuser" placeholder="Entrer votre nom" required />
                        </span>
                    </label>

                    <label class="field">
                        <span class="label">Prénom <span style="color: red;">*</span></span>
                        <span class="input-wrap">
                            <span class="icon" aria-hidden="true">
                                <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M12 12a5 5 0 1 0-5-5 5 5 0 0 0 5 5zm0 2c-5.33 0-8 2.67-8 6a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1c0-3.33-2.67-6-8-6z"/></svg>
                            </span>
                            <input type="text" name="prenom" placeholder="Entrer votre prénom" required />
                        </span>
                    </label>

                    <label class="field">
                        <span class="label">Email <span style="color: red;">*</span></span>
                        <span class="input-wrap">
                            <span class="icon" aria-hidden="true">
                                <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M20 4H4a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V6a2 2 0 0 0-2-2zm0 2v.01L12 13 4 6.01V6h16zM4 18V8.83l7.29 6.88a1 1 0 0 0 1.42 0L20 8.83V18H4z"/></svg>
                            </span>
                            <input type="email" name="mail" placeholder="Entrer votre email" required />
                        </span>
                    </label>

                    <!-- Promotion (visible seulement pour non-enseignants) -->
                    <label class="field" id="promotion-field">
                        <span class="label">Promotion (assignée automatiquement)</span>
                        <span class="input-wrap">
                            <span class="icon" aria-hidden="true">
                                <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M12 2a10 10 0 1 0 10 10A10 10 0 0 0 12 2zm1 17.93V20h-2v-.07A8.12 8.12 0 0 1 4.07 13H4v-2h.07A8.12 8.12 0 0 1 11 4.07V4h2v.07A8.12 8.12 0 0 1 19.93 11H20v2h-.07A8.12 8.12 0 0 1 13 19.93z"/></svg>
                            </span>
                            <input type="text" name="promotion_display" id="promotion-display" placeholder="Sera assignée automatiquement" readonly style="background: #f5f5f5; cursor: not-allowed;" />
                            <input type="hidden" name="promotion" id="promotion-hidden" />
                        </span>
                    </label>

                    <input type="hidden" name="loginuser" id="loginuser-hidden" />

                    <label class="field">
                        <span class="label">Mot de passe <span style="color: red;">*</span></span>
                        <span class="input-wrap">
                            <span class="icon" aria-hidden="true">
                                <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M17 10h-1V7a4 4 0 0 0-8 0v3H7a2 2 0 0 0-2 2v7a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-7a2 2 0 0 0-2-2zm-6 0V7a3 3 0 0 1 6 0v3z"/></svg>
                            </span>
                            <input type="password" name="pwduser" placeholder="Entrer votre mot de passe" required />
                        </span>
                    </label>

                    <label class="field">
                        <span class="label">Confirmer mot de passe <span style="color: red;">*</span></span>
                        <span class="input-wrap">
                            <span class="icon" aria-hidden="true">
                                <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M17 10h-1V7a4 4 0 0 0-8 0v3H7a2 2 0 0 0-2 2v7a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-7a2 2 0 0 0-2-2zm-6 0V7a3 3 0 0 1 6 0v3z"/></svg>
                            </span>
                            <input type="password" name="confirmPwd" placeholder="Confirmer votre mot de passe" required />
                        </span>
                    </label>

                    <label class="field">
                        <span class="label">Téléphone</span>
                        <span class="input-wrap">
                            <span class="icon" aria-hidden="true">
                                <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M6.62 10.79a15.05 15.05 0 0 0 6.59 6.59l2.2-2.2a1 1 0 0 1 1-.24 11.36 11.36 0 0 0 3.58.57 1 1 0 0 1 1 1V20a1 1 0 0 1-1 1A17 17 0 0 1 3 4a1 1 0 0 1 1-1h3.5a1 1 0 0 1 1 1 11.36 11.36 0 0 0 .57 3.58 1 1 0 0 1-.24 1z"/></svg>
                            </span>
                            <input type="tel" name="teluser" placeholder="Entrer votre numéro de téléphone" />
                        </span>
                    </label>

                    <label class="field">
                        <span class="label">Adresse</span>
                        <span class="input-wrap">
                            <span class="icon" aria-hidden="true">
                                <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M12 2a7 7 0 0 0-7 7c0 5.25 7 13 7 13s7-7.75 7-13a7 7 0 0 0-7-7zm0 9.5A2.5 2.5 0 1 1 14.5 9 2.5 2.5 0 0 1 12 11.5z"/></svg>
                            </span>
                            <input type="text" name="adruser" placeholder="Entrer votre adresse" />
                        </span>
                    </label>

                    <label class="field">
                        <span class="label">Photo de profil</span>
                        <span class="input-wrap">
                            <span class="icon" aria-hidden="true">
                                <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor"><path d="M21 19V5c0-1.1-.9-2-2-2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2zM8.5 13.5l2.5 3.01L14.5 12l4.5 6H5l3.5-4.5z"/></svg>
                            </span>
                            <input type="file" name="photo" accept="image/*" style="padding: 5px 8px;" />
                        </span>
                    </label>

                    <button class="btn-primary" type="submit">
                        S'inscrire
                    </button>
                </form>

                <p class="register-link">
                    <a href="../index.jsp">Déjà un compte ? Se connecter</a>
                </p>
            </main>

            <footer class="footer">
            </footer>
        </section>

        <aside class="panel-right" aria-hidden="true">
            <div class="image">
            </div>
        </aside>
    </div>
</div>

<script>
// Charger la liste des enseignants depuis le JSON
let enseignantsData = [];

// Charger les enseignants au chargement
window.addEventListener('DOMContentLoaded', function() {
    fetch('${pageContext.request.contextPath}/pages/api/enseignants-api.jsp')
        .then(response => response.json())
        .then(data => {
            enseignantsData = data;
            // Remplir la datalist avec les codes et noms
            const datalist = document.getElementById('enseignants-list');
            datalist.innerHTML = '';
            data.forEach(ens => {
                const option = document.createElement('option');
                option.value = ens.code;
                option.textContent = ens.code + ' - ' + ens.nom + ' ' + ens.prenom;
                datalist.appendChild(option);
            });
        })
        .catch(err => console.error('Erreur chargement enseignants:', err));
    
    // Initialisation
    toggleIdentificationFields();
    setupLoginUserSync();
});

function toggleIdentificationFields() {
    const typeSelect = document.getElementById('idtypeutilisateur-select').value;
    const etuField = document.getElementById('etu-field');
    const profField = document.getElementById('prof-field');
    const promotionField = document.getElementById('promotion-field');
    const alertText = document.getElementById('alert-text');
    
    // TU0000003 est enseignant
    if (typeSelect === 'TU0000003') {
        // Afficher Code Enseignant, cacher ETU et promotion
        etuField.style.display = 'none';
        profField.style.display = '';
        promotionField.style.display = 'none';
        alertText.textContent = 'Votre code enseignant sera votre identifiant de connexion.';
        document.getElementById('prof-code-input').required = true;
        document.getElementById('etu-input').required = false;
    } else {
        // Afficher ETU et promotion, cacher Code Enseignant
        etuField.style.display = '';
        profField.style.display = 'none';
        promotionField.style.display = '';
        alertText.textContent = 'Votre numéro étudiant (ETU) sera votre identifiant de connexion.';
        document.getElementById('prof-code-input').required = false;
        document.getElementById('etu-input').required = true;
    }
}

function setupLoginUserSync() {
    // Sync ETU vers loginuser
    const etuInput = document.getElementById('etu-input');
    const profInput = document.getElementById('prof-code-input');
    const loginusernHidden = document.getElementById('loginuser-hidden');
    
    etuInput.addEventListener('input', function() {
        loginusernHidden.value = this.value;
    });
    
    profInput.addEventListener('input', function() {
        loginusernHidden.value = this.value;
    });
    
    // Validation avant soumission
    document.querySelector('form.form').addEventListener('submit', function(e) {
        const typeSelect = document.getElementById('idtypeutilisateur-select').value;
        
        if (typeSelect === 'TU0000003') {
            // Enseignant - vérifier code
            const profCode = profInput.value.trim();
            if (!profCode) {
                e.preventDefault();
                alert('Le code enseignant est obligatoire.');
                return;
            }
            // Vérifier si le code existe dans la liste
            const exists = enseignantsData.some(ens => ens.code === profCode);
            if (!exists) {
                e.preventDefault();
                alert('Code enseignant invalide. Veuillez sélectionner parmi la liste.');
                return;
            }
            loginusernHidden.value = profCode;
        } else {
            // Étudiant/Alumni - vérifier ETU
            const etu = etuInput.value.trim();
            if (etu) {
                loginusernHidden.value = etu;
            } else {
                e.preventDefault();
                alert('Le numéro étudiant (ETU) est obligatoire.');
                return;
            }
        }
    });
}

// Ajouter écouteur pour le changement de type d'utilisateur
document.getElementById('idtypeutilisateur-select').addEventListener('change', toggleIdentificationFields);
</script>

</body>
</html>