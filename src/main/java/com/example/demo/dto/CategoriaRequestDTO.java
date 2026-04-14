package com.example.demo.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Schema(description = "Dados de entrada para criação ou atualização de uma categoria")
public record CategoriaRequestDTO(

        @Schema(description = "Nome da categoria", example = "Eletrônicos")
        @NotBlank(message = "O nome da categoria não pode ser vazio")
        @Size(min = 2, max = 100, message = "O nome deve ter entre 2 e 100 caracteres")
        String nome
) {}
