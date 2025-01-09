package com.example.depwatch;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class Main {
    public static void main(String[] args) {
        System.setProperty("server.port", "9090");
        SpringApplication.run(Main.class, args);
    }

    @GetMapping("/health")
    public String healthCheck() {
        return "Service is healthy!";
    }

    @GetMapping("/version")
    public String version() {
        return "1.0.0";
    }
}