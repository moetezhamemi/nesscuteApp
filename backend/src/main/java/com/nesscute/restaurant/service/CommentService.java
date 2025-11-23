package com.nesscute.restaurant.service;

import com.nesscute.restaurant.dto.CommentDto;
import com.nesscute.restaurant.entity.Article;
import com.nesscute.restaurant.entity.Comment;
import com.nesscute.restaurant.entity.User;
import com.nesscute.restaurant.repository.ArticleRepository;
import com.nesscute.restaurant.repository.CommentRepository;
import com.nesscute.restaurant.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CommentService {

    private final CommentRepository commentRepository;
    private final ArticleRepository articleRepository;
    private final UserRepository userRepository;

    @Transactional
    public CommentDto addComment(Long articleId, Long userId, String content) {
        Article article = articleRepository.findById(articleId)
                .orElseThrow(() -> new RuntimeException("Article not found"));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Comment comment = Comment.builder()
                .article(article)
                .user(user)
                .content(content)
                .build();

        comment = commentRepository.save(comment);

        return CommentDto.builder()
                .id(comment.getId())
                .content(comment.getContent())
                .userName(comment.getUser().getName())
                .userId(comment.getUser().getId())
                .createdAt(comment.getCreatedAt())
                .build();
    }

    public List<CommentDto> getCommentsByArticleId(Long articleId) {
        return commentRepository.findByArticleIdOrderByCreatedAtDesc(articleId)
                .stream()
                .map(comment -> CommentDto.builder()
                        .id(comment.getId())
                        .content(comment.getContent())
                        .userName(comment.getUser().getName())
                        .userId(comment.getUser().getId())
                        .createdAt(comment.getCreatedAt())
                        .build())
                .collect(Collectors.toList());
    }
}

