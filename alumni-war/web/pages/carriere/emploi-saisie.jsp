<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-suitcase"></i> Publier une offre d'emploi</h1>
        <ol class="breadcrumb">
            <li><a href="<%=lien%>?but=carriere/carriere-accueil.jsp"><i class="fa fa-home"></i> Espace Carriere</a></li>
            <li class="active">Publier emploi</li>
        </ol>
    </section>
    <section class="content">
        <form action="<%=lien%>?but=apresCarriere.jsp" method="post">

            <!-- Section : Description -->
            <div class="box box-primary">
                <div class="box-header with-border">
                    <h3 class="box-title"><i class="fa fa-pencil"></i> Description de l'offre</h3>
                </div>
                <div class="box-body">
                    <div class="form-group">
                        <label>Description de l'offre *</label>
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

            <!-- Section : Details emploi -->
            <div class="box box-success">
                <div class="box-header with-border">
                    <h3 class="box-title"><i class="fa fa-suitcase"></i> Details de l'offre d'emploi</h3>
                </div>
                <div class="box-body">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Entreprise *</label>
                                <input type="text" name="entreprise" class="form-control" required>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Intitule du poste *</label>
                                <input type="text" name="poste" class="form-control" required>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Localisation</label>
                                <input type="text" name="localisation" class="form-control">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Type de contrat</label>
                                <select name="type_contrat" class="form-control">
                                    <option value="">-- Choisir --</option>
                                    <option value="CDI">CDI</option>
                                    <option value="CDD">CDD</option>
                                    <option value="Freelance">Freelance</option>
                                    <option value="Alternance">Alternance</option>
                                    <option value="Stage">Stage</option>
                                    <option value="Autre">Autre</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4">
                            <div class="form-group">
                                <label>Salaire minimum</label>
                                <input type="number" step="0.01" name="salaire_min" class="form-control">
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <label>Salaire maximum</label>
                                <input type="number" step="0.01" name="salaire_max" class="form-control">
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <label>Devise</label>
                                <input type="text" name="devise" class="form-control" value="MGA">
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Experience requise</label>
                                <input type="text" name="experience_requise" class="form-control" placeholder="ex: 2 ans">
                            </div>
                        </div>
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
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Teletravail possible</label>
                                <select name="teletravail_possible" class="form-control">
                                    <option value="0">Non</option>
                                    <option value="1">Oui</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label>Date limite candidature</label>
                                <input type="date" name="date_limite" class="form-control">
                            </div>
                        </div>
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
                                <label>Telephone de contact</label>
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
            <input type="hidden" name="acte" value="insertEmploi" />
            <input type="hidden" name="bute" value="carriere/emploi-liste.jsp" />

            <!-- Boutons -->
            <div class="box">
                <div class="box-footer">
                    <button type="submit" class="btn btn-primary">
                        <i class="fa fa-check"></i> Publier l'offre
                    </button>
                    <a href="<%=lien%>?but=carriere/emploi-liste.jsp" class="btn btn-default" style="margin-left:10px">
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
