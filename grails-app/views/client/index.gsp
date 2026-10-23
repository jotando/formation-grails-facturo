<html>
<head>
    <meta name="layout" content="main"/>
    <title><g:message code="client.liste.titre"/></title>
</head>
<body>
<div class="d-flex justify-content-between align-items-center mb-3">
    <h1><g:message code="client.liste.titre"/></h1>
    <g:link class="btn btn-primary" action="create"><g:message code="client.nouveau"/></g:link>
</div>
<g:if test="${clients}">
    <table class="table table-sm">
        <thead><tr><th>Code</th><th>Raison sociale</th><th>E-mail</th><th class="text-right">Remise</th></tr></thead>
        <tbody>
        <g:each in="${clients}" var="c">
            <tr>
                <td><g:link action="show" id="${c.id}">${c.code}</g:link></td>
                <td>${c.raisonSociale}</td>
                <td>${c.email}</td>
                <td class="text-right"><g:formatNumber number="${c.tauxRemise}" format="0.00"/> %</td>
            </tr>
        </g:each>
        </tbody>
    </table>
</g:if>
<g:else><p><g:message code="client.liste.vide"/></p></g:else>
</body>
</html>
