<!doctype html>
<html lang="fr">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <title>Facturo · <g:layoutTitle default="Facturation"/></title>
    <asset:link rel="icon" href="favicon.ico" type="image/x-ico"/>
    <asset:stylesheet src="application.css"/>
    <g:layoutHead/>
</head>
<body>
<nav class="navbar navbar-expand navbar-dark bg-dark">
    <g:link class="navbar-brand" uri="/">Facturo</g:link>
    <ul class="navbar-nav mr-auto">
        <li class="nav-item"><g:link class="nav-link" controller="client">Clients</g:link></li>
        <li class="nav-item"><g:link class="nav-link" controller="produit">Produits</g:link></li>
        <li class="nav-item"><g:link class="nav-link" controller="facture" action="recherche">Factures</g:link></li>
        <%-- Exercices : ajouter ici Fournisseurs (ex01), Commandes (ex03), Audit (ex07), Tableau de bord (ex08) --%>
        <g:pageProperty name="page.nav"/>
    </ul>
</nav>

<main class="container py-4">
    <g:if test="${flash.message}">
        <div class="alert alert-success" role="status">${flash.message}</div>
    </g:if>
    <g:if test="${flash.erreur}">
        <div class="alert alert-danger" role="alert">${flash.erreur}</div>
    </g:if>
    <g:layoutBody/>
</main>

<asset:javascript src="application.js"/>
</body>
</html>
