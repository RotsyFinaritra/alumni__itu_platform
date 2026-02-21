<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<style>
    .alumni-welcome { padding: 30px; }
    .alumni-welcome h1 { font-size: 28px; font-weight: 700; color: #333; margin-bottom: 10px; }
    .alumni-welcome p.subtitle { font-size: 16px; color: #666; margin-bottom: 30px; }
    .alumni-cards { display: flex; flex-wrap: wrap; gap: 20px; }
    .alumni-card {
        flex: 1 1 280px; max-width: 350px;
        background: #fff; border-radius: 8px; padding: 25px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1); transition: transform 0.2s;
        text-decoration: none; color: inherit; display: block;
    }
    .alumni-card:hover { transform: translateY(-4px); box-shadow: 0 4px 16px rgba(0,0,0,0.15); text-decoration: none; color: inherit; }
    .alumni-card i.card-icon { font-size: 36px; color: var(--Background-primaire, #3c8dbc); margin-bottom: 15px; display: block; }
    .alumni-card h3 { font-size: 18px; font-weight: 600; margin-bottom: 8px; }
    .alumni-card p { font-size: 14px; color: #777; margin: 0; }
</style>

<div class="content-wrapper alumni-welcome">
    <div class="row m-0">
        <div class="col-md-12">
            <h1>Bienvenue sur Alumni ITU</h1>
            <p class="subtitle">Plateforme de mise en r&eacute;seau des anciens et nouveaux &eacute;tudiants de l'ITU.</p>
        </div>
        <div class="col-md-12 alumni-cards">
            <!-- Exemple de cartes - a personnaliser selon vos modules -->
            <div class="alumni-card">
                <i class="fa fa-users card-icon"></i>
                <h3>Annuaire Alumni</h3>
                <p>Retrouvez les anciens et nouveaux &eacute;tudiants de l'ITU.</p>
            </div>
            <div class="alumni-card">
                <i class="fa fa-calendar card-icon"></i>
                <h3>&Eacute;v&eacute;nements</h3>
                <p>D&eacute;couvrez les &eacute;v&eacute;nements et rencontres organis&eacute;s par la communaut&eacute;.</p>
            </div>
            <div class="alumni-card">
                <i class="fa fa-briefcase card-icon"></i>
                <h3>Offres d'emploi</h3>
                <p>Consultez les opportunit&eacute;s partag&eacute;es par le r&eacute;seau alumni.</p>
            </div>
        </div>
    </div>
</div>
