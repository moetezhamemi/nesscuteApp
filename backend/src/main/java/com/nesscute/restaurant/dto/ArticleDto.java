package com.nesscute.restaurant.dto;

import com.nesscute.restaurant.entity.Article.ArticleType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ArticleDto {
    private Long id;
    private String name;
    private String description;
    private Double price;
    private ArticleType type;
    private String imageUrl;
    private Double globalRating;
    private Integer ratingCount;
    private LocalDateTime createdAt;
    private List<CommentDto> comments;
}

