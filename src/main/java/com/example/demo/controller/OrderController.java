package com.example.demo.controller;

import com.example.demo.model.Order;
import com.example.demo.service.OrderService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

/**
 * HTTP 요청을 받는 계층. 로직은 갖지 않고 Service 에 넘기기만 한다.
 *
 * @RestController = @Controller + @ResponseBody
 *  → 리턴값을 뷰 이름이 아니라 응답 본문(JSON)으로 그대로 내보낸다.
 */
@RestController
public class OrderController {

    private final OrderService orderService;

    /**
     * 생성자 주입(constructor injection).
     * 생성자가 하나뿐이면 @Autowired 를 생략해도 스프링이 알아서 OrderService 빈을 넣어준다.
     * 필드 주입(@Autowired 필드)보다 이 방식을 쓰는 이유: final 로 불변 보장 + 테스트에서 new 로 직접 주입 가능.
     */
    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    /**
     * POST /orders/total
     * 요청 본문 JSON 예: {"id":"A1","quantity":11,"unitPrice":10.0}
     *
     * @RequestBody : JSON 본문을 Jackson 이 Order 객체로 변환해준다.
     * 리턴한 double 은 그대로 응답 본문이 된다. (예: 99.0)
     */
    @PostMapping("/orders/total")
    public double total(@RequestBody Order order) {
        return orderService.calculateTotal(order);
    }
}
