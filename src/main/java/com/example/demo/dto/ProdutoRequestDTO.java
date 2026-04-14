package com.example.demo.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Schema(description = "Dados de entrada para criação/atualização de um produto")
@Data
public class ProdutoRequestDTO {

    @Schema(description = "Nome do produto", example = "Notebook Gamer")
    @NotBlank(message = "O nome não pode ser vazio")
    @Size(min = 3, max = 100, message = "O nome deve ter entre 3 e 100 caracteres")
    private String nome;

    @Schema(description = "Preço do produto", example = "4599.90")
    @NotNull(message = "O preço é obrigatório")
    @Positive(message = "O preço deve ser um valor positivo maior que zero")
    private Double preco;
}
