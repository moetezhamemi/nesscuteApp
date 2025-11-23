package com.nesscute.restaurant.dto;

import com.nesscute.restaurant.entity.Order.OrderStatus;
import com.nesscute.restaurant.entity.Order.OrderType;
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
public class OrderDto {
    private Long id;
    private Long userId;
    private String userName;
    private OrderStatus status;
    private OrderType type;
    private Double totalPrice;
    private String deliveryAddress;
    private Double latitude;
    private Double longitude;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private List<OrderItemDto> items;
}

