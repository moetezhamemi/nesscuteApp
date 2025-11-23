package com.nesscute.restaurant.repository;

import com.nesscute.restaurant.entity.Article;
import com.nesscute.restaurant.entity.Article.ArticleType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ArticleRepository extends JpaRepository<Article, Long> {
    List<Article> findByType(ArticleType type);
    
    @Query("SELECT a FROM Article a WHERE LOWER(a.name) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(a.description) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<Article> searchArticles(String keyword);
    
    List<Article> findByTypeOrderByGlobalRatingDesc(ArticleType type);
    
    List<Article> findByOrderByGlobalRatingDesc();
}

