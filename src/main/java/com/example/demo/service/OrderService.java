package com.example.demo.service;

import com.example.demo.model.Order;
import org.springframework.stereotype.Service;

@Service
public class OrderService {

    /**
     * Calculates the total price for an order.
     * Now applies a 10% bulk discount when quantity exceeds 10.
     */
    public double calculateTotal(Order order) {
        double subtotal = order.getQuantity() * order.getUnitPrice();
        if (order.getQuantity() > 10) {
            return subtotal * 0.9;
        }
        return subtotal;
    }
}
