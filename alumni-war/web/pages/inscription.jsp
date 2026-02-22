<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Inscription</title>
    <link href="${pageContext.request.contextPath}/assets/css/refontlogin.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/api-global-style.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/refontSidebar.css" rel="stylesheet">
</head>
<body>
<div class="page">
    <div class="frame">
        <section class="panel-left">
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
                %>

                <form class="form" action="testRegister.jsp" method="post">
                    <label class="field">
                        <span class="label">Nom</span>
                        <span class="input-wrap">
                            <input type="text" name="nomuser" placeholder="Entrer votre nom" required />
                        </span>
                    </label>

                    <label class="field">
                        <span class="label">Prénom</span>
                        <span class="input-wrap">
                            <input type="text" name="prenom" placeholder="Entrer votre prénom" required />
                        </span>
                    </label>

                    <label class="field">
                        <span class="label">Email</span>
                        <span class="input-wrap">
                            <input type="email" name="mail" placeholder="Entrer votre email" required />
                        </span>
                    </label>

                    <label class="field">
                        <span class="label">Numéro étudiant</span>
                        <span class="input-wrap">
                            <input type="text" name="etu" placeholder="Entrer votre numéro étudiant" />
                        </span>
                    </label>

                    <label class="field">
                        <span class="label">Nom d'utilisateur</span>
                        <span class="input-wrap">
                            <input type="text" name="loginuser" placeholder="Entrer votre nom d'utilisateur" required />
                        </span>
                    </label>

                    <label class="field">
                        <span class="label">Mot de passe</span>
                        <span class="input-wrap">
                            <input type="password" name="pwduser" placeholder="Entrer votre mot de passe" required />
                        </span>
                    </label>

                    <label class="field">
                        <span class="label">Confirmer mot de passe</span>
                        <span class="input-wrap">
                            <input type="password" name="confirmPwd" placeholder="Confirmer votre mot de passe" required />
                        </span>
                    </label>

                    <label class="field">
                        <span class="label">Téléphone</span>
                        <span class="input-wrap">
                            <input type="tel" name="teluser" placeholder="Entrer votre numéro de téléphone" />
                        </span>
                    </label>

                    <label class="field">
                        <span class="label">Adresse</span>
                        <span class="input-wrap">
                            <input type="text" name="adruser" placeholder="Entrer votre adresse" />
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
</body>
</html>