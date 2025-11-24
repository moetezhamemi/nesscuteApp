package com.nesscute.restaurant.controller;

import com.nesscute.restaurant.entity.Rating;
import com.nesscute.restaurant.service.RatingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/articles/{articleId}/rating")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class RatingController {

    private final RatingService ratingService;

    @PostMapping
    @PreAuthorize("hasAnyRole('CLIENT', 'ADMIN')")
    public ResponseEntity<Map<String, Object>> addOrUpdateRating(
            @PathVariable Long articleId,
            @RequestParam Long userId,
            @RequestParam Integer rating) {
        Rating savedRating = ratingService.addOrUpdateRating(articleId, userId, rating);
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("rating", savedRating.getValue());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/user/{userId}")
    @PreAuthorize("hasAnyRole('CLIENT', 'ADMIN')")
    public ResponseEntity<Map<String, Object>> getUserRating(
            @PathVariable Long articleId,
            @PathVariable Long userId) {
        Rating rating = ratingService.getUserRating(articleId, userId);
        Map<String, Object> response = new HashMap<>();
        if (rating != null) {
            response.put("rating", rating.getValue());
        } else {
            response.put("rating", 0);
        }
        return ResponseEntity.ok(response);
    }
}
