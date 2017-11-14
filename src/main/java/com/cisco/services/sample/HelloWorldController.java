package com.cisco.services.sample;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloWorldController {

	@GetMapping(value = "/")
	@ResponseBody
	@ResponseStatus(value = HttpStatus.OK)
	public String sayHello() {
		return "Hello! Welcome to the training!\n";
	}

}
