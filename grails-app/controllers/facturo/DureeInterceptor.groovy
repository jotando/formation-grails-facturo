package facturo

/** Journalise la durée de chaque action. Enregistré automatiquement (nom en *Interceptor). */
class DureeInterceptor {

    DureeInterceptor() {
        matchAll()
    }

    boolean before() {
        request.setAttribute('facturo.t0', System.nanoTime())
        true
    }

    boolean after() { true }

    void afterView() {
        Long t0 = request.getAttribute('facturo.t0') as Long
        if (t0) {
            log.info "${controllerName}/${actionName ?: 'index'} : ${(System.nanoTime() - t0).intdiv(1_000_000)} ms"
        }
    }
}
