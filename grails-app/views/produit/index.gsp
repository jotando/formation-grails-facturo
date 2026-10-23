<html>
<head>
    <meta name="layout" content="main"/>
    <title>Produits</title>
</head>
<body>
<h1>Produits</h1>
<table class="table table-sm">
    <thead><tr><th>Référence</th><th>Libellé</th><th class="text-right">Prix HT</th><th class="text-right">TVA</th><th class="text-right">Stock</th></tr></thead>
    <tbody>
    <g:each in="${produits}" var="p">
        <tr class="${p.stock == 0 ? 'table-warning' : ''}">
            <td>${p.reference}</td>
            <td>${p.libelle}</td>
            <td class="text-right"><fac:montant valeur="${p.prixUnitaireHt}"/></td>
            <td class="text-right"><g:formatNumber number="${p.tauxTva}" format="0.0"/> %</td>
            <td class="text-right">${p.stock}</td>
        </tr>
    </g:each>
    </tbody>
</table>
</body>
</html>
