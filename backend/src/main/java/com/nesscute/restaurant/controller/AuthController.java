package com.nesscute.restaurant.controller;

import com.nesscute.restaurant.dto.AuthRequest;
import com.nesscute.restaurant.dto.AuthResponse;
import com.nesscute.restaurant.dto.RegisterRequest;
import com.nesscute.restaurant.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody AuthRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PostMapping("/google")
    public ResponseEntity<AuthResponse> googleLogin(@RequestBody GoogleLoginRequest request) {
        return ResponseEntity.ok(authService.googleLogin(
                request.getGoogleId(),
                request.getEmail(),
                request.getName(),
                request.getProfileImage()
        ));
    }

    // Classe interne pour la requête Google
    private static class GoogleLoginRequest {
        private String googleId;
        private String email;
        private String name;
        private String profileImage;

        public String getGoogleId() { return googleId; }
        public String getEmail() { return email; }
        public String getName() { return name; }
        public String getProfileImage() { return profileImage; }
    }
}

