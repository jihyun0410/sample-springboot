package com.example.demo.model;

/**
 * 주문 데이터를 담는 단순 값 객체(DTO).
 * 필드가 final 이라 한 번 만들면 값이 바뀌지 않는다(불변).
 *
 * 참고: JSON → 객체 변환(@RequestBody)은 Jackson 이 이 생성자를 통해 처리한다.
 *       (Spring Boot 3 + Java 17 환경에서는 파라미터 이름 정보로 매핑됨)
 */
public class Order {

    private final String id;
    private final int quantity;
    private final double unitPrice;

    public Order(String id, int quantity, double unitPrice) {
        this.id = id;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
    }

    public String getId() {
        return id;
    }

    public int getQuantity() {
        return quantity;
    }

    public double getUnitPrice() {
        return unitPrice;
    }
}
