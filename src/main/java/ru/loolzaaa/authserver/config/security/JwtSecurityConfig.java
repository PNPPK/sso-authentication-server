package ru.loolzaaa.authserver.config.security;

import lombok.RequiredArgsConstructor;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.csrf.CookieCsrfTokenRepository;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import ru.loolzaaa.authserver.config.security.bean.*;
import ru.loolzaaa.authserver.config.security.filter.ExternalLogoutFilter;
import ru.loolzaaa.authserver.config.security.filter.JwtTokenFilter;
import ru.loolzaaa.authserver.config.security.filter.LoginAccessFilter;
import ru.loolzaaa.authserver.config.security.property.SsoServerProperties;
import ru.loolzaaa.authserver.model.UserPrincipal;
import ru.loolzaaa.authserver.services.CookieService;
import ru.loolzaaa.authserver.services.JWTService;
import ru.loolzaaa.authserver.services.SecurityContextService;

@RequiredArgsConstructor
@EnableMethodSecurity
@EnableConfigurationProperties(SsoServerProperties.class)
@Configuration
public class JwtSecurityConfig {

    private static final Logger log = LogManager.getLogger(JwtSecurityConfig.class.getName());

    private final SsoServerProperties ssoServerProperties;

    @Qualifier("jwtPasswordEncoder")
    private final PasswordEncoder passwordEncoder;

    @Qualifier("jwtUserDetailsService")
    private final UserDetailsService userDetailsService;

    private final JwtAuthenticationSuccessHandler jwtAuthenticationSuccessHandler;
    private final JwtAuthenticationFailureHandler jwtAuthenticationFailureHandler;
    private final JwtLogoutHandler jwtLogoutHandler;

    private final IgnoredPathsHandler ignoredPathsHandler;

    private final JWTService jwtService;
    private final CookieService cookieService;
    private final SecurityContextService securityContextService;

    @Bean
    AuthenticationProvider authenticationProvider() {
        CustomDaoAuthenticationProvider authenticationProvider = new CustomDaoAuthenticationProvider();
        authenticationProvider.setPasswordEncoder(passwordEncoder);
        authenticationProvider.setUserDetailsService(userDetailsService);
        return authenticationProvider;
    }

    @Bean
    public SecurityFilterChain jwtFilterChain(HttpSecurity http) throws Exception {
        // Set current application name from properties for request authorizing
        UserPrincipal.setApplicationName(ssoServerProperties.getApplication().getName());

        http
                .csrf(csrf -> csrf
                        .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
                        .ignoringRequestMatchers(new AntPathRequestMatcher("/api/refresh/ajax", "POST")))
                .cors()
                .and()
                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(authorize -> authorize
                        .antMatchers("/admin").hasRole("ADMIN")
                        .antMatchers(ssoServerProperties.getLoginPage()).permitAll()
                        .antMatchers(ignoredPathsHandler.toAntPatterns()).permitAll()
                        .anyRequest().hasAuthority(ssoServerProperties.getApplication().getName()))
                .formLogin(formLogin -> formLogin
                        .loginPage(ssoServerProperties.getLoginPage())
                        .loginProcessingUrl("/do_login")
                        .failureHandler(jwtAuthenticationFailureHandler)
                        .successHandler(jwtAuthenticationSuccessHandler)
                        .permitAll())
                .logout(logout -> logout
                        .logoutRequestMatcher(new AntPathRequestMatcher("/do_logout", "POST"))
                        .logoutSuccessUrl(ssoServerProperties.getLoginPage() + "?successLogout")
                        .addLogoutHandler(jwtLogoutHandler)
                        .deleteCookies("JSESSIONID", CookieName.ACCESS.getName(), CookieName.REFRESH.getName(), CookieName.RFID.getName())
                        .invalidateHttpSession(true)
                        .clearAuthentication(true)
                        .permitAll())
                .httpBasic().disable()
                .anonymous().disable()
                // Filters order is important!
                .addFilterBefore(new ExternalLogoutFilter(securityContextService, jwtService), UsernamePasswordAuthenticationFilter.class)
                .addFilterBefore(new JwtTokenFilter(ssoServerProperties, ignoredPathsHandler,
                        securityContextService, jwtService, cookieService), UsernamePasswordAuthenticationFilter.class)
                .addFilterAfter(new LoginAccessFilter(ssoServerProperties, cookieService), UsernamePasswordAuthenticationFilter.class);
        log.debug("Jwt [all API except Basic authentication] configuration completed");
        return http.build();
    }
}
