package com.example.demo.service;

import com.example.demo.model.Order;
import org.springframework.stereotype.Service;

@Service
public class OrderService {

    /**
     * Calculates the total price for an order (baseline behavior).
     */
    public double calculateTotal(Order order) {
        return order.getQuantity() * order.getUnitPrice();
    }
}
