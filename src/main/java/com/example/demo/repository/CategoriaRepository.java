package com.example.demo.repository;

import com.example.demo.model.Categoria;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CategoriaRepository extends JpaRepository<Categoria, Long> {

    // Desafio de pesquisa: busca por nome ignorando maiúsculas/minúsculas, com paginação
    Page<Categoria> findByNomeContainingIgnoreCase(String nome, Pageable pageable);
}
