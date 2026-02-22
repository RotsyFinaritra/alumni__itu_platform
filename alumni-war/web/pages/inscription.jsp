            // Vérification de la clé primaire
            System.out.println("DEBUG: refuser généré = " + utilisateur.getRefuser());
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@page import="bean.TypeObjet"%>
<%@page import="user.*"%>
<%@ page import="utilitaireAcade.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="lc.Direction" %>
<%@ page import="java.net.InetAddress" %>
<%@ page import="utilisateurAcade.UtilisateurAcade" %>
<%
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        // Handle registration
        String nomuser = request.getParameter("nomuser");
        String prenom = request.getParameter("prenom");
        String mail = request.getParameter("mail");
        String etu = request.getParameter("etu");
        String loginuser = request.getParameter("loginuser");
        String pwduser = request.getParameter("pwduser");
        String confirmPwd = request.getParameter("confirmPwd");
        String teluser = request.getParameter("teluser");
        String adruser = request.getParameter("adruser");

        if (!pwduser.equals(confirmPwd)) {
            session.setAttribute("errorInscription", "Les mots de passe ne correspondent pas.");
            response.sendRedirect("inscription.jsp");
            return;
        }

        try {
            // Encrypt password
            String encryptedPwd = UtilitaireAcade.cryptWord(pwduser, 5, 0);

            // Vérification des champs essentiels
            if(loginuser == null || loginuser.trim().isEmpty() ||
               encryptedPwd == null || encryptedPwd.trim().isEmpty() ||
               nomuser == null || nomuser.trim().isEmpty() ||
               prenom == null || prenom.trim().isEmpty() ||
               mail == null || mail.trim().isEmpty()) {
                session.setAttribute("errorInscription", "Tous les champs obligatoires doivent être renseignés.");
                response.sendRedirect("inscription.jsp");
                return;
            }

            // Log pour debug
            System.out.println("Inscription: loginuser=" + loginuser +
                   ", nomuser=" + nomuser +
                   ", prenom=" + prenom +
                   ", mail=" + mail +
                   ", etu=" + etu +
                   ", teluser=" + teluser +
                   ", adruser=" + adruser);


            UtilisateurAcade utilisateur = new UtilisateurAcade();
            utilisateur.setLoginuser(loginuser);
            utilisateur.setPwduser(encryptedPwd);
            utilisateur.setNomuser(nomuser);
            utilisateur.setPrenom(prenom);
            utilisateur.setMail(mail);
            utilisateur.setEtu(etu);
            utilisateur.setTeluser(teluser);
            utilisateur.setAdruser(adruser);
            utilisateur.setIdrole("alumni");
            utilisateur.setIdtypeutilisateur("TU0000001");

            // Générer la clé primaire
            try {
                utilisateur.construirePK(null);
            } catch (Exception pkEx) {
                pkEx.printStackTrace();
                session.setAttribute("errorInscription", "Erreur lors de la génération de la clé primaire utilisateur: " + pkEx.getMessage());
                response.sendRedirect("inscription.jsp");
                return;
            }

            // Get UserEJB
            UserEJB u = UserEJBClient.lookupUserEJBBeanLocal();

            // Create the user
            u.createObject(utilisateur);

            session.setAttribute("successInscription", "Inscription réussie. Vous pouvez maintenant vous connecter.");
            response.sendRedirect("../index.jsp");
            return;
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorInscription", "Erreur lors de l'inscription: " + e.getMessage());
            response.sendRedirect("inscription.jsp");
            return;
        }
    }
%>
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

                <form class="form" action="inscription.jsp" method="post">
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