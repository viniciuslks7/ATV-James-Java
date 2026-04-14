package com.example.demo.dto;

import com.example.demo.model.Produto;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Schema(description = "Dados de saída de um produto")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProdutoResponseDTO {

    @Schema(description = "ID do produto", example = "1")
    private Long id;
    @Schema(description = "Nome do produto", example = "Notebook Gamer")
    private String nome;
    @Schema(description = "Preço do produto", example = "4599.90")
    private Double preco;

    public ProdutoResponseDTO(Produto produto) {
        this.id = produto.getId();
        this.nome = produto.getNome();
        this.preco = produto.getPreco();
    }
}
