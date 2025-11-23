package com.nesscute.restaurant.controller;

import com.nesscute.restaurant.entity.Rating;
import com.nesscute.restaurant.service.RatingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/articles/{articleId}/rating")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class RatingController {

    private final RatingService ratingService;

    @PostMapping
    @PreAuthorize("hasAnyRole('CLIENT', 'ADMIN')")
    public ResponseEntity<Rating> addOrUpdateRating(
            @PathVariable Long articleId,
            @RequestParam Long userId,
            @RequestParam Integer rating) {
        return ResponseEntity.ok(ratingService.addOrUpdateRating(articleId, userId, rating));
    }
}

