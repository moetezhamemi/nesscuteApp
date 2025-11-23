package com.nesscute.restaurant.service;

import com.nesscute.restaurant.dto.OrderDto;
import com.nesscute.restaurant.dto.OrderItemDto;
import com.nesscute.restaurant.entity.*;
import com.nesscute.restaurant.entity.Order.OrderStatus;
import com.nesscute.restaurant.entity.Order.OrderType;
import com.nesscute.restaurant.repository.ArticleRepository;
import com.nesscute.restaurant.repository.OrderRepository;
import com.nesscute.restaurant.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final ArticleRepository articleRepository;

    public List<OrderDto> getAllOrders() {
        return orderRepository.findAll().stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    public List<OrderDto> getOrdersByUserId(Long userId) {
        return orderRepository.findByUserIdOrderByCreatedAtDesc(userId).stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    public List<OrderDto> getOrdersByStatus(OrderStatus status) {
        return orderRepository.findByStatusOrderByCreatedAtDesc(status).stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    public OrderDto getOrderById(Long id) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        return mapToDto(order);
    }

    @Transactional
    public OrderDto createOrder(OrderDto orderDto) {
        User user = userRepository.findById(orderDto.getUserId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        Order order = Order.builder()
                .user(user)
                .status(OrderStatus.EN_ATTENTE)
                .type(orderDto.getType())
                .deliveryAddress(orderDto.getDeliveryAddress())
                .latitude(orderDto.getLatitude())
                .longitude(orderDto.getLongitude())
                .build();

        double totalPrice = 0.0;
        for (OrderItemDto itemDto : orderDto.getItems()) {
            Article article = articleRepository.findById(itemDto.getArticleId())
                    .orElseThrow(() -> new RuntimeException("Article not found"));

            OrderItem item = OrderItem.builder()
                    .order(order)
                    .article(article)
                    .quantity(itemDto.getQuantity())
                    .unitPrice(article.getPrice())
                    .build();

            order.getItems().add(item);
            totalPrice += item.getUnitPrice() * item.getQuantity();
        }

        order.setTotalPrice(totalPrice);
        order = orderRepository.save(order);

        return mapToDto(order);
    }

    @Transactional
    public OrderDto updateOrderStatus(Long id, OrderStatus status) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Order not found"));

        order.setStatus(status);
        order = orderRepository.save(order);

        return mapToDto(order);
    }

    @Transactional
    public void deleteOrder(Long id) {
        if (!orderRepository.existsById(id)) {
            throw new RuntimeException("Order not found");
        }
        orderRepository.deleteById(id);
    }

    private OrderDto mapToDto(Order order) {
        List<OrderItemDto> items = order.getItems().stream()
                .map(item -> OrderItemDto.builder()
                        .id(item.getId())
                        .articleId(item.getArticle().getId())
                        .articleName(item.getArticle().getName())
                        .quantity(item.getQuantity())
                        .unitPrice(item.getUnitPrice())
                        .build())
                .collect(Collectors.toList());

        return OrderDto.builder()
                .id(order.getId())
                .userId(order.getUser().getId())
                .userName(order.getUser().getName())
                .status(order.getStatus())
                .type(order.getType())
                .totalPrice(order.getTotalPrice())
                .deliveryAddress(order.getDeliveryAddress())
                .latitude(order.getLatitude())
                .longitude(order.getLongitude())
                .createdAt(order.getCreatedAt())
                .updatedAt(order.getUpdatedAt())
                .items(items)
                .build();
    }
}

