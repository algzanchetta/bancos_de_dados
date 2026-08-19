-- ================================================================
-- GERADOR COMPLETO DE BASES DE DADOS PARA ANÁLISE (MySQL)
-- Cria 4 databases: Crédito, Streaming, E-commerce, SaaS
-- 
-- USO: Importar diretamente no phpMyAdmin
-- ================================================================

-- ================================================================
-- BASE 1: CRÉDITO / MICROCREDITO
-- ================================================================

CREATE DATABASE IF NOT EXISTS credito_analise CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE credito_analise;

CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150),
    cpf VARCHAR(14),
    idade INT,
    genero VARCHAR(20),
    estabelecimento VARCHAR(150)
) ENGINE=InnoDB;

CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100),
    comissao DECIMAL(5,2),
    custo_fixo DECIMAL(10,2)
) ENGINE=InnoDB;

CREATE TABLE contratos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idcliente INT,
    idusuario INT,
    dtinicio DATE,
    dtfim DATE,
    valor DECIMAL(12,2),
    valor_parcelado DECIMAL(12,2),
    qtd_parcela INT,
    status VARCHAR(20),
    FOREIGN KEY (idcliente) REFERENCES clientes(id),
    FOREIGN KEY (idusuario) REFERENCES usuarios(id)
) ENGINE=InnoDB;

CREATE TABLE movimentacoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idcontrato INT,
    dtvenc DATE,
    dtrecebimento DATE,
    valorrecebido DECIMAL(12,2),
    areceber DECIMAL(12,2),
    desconto DECIMAL(10,2),
    status VARCHAR(20),
    FOREIGN KEY (idcontrato) REFERENCES contratos(id)
) ENGINE=InnoDB;

-- Popular agentes
INSERT INTO usuarios (nome, comissao, custo_fixo) VALUES
('Carlos', 6.00, 1500.00),
('Julio', 6.00, 1500.00),
('Marcelo', 6.00, 1500.00),
('Renato', 6.00, 1500.00),
('Leonardo', 6.00, 1500.00),
('Fernanda', 6.00, 1500.00),
('Kelly', 6.00, 1500.00),
('MVP', 6.00, 1500.00);

-- Popular clientes (exemplo - expanda conforme necessário)
INSERT INTO clientes (nome, cpf, idade, genero, estabelecimento) VALUES
('João Silva', '123.456.789-00', 35, 'Masculino', 'Padaria'),
('Maria Santos', '987.654.321-00', 28, 'Feminino', 'Restaurante'),
('Carlos Oliveira', '456.789.123-00', 42, 'Masculino', 'Bar'),
('Ana Costa', '321.654.987-00', 31, 'Feminino', 'Salão'),
('Pedro Souza', '654.321.987-00', 45, 'Masculino', 'Oficina');

-- Popular contratos (exemplo)
INSERT INTO contratos (idcliente, idusuario, dtinicio, dtfim, valor, valor_parcelado, qtd_parcela, status) VALUES
(1, 1, '2025-08-01', '2025-10-30', 2000.00, 2138.00, 90, 'Vigente'),
(2, 2, '2025-09-15', '2025-11-14', 1500.00, 1569.00, 60, 'Vigente'),
(3, 3, '2025-07-01', '2025-09-29', 3000.00, 3207.00, 90, 'Vigente');

-- Popular movimentações (exemplo)
INSERT INTO movimentacoes (idcontrato, dtvenc, dtrecebimento, valorrecebido, areceber, desconto, status) VALUES
(1, '2025-08-01', '2025-08-01', 23.76, 23.76, 0, 'Pago'),
(1, '2025-08-02', '2025-08-03', 23.76, 23.76, 0, 'Pago'),
(1, '2025-08-03', NULL, 0, 23.76, 0, 'Aberto');

-- ================================================================
-- BASE 2: STREAMING
-- ================================================================

CREATE DATABASE IF NOT EXISTS streaming_analise CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE streaming_analise;

CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150),
    email VARCHAR(150),
    plano VARCHAR(30),
    dt_cadastro DATE,
    status VARCHAR(20)
) ENGINE=InnoDB;

CREATE TABLE titulos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(200),
    tipo VARCHAR(30),
    genero VARCHAR(50),
    duracao_min INT,
    dt_lancamento DATE,
    classificacao VARCHAR(10)
) ENGINE=InnoDB;

CREATE TABLE assistencias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idusuario INT,
    idtitulo INT,
    dt_assistido DATE,
    minutos_assistidos INT,
    dispositivo VARCHAR(30),
    FOREIGN KEY (idusuario) REFERENCES usuarios(id),
    FOREIGN KEY (idtitulo) REFERENCES titulos(id)
) ENGINE=InnoDB;

CREATE TABLE avaliacoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idusuario INT,
    idtitulo INT,
    nota INT,
    dt_avaliacao DATE,
    FOREIGN KEY (idusuario) REFERENCES usuarios(id),
    FOREIGN KEY (idtitulo) REFERENCES titulos(id)
) ENGINE=InnoDB;

-- Popular usuários (exemplo)
INSERT INTO usuarios (nome, email, plano, dt_cadastro, status) VALUES
('João Silva', 'joao@email.com', 'Premium', '2024-05-15', 'Ativo'),
('Maria Santos', 'maria@email.com', 'Padrao', '2024-08-20', 'Ativo'),
('Carlos Oliveira', 'carlos@email.com', 'Basico', '2025-01-10', 'Cancelado');

-- Popular títulos (exemplo)
INSERT INTO titulos (titulo, tipo, genero, duracao_min, dt_lancamento, classificacao) VALUES
('Ação Máxima', 'Filme', 'Ação', 120, '2023-06-15', '14'),
('Comédia Total', 'Filme', 'Comédia', 95, '2024-02-20', '12'),
('Drama Profundo', 'Série', 'Drama', 45, '2025-03-10', '16');

-- Popular assistências (exemplo)
INSERT INTO assistencias (idusuario, idtitulo, dt_assistido, minutos_assistidos, dispositivo) VALUES
(1, 1, '2026-08-15', 120, 'Smart TV'),
(2, 2, '2026-08-16', 95, 'Celular'),
(1, 3, '2026-08-17', 45, 'Notebook');

-- Popular avaliações (exemplo)
INSERT INTO avaliacoes (idusuario, idtitulo, nota, dt_avaliacao) VALUES
(1, 1, 5, '2026-08-15'),
(2, 2, 4, '2026-08-16'),
(3, 3, 3, '2026-08-17');

-- ================================================================
-- BASE 3: E-COMMERCE
-- ================================================================

CREATE DATABASE IF NOT EXISTS ecommerce_analise CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ecommerce_analise;

CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150),
    email VARCHAR(150),
    cpf VARCHAR(14),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    dt_cadastro DATE
) ENGINE=InnoDB;

CREATE TABLE produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(200),
    categoria VARCHAR(50),
    preco_custo DECIMAL(10,2),
    preco_venda DECIMAL(10,2),
    estoque INT
) ENGINE=InnoDB;

CREATE TABLE pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idcliente INT,
    dt_pedido DATE,
    status VARCHAR(20),
    frete DECIMAL(8,2),
    desconto DECIMAL(8,2),
    FOREIGN KEY (idcliente) REFERENCES clientes(id)
) ENGINE=InnoDB;

CREATE TABLE itens_pedido (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idpedido INT,
    idproduto INT,
    quantidade INT,
    preco_unitario DECIMAL(10,2),
    FOREIGN KEY (idpedido) REFERENCES pedidos(id),
    FOREIGN KEY (idproduto) REFERENCES produtos(id)
) ENGINE=InnoDB;

CREATE TABLE pagamentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idpedido INT,
    forma VARCHAR(30),
    valor DECIMAL(10,2),
    dt_pagamento DATE,
    status VARCHAR(20),
    FOREIGN KEY (idpedido) REFERENCES pedidos(id)
) ENGINE=InnoDB;

-- Popular clientes (exemplo)
INSERT INTO clientes (nome, email, cpf, cidade, estado, dt_cadastro) VALUES
('João Silva', 'joao@email.com', '123.456.789-00', 'São Paulo', 'SP', '2024-03-15'),
('Maria Santos', 'maria@email.com', '987.654.321-00', 'Rio de Janeiro', 'RJ', '2024-06-20'),
('Carlos Oliveira', 'carlos@email.com', '456.789.123-00', 'Belo Horizonte', 'MG', '2025-01-10');

-- Popular produtos (exemplo)
INSERT INTO produtos (nome, categoria, preco_custo, preco_venda, estoque) VALUES
('Smartphone XYZ', 'Eletrônicos', 800.00, 1299.90, 50),
('Camiseta Básica', 'Roupas', 15.00, 49.90, 200),
('Panela de Pressão', 'Casa', 35.00, 89.90, 100);

-- Popular pedidos (exemplo)
INSERT INTO pedidos (idcliente, dt_pedido, status, frete, desconto) VALUES
(1, '2026-08-15', 'Entregue', 15.90, 0),
(2, '2026-08-16', 'Enviado', 22.50, 10.00),
(3, '2026-08-17', 'Processando', 18.00, 0);

-- Popular itens de pedido (exemplo)
INSERT INTO itens_pedido (idpedido, idproduto, quantidade, preco_unitario) VALUES
(1, 1, 1, 1299.90),
(2, 2, 3, 49.90),
(3, 3, 1, 89.90);

-- Popular pagamentos (exemplo)
INSERT INTO pagamentos (idpedido, forma, valor, dt_pagamento, status) VALUES
(1, 'Cartão Crédito', 1315.80, '2026-08-15', 'Aprovado'),
(2, 'Pix', 162.20, '2026-08-16', 'Aprovado'),
(3, 'Boleto', 107.90, NULL, 'Pendente');

-- ================================================================
-- BASE 4: SaaS / ASSINATURAS
-- ================================================================

CREATE DATABASE IF NOT EXISTS saas_analise CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE saas_analise;

CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150),
    empresa VARCHAR(150),
    segmento VARCHAR(50),
    tamanho VARCHAR(20),
    dt_cadastro DATE
) ENGINE=InnoDB;

CREATE TABLE planos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50),
    preco_mensal DECIMAL(10,2),
    limite_usuarios INT,
    recursos TEXT
) ENGINE=InnoDB;

CREATE TABLE assinaturas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idcliente INT,
    idplano INT,
    dt_inicio DATE,
    dt_fim DATE,
    status VARCHAR(20),
    valor_mensal DECIMAL(10,2),
    FOREIGN KEY (idcliente) REFERENCES clientes(id),
    FOREIGN KEY (idplano) REFERENCES planos(id)
) ENGINE=InnoDB;

CREATE TABLE faturas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idassinatura INT,
    dt_vencimento DATE,
    dt_pagamento DATE,
    valor DECIMAL(10,2),
    status VARCHAR(20),
    FOREIGN KEY (idassinatura) REFERENCES assinaturas(id)
) ENGINE=InnoDB;

CREATE TABLE usos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idassinatura INT,
    dt_uso DATE,
    metrica VARCHAR(50),
    valor INT,
    FOREIGN KEY (idassinatura) REFERENCES assinaturas(id)
) ENGINE=InnoDB;

-- Popular clientes (exemplo)
INSERT INTO clientes (nome, empresa, segmento, tamanho, dt_cadastro) VALUES
('João Silva', 'Tech Solutions', 'Tecnologia', 'Pequena', '2024-01-15'),
('Maria Santos', 'Varejo Plus', 'Varejo', 'Média', '2024-03-20'),
('Carlos Oliveira', 'Indústria Beta', 'Indústria', 'Grande', '2024-06-10');

-- Popular planos
INSERT INTO planos (nome, preco_mensal, limite_usuarios, recursos) VALUES
('Starter', 49.90, 5, 'Básico'),
('Professional', 149.90, 25, 'Intermediário'),
('Business', 399.90, 100, 'Avançado'),
('Enterprise', 999.90, 9999, 'Completo');

-- Popular assinaturas (exemplo)
INSERT INTO assinaturas (idcliente, idplano, dt_inicio, dt_fim, status, valor_mensal) VALUES
(1, 3, '2024-01-15', NULL, 'Ativa', 399.90),
(2, 2, '2024-03-20', NULL, 'Ativa', 149.90),
(3, 4, '2024-06-10', '2025-06-10', 'Cancelada', 999.90);

-- Popular faturas (exemplo)
INSERT INTO faturas (idassinatura, dt_vencimento, dt_pagamento, valor, status) VALUES
(1, '2026-08-15', '2026-08-14', 399.90, 'Paga'),
(2, '2026-08-20', '2026-08-20', 149.90, 'Paga'),
(3, '2025-06-10', NULL, 999.90, 'Atrasada');

-- Popular usos (exemplo)
INSERT INTO usos (idassinatura, dt_uso, metrica, valor) VALUES
(1, '2026-08-15', 'logins', 45),
(1, '2026-08-15', 'api_calls', 120),
(2, '2026-08-16', 'logins', 12),
(2, '2026-08-16', 'relatorios_gerados', 8);

-- ================================================================
-- FINALIZAÇÃO
-- ================================================================

SELECT '✅ TODAS AS BASES CRIADAS COM SUCESSO!' AS mensagem;
SELECT '• credito_analise (Crédito/Microcrédito)' AS base_1;
SELECT '• streaming_analise (Streaming/Entretenimento)' AS base_2;
SELECT '• ecommerce_analise (E-commerce/Vendas)' AS base_3;
SELECT '• saas_analise (SaaS/Assinaturas)' AS base_4;