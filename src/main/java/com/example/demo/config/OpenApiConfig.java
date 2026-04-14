package com.example.demo.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("API de Catálogo")
                        .version("v1")
                        .description("Documentação interativa da API de produtos e categorias")
                        .contact(new Contact().name("Suporte API").email("suporte@example.com")))
                .addServersItem(new Server().url("http://localhost:8080").description("Servidor local"));
    }
}
