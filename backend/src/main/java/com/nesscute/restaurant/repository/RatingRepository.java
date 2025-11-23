package com.nesscute.restaurant.repository;

import com.nesscute.restaurant.entity.Rating;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface RatingRepository extends JpaRepository<Rating, Long> {
    Optional<Rating> findByArticleIdAndUserId(Long articleId, Long userId);
    
    @Query("SELECT AVG(r.value) FROM Rating r WHERE r.article.id = :articleId")
    Double calculateAverageRating(@Param("articleId") Long articleId);
    
    @Query("SELECT COUNT(r) FROM Rating r WHERE r.article.id = :articleId")
    Long countByArticleId(@Param("articleId") Long articleId);
}

