<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-graduation-cap"></i> Publier une offre de stage</h1>
        <ol class="breadcrumb">
            <li><a href="<%=lien%>?but=carriere/carriere-accueil.jsp"><i class="fa fa-home"></i> Espace Carriere</a></li>
            <li class="active">Publier stage</li>
        </ol>
    </section>
    <section class="content">
        <form action="<%=lien%>?but=apresCarriere.jsp" method="post">

            <!-- Section : Description -->
            <div class="box box-primary">
                <div class="box-header with-border">
                    <h3 class="box-title"><i class="fa fa-pencil"></i> Description du stage</h3>
                </div>
                <div class="box-body">
                    <div class="form-group">
                        <label>Description du stage *</label>
                        <textarea name="contenu" class="form-control" rows="6" required></textarea>
                    </div>
                    <div class="form-group">
                        <label>Visibilite</label>
                        <select name="idvisibilite" class="form-control">
                            <option value="VIS00001">Public</option>
                            <option value="VIS00002">Membres uniquement</option>
                            <option value="VIS00003">Prive</option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- Section : Details stage -->
            <div class="box box-success">
                <div class="box-header with-border">
                    <h3 class="box-title"><i class="fa fa-graduation-cap"></i> Details du stage</h3>
                </div>
                <div class="box-body">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Entreprise / Organisme *</label>
                                <input type="text" name="entreprise" class="form-control" required>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Localisation</label>
                                <input type="text" name="localisation" class="form-control">
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4">
                            <div class="form-group">
                                <label>Duree (ex: 3 mois)</label>
                                <input type="text" name="duree" class="form-control">
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <label>Date de debut</label>
                                <input type="date" name="date_debut" class="form-control">
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <label>Date de fin</label>
                                <input type="date" name="date_fin" class="form-control">
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4">
                            <div class="form-group">
                                <label>Indemnite mensuelle</label>
                                <input type="number" step="0.01" name="indemnite" class="form-control">
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <label>Nombre de places</label>
                                <input type="number" name="places_disponibles" class="form-control" value="1">
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <label>Convention requise</label>
                                <select name="convention_requise" class="form-control">
                                    <option value="0">Non</option>
                                    <option value="1">Oui</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Niveau d'etude requis</label>
                                <input type="text" name="niveau_etude_requis" class="form-control" placeholder="ex: Bac+3">
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Competences requises</label>
                        <textarea name="competences_requises" class="form-control" rows="3"></textarea>
                    </div>
                    <div class="row">
                        <div class="col-md-4">
                            <div class="form-group">
                                <label>Email de contact</label>
                                <input type="email" name="contact_email" class="form-control">
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <label>Telephone</label>
                                <input type="text" name="contact_tel" class="form-control">
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <label>Lien de candidature</label>
                                <input type="url" name="lien_candidature" class="form-control">
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Champs caches -->
            <input type="hidden" name="acte" value="insertStage" />
            <input type="hidden" name="bute" value="carriere/stage-liste.jsp" />

            <!-- Boutons -->
            <div class="box">
                <div class="box-footer">
                    <button type="submit" class="btn btn-success">
                        <i class="fa fa-check"></i> Publier le stage
                    </button>
                    <a href="<%=lien%>?but=carriere/stage-liste.jsp" class="btn btn-default" style="margin-left:10px">
                        <i class="fa fa-times"></i> Annuler
                    </a>
                </div>
            </div>
        </form>
    </section>
</div>
<%
    } catch (Exception e) {
        e.printStackTrace();
        String msgErr = (e.getMessage() != null) ? e.getMessage() : "Erreur inconnue";
%>
<script>alert('Erreur : <%=msgErr.replace("'", "\\'")%>'); history.back();</script>
<%
    }
%>
