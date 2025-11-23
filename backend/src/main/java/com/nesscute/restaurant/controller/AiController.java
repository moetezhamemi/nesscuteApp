package com.nesscute.restaurant.controller;

import com.nesscute.restaurant.dto.AiQueryRequest;
import com.nesscute.restaurant.dto.AiQueryResponse;
import com.nesscute.restaurant.service.AiService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/ai")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AiController {

    private final AiService aiService;

    @PostMapping("/query")
    @PreAuthorize("hasAnyRole('CLIENT', 'ADMIN')")
    public ResponseEntity<AiQueryResponse> processQuery(@RequestBody AiQueryRequest request) {
        return ResponseEntity.ok(aiService.processQuery(request));
    }
}

