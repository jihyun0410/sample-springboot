package com.example.demo;

import com.example.demo.model.Order;
import com.example.demo.service.OrderService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * @SpringBootTest 예제 테스트.
 *
 * [@SpringBootTest 가 하는 일]
 * - 테스트를 실행하기 전에 "진짜 스프링 애플리케이션 컨텍스트"를 통째로 띄운다.
 * - 어떤 설정을 쓸지는 현재 패키지(com.example.demo)에서 위로 올라가며
 *   @SpringBootConfiguration(= @SpringBootApplication) 이 붙은 클래스를 자동으로 찾는다.
 *   → 여기서는 DemoApplication 을 찾아서 그 설정으로 컨텍스트를 만든다.
 *   (그래서 테스트 패키지를 main 과 똑같이 맞추는 게 중요하다.)
 * - 컨텍스트가 뜨면 @Service, @RestController 같은 빈이 전부 등록되므로
 *   @Autowired 로 실제 빈을 주입받아 쓸 수 있다.
 *
 * [단위 테스트와 뭐가 다른가]
 * - new OrderService() 로 직접 만들어 테스트하면 = 단위 테스트 (빠름, 스프링 없음).
 * - @SpringBootTest 는 = 통합 테스트. 스프링이 빈을 제대로 만들고 주입하는지까지 검증한다.
 *   느린 대신 "설정이 실제로 동작하는가"를 확인할 수 있다.
 *
 * [webEnvironment 옵션 - 참고]
 * - 기본값은 MOCK: 서블릿 컨테이너를 실제 포트로 띄우지 않는다. (지금 이 테스트)
 * - 컨트롤러를 HTTP 로 직접 호출해보고 싶으면
 *   @SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT) + TestRestTemplate 을 쓴다.
 */
@SpringBootTest
class OrderServiceTest {

    /**
     * 스프링 컨텍스트에 등록된 OrderService 빈을 주입받는다.
     * OrderService 에 @Service 가 붙어 있어서 컴포넌트 스캔으로 자동 등록된 상태다.
     * (주입이 실패하면 테스트는 아예 시작조차 못 하고 깨진다 → 설정 검증 효과)
     */
    @Autowired
    private OrderService orderService;

    @Test
    @DisplayName("수량 10개 이하면 할인 없이 수량 x 단가")
    void totalWithoutDiscount() {
        // given: 3개 x 10.0원
        Order order = new Order("A1", 3, 10.0);

        // when & then: 30.0 (할인 조건 미달)
        assertEquals(30.0, orderService.calculateTotal(order));
    }

    @Test
    @DisplayName("수량이 10개를 초과하면 10% 할인이 적용된다")
    void totalWithBulkDiscount() {
        // given: 11개 x 10.0원 = 110.0원
        Order order = new Order("A2", 11, 10.0);

        // when & then: 110.0 * 0.9 = 99.0
        // double 비교라 오차가 생길 수 있어 허용 오차(delta)를 준다.
        assertEquals(99.0, orderService.calculateTotal(order), 0.0001);
    }

    @Test
    @DisplayName("경계값: 딱 10개는 아직 할인 대상이 아니다 (> 10 조건)")
    void totalAtBoundary() {
        // 할인 조건이 quantity > 10 이므로 10개는 할인 없음.
        // 경계값은 부등호 실수(>= vs >)가 가장 잘 나는 지점이라 꼭 테스트한다.
        Order order = new Order("A3", 10, 10.0);

        assertEquals(100.0, orderService.calculateTotal(order));
    }
}
