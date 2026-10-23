import org.springframework.web.servlet.i18n.SessionLocaleResolver

// Interface en français par défaut, quel que soit le navigateur ; ?lang=en reste possible.
beans = {
    localeResolver(SessionLocaleResolver) {
        defaultLocale = Locale.FRANCE
    }
}
