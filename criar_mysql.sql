-- ================================================================
-- BASE ÚNICA DE ANÁLISE (MySQL)
-- 4 setores em 1 database, separados por prefixo nas tabelas
-- 
-- USO: Importar no phpMyAdmin (dentro do database "analise_dados")
-- ================================================================

-- Se ainda não criou o database, descomente a linha abaixo (só funciona em localhost):
-- CREATE DATABASE IF NOT EXISTS analise_dados CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- USE analise_dados;

-- ================================================================
-- 💰 SETOR 1: CRÉDITO / MICROCREDITO
-- ================================================================

CREATE TABLE credito_clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150),
    cpf VARCHAR(14),
    idade INT,
    genero VARCHAR(20),
    estabelecimento VARCHAR(150)
) ENGINE=InnoDB;

CREATE TABLE credito_usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100),
    comissao DECIMAL(5,2),
    custo_fixo DECIMAL(10,2)
) ENGINE=InnoDB;

CREATE TABLE credito_contratos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idcliente INT,
    idusuario INT,
    dtinicio DATE,
    dtfim DATE,
    valor DECIMAL(12,2),
    valor_parcelado DECIMAL(12,2),
    qtd_parcela INT,
    status VARCHAR(20),
    FOREIGN KEY (idcliente) REFERENCES credito_clientes(id),
    FOREIGN KEY (idusuario) REFERENCES credito_usuarios(id)
) ENGINE=InnoDB;

CREATE TABLE credito_movimentacoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idcontrato INT,
    dtvenc DATE,
    dtrecebimento DATE,
    valorrecebido DECIMAL(12,2),
    areceber DECIMAL(12,2),
    desconto DECIMAL(10,2),
    status VARCHAR(20),
    FOREIGN KEY (idcontrato) REFERENCES credito_contratos(id)
) ENGINE=InnoDB;

-- Popular agentes de cobrança
INSERT INTO credito_usuarios (nome, comissao, custo_fixo) VALUES
('Carlos', 6.00, 1500.00), ('Julio', 6.00, 1500.00),
('Marcelo', 6.00, 1500.00), ('Renato', 6.00, 1500.00),
('Leonardo', 6.00, 1500.00), ('Fernanda', 6.00, 1500.00),
('Kelly', 6.00, 1500.00), ('MVP', 6.00, 1500.00);

-- Popular clientes de crédito
INSERT INTO credito_clientes (nome, cpf, idade, genero, estabelecimento) VALUES
('João Silva', '123.456.789-00', 35, 'Masculino', 'Padaria'),
('Maria Santos', '987.654.321-00', 28, 'Feminino', 'Restaurante'),
('Carlos Oliveira', '456.789.123-00', 42, 'Masculino', 'Bar'),
('Ana Costa', '321.654.987-00', 31, 'Feminino', 'Salão'),
('Pedro Souza', '654.321.987-00', 45, 'Masculino', 'Oficina');

-- Popular contratos
INSERT INTO credito_contratos (idcliente, idusuario, dtinicio, dtfim, valor, valor_parcelado, qtd_parcela, status) VALUES
(1, 1, '2025-08-01', '2025-10-30', 2000.00, 2138.00, 90, 'Vigente'),
(2, 2, '2025-09-15', '2025-11-14', 1500.00, 1569.00, 60, 'Vigente'),
(3, 3, '2025-07-01', '2025-09-29', 3000.00, 3207.00, 90, 'Vigente');

-- Popular movimentações
INSERT INTO credito_movimentacoes (idcontrato, dtvenc, dtrecebimento, valorrecebido, areceber, desconto, status) VALUES
(1, '2025-08-01', '2025-08-01', 23.76, 23.76, 0, 'Pago'),
(1, '2025-08-02', '2025-08-03', 23.76, 23.76, 0, 'Pago'),
(1, '2025-08-03', NULL, 0, 23.76, 0, 'Aberto');

-- ================================================================
-- 🎬 SETOR 2: STREAMING
-- ================================================================

CREATE TABLE streaming_usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150),
    email VARCHAR(150),
    plano VARCHAR(30),
    dt_cadastro DATE,
    status VARCHAR(20)
) ENGINE=InnoDB;

CREATE TABLE streaming_titulos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(200),
    tipo VARCHAR(30),
    genero VARCHAR(50),
    duracao_min INT,
    dt_lancamento DATE,
    classificacao VARCHAR(10)
) ENGINE=InnoDB;

CREATE TABLE streaming_assistencias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idusuario INT,
    idtitulo INT,
    dt_assistido DATE,
    minutos_assistidos INT,
    dispositivo VARCHAR(30),
    FOREIGN KEY (idusuario) REFERENCES streaming_usuarios(id),
    FOREIGN KEY (idtitulo) REFERENCES streaming_titulos(id)
) ENGINE=InnoDB;

CREATE TABLE streaming_avaliacoes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idusuario INT,
    idtitulo INT,
    nota INT,
    dt_avaliacao DATE,
    FOREIGN KEY (idusuario) REFERENCES streaming_usuarios(id),
    FOREIGN KEY (idtitulo) REFERENCES streaming_titulos(id)
) ENGINE=InnoDB;

INSERT INTO streaming_usuarios (nome, email, plano, dt_cadastro, status) VALUES
('João Silva', 'joao@email.com', 'Premium', '2024-05-15', 'Ativo'),
('Maria Santos', 'maria@email.com', 'Padrao', '2024-08-20', 'Ativo'),
('Carlos Oliveira', 'carlos@email.com', 'Basico', '2025-01-10', 'Cancelado');

INSERT INTO streaming_titulos (titulo, tipo, genero, duracao_min, dt_lancamento, classificacao) VALUES
('Ação Máxima', 'Filme', 'Ação', 120, '2023-06-15', '14'),
('Comédia Total', 'Filme', 'Comédia', 95, '2024-02-20', '12'),
('Drama Profundo', 'Série', 'Drama', 45, '2025-03-10', '16');

INSERT INTO streaming_assistencias (idusuario, idtitulo, dt_assistido, minutos_assistidos, dispositivo) VALUES
(1, 1, '2026-08-15', 120, 'Smart TV'),
(2, 2, '2026-08-16', 95, 'Celular'),
(1, 3, '2026-08-17', 45, 'Notebook');

INSERT INTO streaming_avaliacoes (idusuario, idtitulo, nota, dt_avaliacao) VALUES
(1, 1, 5, '2026-08-15'),
(2, 2, 4, '2026-08-16'),
(3, 3, 3, '2026-08-17');

-- ================================================================
-- 🛒 SETOR 3: E-COMMERCE
-- ================================================================

CREATE TABLE ecommerce_clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150),
    email VARCHAR(150),
    cpf VARCHAR(14),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    dt_cadastro DATE
) ENGINE=InnoDB;

CREATE TABLE ecommerce_produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(200),
    categoria VARCHAR(50),
    preco_custo DECIMAL(10,2),
    preco_venda DECIMAL(10,2),
    estoque INT
) ENGINE=InnoDB;

CREATE TABLE ecommerce_pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idcliente INT,
    dt_pedido DATE,
    status VARCHAR(20),
    frete DECIMAL(8,2),
    desconto DECIMAL(8,2),
    FOREIGN KEY (idcliente) REFERENCES ecommerce_clientes(id)
) ENGINE=InnoDB;

CREATE TABLE ecommerce_itens_pedido (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idpedido INT,
    idproduto INT,
    quantidade INT,
    preco_unitario DECIMAL(10,2),
    FOREIGN KEY (idpedido) REFERENCES ecommerce_pedidos(id),
    FOREIGN KEY (idproduto) REFERENCES ecommerce_produtos(id)
) ENGINE=InnoDB;

CREATE TABLE ecommerce_pagamentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idpedido INT,
    forma VARCHAR(30),
    valor DECIMAL(10,2),
    dt_pagamento DATE,
    status VARCHAR(20),
    FOREIGN KEY (idpedido) REFERENCES ecommerce_pedidos(id)
) ENGINE=InnoDB;

INSERT INTO ecommerce_clientes (nome, email, cpf, cidade, estado, dt_cadastro) VALUES
('João Silva', 'joao@email.com', '123.456.789-00', 'São Paulo', 'SP', '2024-03-15'),
('Maria Santos', 'maria@email.com', '987.654.321-00', 'Rio de Janeiro', 'RJ', '2024-06-20'),
('Carlos Oliveira', 'carlos@email.com', '456.789.123-00', 'Belo Horizonte', 'MG', '2025-01-10');

INSERT INTO ecommerce_produtos (nome, categoria, preco_custo, preco_venda, estoque) VALUES
('Smartphone XYZ', 'Eletrônicos', 800.00, 1299.90, 50),
('Camiseta Básica', 'Roupas', 15.00, 49.90, 200),
('Panela de Pressão', 'Casa', 35.00, 89.90, 100);

INSERT INTO ecommerce_pedidos (idcliente, dt_pedido, status, frete, desconto) VALUES
(1, '2026-08-15', 'Entregue', 15.90, 0),
(2, '2026-08-16', 'Enviado', 22.50, 10.00),
(3, '2026-08-17', 'Processando', 18.00, 0);

INSERT INTO ecommerce_itens_pedido (idpedido, idproduto, quantidade, preco_unitario) VALUES
(1, 1, 1, 1299.90),
(2, 2, 3, 49.90),
(3, 3, 1, 89.90);

INSERT INTO ecommerce_pagamentos (idpedido, forma, valor, dt_pagamento, status) VALUES
(1, 'Cartão Crédito', 1315.80, '2026-08-15', 'Aprovado'),
(2, 'Pix', 162.20, '2026-08-16', 'Aprovado'),
(3, 'Boleto', 107.90, NULL, 'Pendente');

-- ================================================================
-- 📊 SETOR 4: SaaS / ASSINATURAS
-- ================================================================

CREATE TABLE saas_clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150),
    empresa VARCHAR(150),
    segmento VARCHAR(50),
    tamanho VARCHAR(20),
    dt_cadastro DATE
) ENGINE=InnoDB;

CREATE TABLE saas_planos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50),
    preco_mensal DECIMAL(10,2),
    limite_usuarios INT,
    recursos TEXT
) ENGINE=InnoDB;

CREATE TABLE saas_assinaturas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idcliente INT,
    idplano INT,
    dt_inicio DATE,
    dt_fim DATE,
    status VARCHAR(20),
    valor_mensal DECIMAL(10,2),
    FOREIGN KEY (idcliente) REFERENCES saas_clientes(id),
    FOREIGN KEY (idplano) REFERENCES saas_planos(id)
) ENGINE=InnoDB;

CREATE TABLE saas_faturas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idassinatura INT,
    dt_vencimento DATE,
    dt_pagamento DATE,
    valor DECIMAL(10,2),
    status VARCHAR(20),
    FOREIGN KEY (idassinatura) REFERENCES saas_assinaturas(id)
) ENGINE=InnoDB;

CREATE TABLE saas_usos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idassinatura INT,
    dt_uso DATE,
    metrica VARCHAR(50),
    valor INT,
    FOREIGN KEY (idassinatura) REFERENCES saas_assinaturas(id)
) ENGINE=InnoDB;

INSERT INTO saas_clientes (nome, empresa, segmento, tamanho, dt_cadastro) VALUES
('João Silva', 'Tech Solutions', 'Tecnologia', 'Pequena', '2024-01-15'),
('Maria Santos', 'Varejo Plus', 'Varejo', 'Média', '2024-03-20'),
('Carlos Oliveira', 'Indústria Beta', 'Indústria', 'Grande', '2024-06-10');

INSERT INTO saas_planos (nome, preco_mensal, limite_usuarios, recursos) VALUES
('Starter', 49.90, 5, 'Básico'),
('Professional', 149.90, 25, 'Intermediário'),
('Business', 399.90, 100, 'Avançado'),
('Enterprise', 999.90, 9999, 'Completo');

INSERT INTO saas_assinaturas (idcliente, idplano, dt_inicio, dt_fim, status, valor_mensal) VALUES
(1, 3, '2024-01-15', NULL, 'Ativa', 399.90),
(2, 2, '2024-03-20', NULL, 'Ativa', 149.90),
(3, 4, '2024-06-10', '2025-06-10', 'Cancelada', 999.90);

INSERT INTO saas_faturas (idassinatura, dt_vencimento, dt_pagamento, valor, status) VALUES
(1, '2026-08-15', '2026-08-14', 399.90, 'Paga'),
(2, '2026-08-20', '2026-08-20', 149.90, 'Paga'),
(3, '2025-06-10', NULL, 999.90, 'Atrasada');

INSERT INTO saas_usos (idassinatura, dt_uso, metrica, valor) VALUES
(1, '2026-08-15', 'logins', 45),
(1, '2026-08-15', 'api_calls', 120),
(2, '2026-08-16', 'logins', 12),
(2, '2026-08-16', 'relatorios_gerados', 8);

-- ================================================================
-- ✅ VERIFICAÇÃO FINAL
-- ================================================================
SELECT '✅ Base única criada com 18 tabelas (4 setores × prefixos)' AS status;