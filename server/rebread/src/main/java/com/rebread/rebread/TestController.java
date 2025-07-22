package com.rebread.rebread;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.GetMapping;


@RestController
public class TestController {
    @GetMapping("/test")
    public String hello() {
        return "<h1>Hello</h1>";
    }
    
}
