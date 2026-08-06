package com.example.demo.service;

import com.example.demo.model.Order;
import org.springframework.stereotype.Service;

/**
 * 비즈니스 로직 계층.
 *
 * @Service 가 붙어 있어 컴포넌트 스캔 대상이 되고, 스프링 컨텍스트에 싱글턴 빈으로 등록된다.
 * → 그래서 테스트에서 @Autowired 로 주입받을 수 있다. (OrderServiceTest 참고)
 */
@Service
public class OrderService {

    /**
     * 주문 총액 계산.
     * 규칙: 총액 = 수량 x 단가, 단 수량이 10개를 "초과"하면 10% 할인.
     *
     * 주의: 10개는 할인 대상이 아니다(> 10). 경계값 테스트로 고정해 둠.
     */
    public double calculateTotal(Order order) {
        double subtotal = order.getQuantity() * order.getUnitPrice();
        if (order.getQuantity() > 10) {
            return subtotal * 0.9;
        }
        return subtotal;
    }
}
