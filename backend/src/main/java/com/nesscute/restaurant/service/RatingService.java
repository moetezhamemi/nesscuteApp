package com.nesscute.restaurant.service;

import com.nesscute.restaurant.entity.Article;
import com.nesscute.restaurant.entity.Rating;
import com.nesscute.restaurant.entity.User;
import com.nesscute.restaurant.repository.ArticleRepository;
import com.nesscute.restaurant.repository.RatingRepository;
import com.nesscute.restaurant.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class RatingService {

    private final RatingRepository ratingRepository;
    private final ArticleRepository articleRepository;
    private final UserRepository userRepository;

    @Transactional
    public Rating addOrUpdateRating(Long articleId, Long userId, Integer ratingValue) {
        if (ratingValue < 1 || ratingValue > 5) {
            throw new RuntimeException("Rating must be between 1 and 5");
        }

        Article article = articleRepository.findById(articleId)
                .orElseThrow(() -> new RuntimeException("Article not found"));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Rating rating = ratingRepository.findByArticleIdAndUserId(articleId, userId)
                .orElse(Rating.builder()
                        .article(article)
                        .user(user)
                        .value(ratingValue)
                        .build());

        rating.setValue(ratingValue);
        rating = ratingRepository.save(rating);

        // Recalculate global rating
        Double averageRating = ratingRepository.calculateAverageRating(articleId);
        Long ratingCount = ratingRepository.countByArticleId(articleId);

        article.setGlobalRating(averageRating != null ? averageRating : 0.0);
        article.setRatingCount(ratingCount != null ? ratingCount.intValue() : 0);
        articleRepository.save(article);

        return rating;
    }

    public Rating getUserRating(Long articleId, Long userId) {
        return ratingRepository.findByArticleIdAndUserId(articleId, userId)
                .orElse(null);
    }
}
