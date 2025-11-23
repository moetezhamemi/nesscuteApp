package com.nesscute.restaurant.dto;

import lombok.Data;

@Data
public class AiQueryRequest {
    private String question;
    private String userRole;
}

