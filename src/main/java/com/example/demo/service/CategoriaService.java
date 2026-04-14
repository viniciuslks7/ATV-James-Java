package com.example.demo.service;

import com.example.demo.dto.CategoriaRequestDTO;
import com.example.demo.dto.CategoriaResponseDTO;
import com.example.demo.exception.CategoriaNotFoundException;
import com.example.demo.model.Categoria;
import com.example.demo.repository.CategoriaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class CategoriaService {

    private final CategoriaRepository categoriaRepository;

    public Page<CategoriaResponseDTO> listarPaginado(Pageable pageable) {
        return categoriaRepository.findAll(pageable)
                .map(CategoriaResponseDTO::new);
    }

    public Page<CategoriaResponseDTO> buscarPorNome(String nome, Pageable pageable) {
        return categoriaRepository.findByNomeContainingIgnoreCase(nome, pageable)
                .map(CategoriaResponseDTO::new);
    }

    public CategoriaResponseDTO salvar(CategoriaRequestDTO dto) {
        Categoria categoria = new Categoria();
        categoria.setNome(dto.nome());
        Categoria salva = categoriaRepository.save(categoria);
        return new CategoriaResponseDTO(salva);
    }

    public void excluir(Long id) {
        if (!categoriaRepository.existsById(id)) {
            throw new CategoriaNotFoundException(id);
        }
        categoriaRepository.deleteById(id);
    }
}
