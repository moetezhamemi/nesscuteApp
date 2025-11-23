package com.nesscute.restaurant.service;

import com.nesscute.restaurant.dto.ArticleDto;
import com.nesscute.restaurant.dto.CommentDto;
import com.nesscute.restaurant.entity.Article;
import com.nesscute.restaurant.entity.Article.ArticleType;
import com.nesscute.restaurant.repository.ArticleRepository;
import com.nesscute.restaurant.repository.CommentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ArticleService {

    private final ArticleRepository articleRepository;
    private final CommentRepository commentRepository;

    public List<ArticleDto> getAllArticles() {
        return articleRepository.findAll().stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    public ArticleDto getArticleById(Long id) {
        Article article = articleRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Article not found"));
        return mapToDto(article);
    }

    public List<ArticleDto> getArticlesByType(ArticleType type) {
        return articleRepository.findByType(type).stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    public List<ArticleDto> searchArticles(String keyword) {
        return articleRepository.searchArticles(keyword).stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    @Transactional
    public ArticleDto createArticle(ArticleDto articleDto) {
        Article article = Article.builder()
                .name(articleDto.getName())
                .description(articleDto.getDescription())
                .price(articleDto.getPrice())
                .type(articleDto.getType())
                .imageUrl(articleDto.getImageUrl())
                .globalRating(0.0)
                .ratingCount(0)
                .build();

        article = articleRepository.save(article);
        return mapToDto(article);
    }

    @Transactional
    public ArticleDto updateArticle(Long id, ArticleDto articleDto) {
        Article article = articleRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Article not found"));

        article.setName(articleDto.getName());
        article.setDescription(articleDto.getDescription());
        article.setPrice(articleDto.getPrice());
        article.setType(articleDto.getType());
        if (articleDto.getImageUrl() != null) {
            article.setImageUrl(articleDto.getImageUrl());
        }

        article = articleRepository.save(article);
        return mapToDto(article);
    }

    @Transactional
    public void deleteArticle(Long id) {
        if (!articleRepository.existsById(id)) {
            throw new RuntimeException("Article not found");
        }
        articleRepository.deleteById(id);
    }

    private ArticleDto mapToDto(Article article) {
        List<CommentDto> comments = commentRepository.findByArticleIdOrderByCreatedAtDesc(article.getId())
                .stream()
                .map(comment -> CommentDto.builder()
                        .id(comment.getId())
                        .content(comment.getContent())
                        .userName(comment.getUser().getName())
                        .userId(comment.getUser().getId())
                        .createdAt(comment.getCreatedAt())
                        .build())
                .collect(Collectors.toList());

        return ArticleDto.builder()
                .id(article.getId())
                .name(article.getName())
                .description(article.getDescription())
                .price(article.getPrice())
                .type(article.getType())
                .imageUrl(article.getImageUrl())
                .globalRating(article.getGlobalRating())
                .ratingCount(article.getRatingCount())
                .createdAt(article.getCreatedAt())
                .comments(comments)
                .build();
    }
}

