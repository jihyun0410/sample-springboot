package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 애플리케이션 진입점.
 *
 * @SpringBootApplication 은 사실 아래 3개를 합친 것이다.
 *  - @SpringBootConfiguration : 이 클래스가 설정 클래스임을 표시 (@SpringBootTest 가 찾는 기준점)
 *  - @EnableAutoConfiguration : 클래스패스를 보고 필요한 설정을 자동 구성 (web 스타터 → 톰캣/MVC)
 *  - @ComponentScan           : 이 클래스가 있는 패키지(com.example.demo) 이하를 스캔해
 *                               @RestController, @Service 등을 빈으로 등록
 *
 * → 그래서 클래스 위치가 곧 스캔 범위다. 이 파일은 항상 최상위 패키지에 둔다.
 */
@SpringBootApplication
public class DemoApplication {

    public static void main(String[] args) {
        // 내장 톰캣 기동 + 스프링 컨텍스트 생성 + 컴포넌트 스캔까지 이 한 줄이 다 한다.
        SpringApplication.run(DemoApplication.class, args);
    }
}
