<html>
<head>
    <meta name="layout" content="main"/>
    <title><g:message code="facture.nouvelle"/></title>
</head>
<body>
<h1><g:message code="facture.nouvelle"/></h1>
<g:form action="save" class="form-inline">
    <g:select class="form-control mr-2" name="clientId" from="${clients}" optionKey="id" optionValue="raisonSociale" value="${params.clientId}"/>
    <g:submitButton class="btn btn-primary" name="creer" value="${message(code: 'bouton.creer')}"/>
</g:form>
</body>
</html>
