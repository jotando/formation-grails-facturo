<%-- Template partagé par create.gsp et edit.gsp : <g:render template="form" model="[client: client]"/> --%>
<g:hasErrors bean="${client}">
    <ul class="alert alert-danger errors" role="alert">
        <g:eachError bean="${client}" var="err"><li><g:message error="${err}"/></li></g:eachError>
    </ul>
</g:hasErrors>
<div class="form-group">
    <label for="code">Code</label>
    <g:textField class="form-control ${hasErrors(bean: client, field: 'code', 'is-invalid')}" name="code" value="${client?.code}"/>
</div>
<div class="form-group">
    <label for="raisonSociale">Raison sociale</label>
    <g:textField class="form-control ${hasErrors(bean: client, field: 'raisonSociale', 'is-invalid')}" name="raisonSociale" value="${client?.raisonSociale}"/>
</div>
<div class="form-group">
    <label for="email">E-mail</label>
    <g:field type="email" class="form-control ${hasErrors(bean: client, field: 'email', 'is-invalid')}" name="email" value="${client?.email}"/>
</div>
<div class="form-group">
    <label for="tauxRemise">Remise (%)</label>
    <g:field type="number" step="0.01" class="form-control ${hasErrors(bean: client, field: 'tauxRemise', 'is-invalid')}" name="tauxRemise" value="${client?.tauxRemise}"/>
</div>
<div class="form-check mb-3">
    <g:checkBox class="form-check-input" name="actif" value="${client?.actif}"/>
    <label class="form-check-label" for="actif">Actif</label>
</div>
