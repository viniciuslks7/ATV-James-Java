INSERT INTO categorias (nome)
SELECT 'Eletrônicos'
WHERE NOT EXISTS (
    SELECT 1 FROM categorias WHERE LOWER(nome) = LOWER('Eletrônicos')
);

INSERT INTO categorias (nome)
SELECT 'Alimentos'
WHERE NOT EXISTS (
    SELECT 1 FROM categorias WHERE LOWER(nome) = LOWER('Alimentos')
);

INSERT INTO categorias (nome)
SELECT 'Vestuário'
WHERE NOT EXISTS (
    SELECT 1 FROM categorias WHERE LOWER(nome) = LOWER('Vestuário')
);

INSERT INTO produto (nome, preco)
SELECT 'Notebook', 4599.90
WHERE NOT EXISTS (
    SELECT 1 FROM produto WHERE LOWER(nome) = LOWER('Notebook')
);

INSERT INTO produto (nome, preco)
SELECT 'Arroz 5Kg', 27.50
WHERE NOT EXISTS (
    SELECT 1 FROM produto WHERE LOWER(nome) = LOWER('Arroz 5Kg')
);

INSERT INTO produto (nome, preco)
SELECT 'Camiseta Básica', 49.90
WHERE NOT EXISTS (
    SELECT 1 FROM produto WHERE LOWER(nome) = LOWER('Camiseta Básica')
);
