package ru.loolzaaa.authserver.controllers;

import com.fasterxml.jackson.databind.JsonNode;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import ru.loolzaaa.authserver.dto.CreateUserRequestDTO;
import ru.loolzaaa.authserver.dto.RequestStatusDTO;
import ru.loolzaaa.authserver.exception.RequestErrorException;
import ru.loolzaaa.authserver.model.UserPrincipal;
import ru.loolzaaa.authserver.services.UserControlService;

import javax.validation.Valid;
import java.util.List;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api")
public class UserController {

    private static final GrantedAuthority adminGrantedAuthority = new SimpleGrantedAuthority("ROLE_ADMIN");

    private final UserControlService userControlService;

    @GetMapping(value = {"/user/{username}", "/fast/user/{username}"}, produces = "application/json")
    UserPrincipal getUserByUsername(@PathVariable("username") String username,
                                    @RequestParam(value = "app", required = false) String app) {
        return userControlService.getUserByUsername(username, app);
    }

    @GetMapping(value = {"/users", "/fast/users"}, produces = "application/json")
    List<UserPrincipal> getUsersByAuthority(@RequestParam(value = "app") String app,
                                            @RequestParam("authority") String authority) {
        return userControlService.getUsersByAuthority(app, authority);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping(value = "/user", consumes = "application/json", produces = "application/json")
    ResponseEntity<RequestStatusDTO> createUser(@RequestParam("app") String app,
                                                @Valid @RequestBody CreateUserRequestDTO user,
                                                BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            throw new RequestErrorException("Can't create DTO for new user");
        }
        RequestStatusDTO requestStatusDTO = userControlService.createUser(app, user);
        return ResponseEntity.status(requestStatusDTO.getStatusCode()).body(requestStatusDTO);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping(value = "/user/{username}", produces = "application/json")
    ResponseEntity<RequestStatusDTO> deleteUser(@PathVariable("username") String username,
                                                @RequestParam(name = "password", required = false) String password) {
        RequestStatusDTO requestStatusDTO = userControlService.deleteUser(username, password);
        return ResponseEntity.status(requestStatusDTO.getStatusCode()).body(requestStatusDTO);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PatchMapping(value = "/user/{username}/lock", produces = "application/json")
    ResponseEntity<RequestStatusDTO> changeUserLockStatus(@PathVariable("username") String username,
                                                          @RequestParam(value = "enabled", required = false) Boolean enabled,
                                                          @RequestParam(value = "lock", required = false) Boolean lock) {
        RequestStatusDTO requestStatusDTO = userControlService.changeUserLockStatus(username, enabled, lock);
        return ResponseEntity.status(requestStatusDTO.getStatusCode()).body(requestStatusDTO);
    }

    @PostMapping(value = "/user/{username}/password/change", produces = "application/json")
    ResponseEntity<RequestStatusDTO> changeUserPassword(@PathVariable("username") String username,
                                                        @RequestParam("oldPassword") String oldPassword,
                                                        @RequestParam("newPassword") String newPassword) {
        RequestStatusDTO requestStatusDTO = userControlService.changeUserPassword(username, oldPassword, newPassword);
        return ResponseEntity.status(requestStatusDTO.getStatusCode()).body(requestStatusDTO);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping(value = "/user/{username}/password/reset", produces = "application/json")
    ResponseEntity<RequestStatusDTO> resetUserPassword(@PathVariable("username") String username,
                                                       @RequestParam("newPassword") String newPassword) {
        RequestStatusDTO requestStatusDTO = userControlService.resetUserPassword(username, newPassword);
        return ResponseEntity.status(requestStatusDTO.getStatusCode()).body(requestStatusDTO);
    }

    @PatchMapping(value = {"/user/{username}/config/{app}", "/fast/user/{username}/config/{app}"},
            consumes = "application/json", produces = "application/json")
    ResponseEntity<RequestStatusDTO> changeUserConfig(@PathVariable("username") String username,
                                                      @PathVariable("app") String app,
                                                      @RequestBody JsonNode config,
                                                      BindingResult bindingResult) {
        if (bindingResult.hasErrors()) {
            throw new RequestErrorException("Can't create JsonNode for config");
        }
        RequestStatusDTO requestStatusDTO = userControlService.changeApplicationConfigForUser(username, app, config);
        return ResponseEntity.status(requestStatusDTO.getStatusCode()).body(requestStatusDTO);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping(value = "/user/{username}/config/{app}", produces = "application/json")
    ResponseEntity<RequestStatusDTO> deleteUserConfig(@PathVariable("username") String username, @PathVariable("app") String app) {
        RequestStatusDTO requestStatusDTO = userControlService.deleteApplicationConfigForUser(username, app);
        return ResponseEntity.status(requestStatusDTO.getStatusCode()).body(requestStatusDTO);
    }

    @PutMapping(value = "/user/temporary", produces = "application/json")
    ResponseEntity<RequestStatusDTO> createTemporaryUser(Authentication authentication,
                                                         @RequestParam("username") String username,
                                                         @RequestParam("dateFrom") long dateFrom,
                                                         @RequestParam("dateTo") long dateTo) {
        if (!isUserPermitToCreateTemporaryUser(authentication, username)) {
            throw new RequestErrorException("User can create temporary user only for himself");
        }
        RequestStatusDTO requestStatusDTO = userControlService.createTemporaryUser(username, dateFrom, dateTo);
        return ResponseEntity.status(requestStatusDTO.getStatusCode()).body(requestStatusDTO);
    }

    private boolean isUserPermitToCreateTemporaryUser(Authentication authentication, String username) {
        boolean isUserAdmin = authentication.getAuthorities().contains(adminGrantedAuthority);
        UserPrincipal userPrincipal = null;
        if (authentication.getPrincipal() instanceof UserPrincipal) {
            userPrincipal = (UserPrincipal) authentication.getPrincipal();
        }
        return isUserAdmin || (userPrincipal != null && userPrincipal.getUser().getLogin().equals(username));
    }
}
