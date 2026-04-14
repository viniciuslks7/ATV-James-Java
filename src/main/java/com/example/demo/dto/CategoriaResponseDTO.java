package com.example.demo.dto;

import com.example.demo.model.Categoria;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Dados de saída de uma categoria")
public record CategoriaResponseDTO(

        @Schema(description = "ID único da categoria", example = "1")
        Long id,

        @Schema(description = "Nome da categoria", example = "Eletrônicos")
        String nome
) {
    // Construtor conveniente que converte a entidade para o DTO
    public CategoriaResponseDTO(Categoria categoria) {
        this(categoria.getId(), categoria.getNome());
    }
}
