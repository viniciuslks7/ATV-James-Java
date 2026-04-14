# Atividade Avaliativa - Java (Professor James)

Projeto Spring Boot para gerenciamento de **Produtos** e **Categorias**, com foco em boas praticas de API REST, DTOs, validacao, paginacao e documentacao OpenAPI/Swagger.

## Objetivo da atividade

Implementar e validar a expansao da API de catalogo com a entidade **Categoria**, incluindo:

- Model, Repository, Service e Controller
- DTOs com Java Records
- Query Method com busca por nome (ignore case) + paginacao
- Swagger documentado para teste dos endpoints

## Funcionalidades implementadas

- CRUD de produtos
- Cadastro e listagem de categorias
- Busca de categorias por nome: `GET /api/categorias?nome=...`
- Paginacao e ordenacao por nome
- Validacao de payload com Bean Validation
- Respostas padronizadas com `ApiResponse`

## Tecnologias

- Java 17
- Spring Boot 3.5.x
- Spring Web
- Spring Data JPA
- Spring Validation
- Springdoc OpenAPI (Swagger UI)
- H2 Database
- PostgreSQL 16
- Maven

## Banco de dados e perfis

O projeto suporta os dois bancos:

- **H2 (padrao)**: perfil `h2`
- **PostgreSQL**: perfil `postgres`

Configuracao PostgreSQL (aula):

- Host: `localhost`
- Porta: `5433`
- Banco: `bancojames`
- Usuario: `postgres`
- Senha padrao: `123456` (ou via `POSTGRES_PASSWORD`)

## Seed automatico

Existe o arquivo `src/main/resources/data.sql` com carga inicial automatica.

## Como executar

### 1. Rodar com H2 (padrao)

```bash
./mvnw spring-boot:run
```

### 2. Rodar com PostgreSQL

```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=postgres
```

## Swagger

- UI: `http://localhost:8080/swagger-ui/index.html`
- OpenAPI JSON: `http://localhost:8080/v3/api-docs`

## Evidencias da atividade

A pasta `evidencias/` contem:

- prints de cadastro e listagem no Swagger
- print de confirmacao no banco PostgreSQL
- PDF consolidado para entrega

## Testes

```bash
./mvnw test
```

## Autor

**Vinicius Oliveira**  
Disciplina de Java - Professor James
