<?php
/**
 * BASE ÚNICA DE ANÁLISE (SQLite)
 * 4 setores em 1 arquivo .db, separados por prefixo nas tabelas
 * 
 * USO: php analise_dados.php
 */

echo "╔════════════════════════════════════════════════════════════╗\n";
echo "║  GERADOR DA BASE ÚNICA DE ANÁLISE                         ║\n";
echo "║  4 setores em 1 arquivo SQLite                            ║\n";
echo "╚════════════════════════════════════════════════════════════╝\n\n";

$db = new SQLite3('analise_dados.db');

// ============================================================================
// 💰 CRÉDITO
// ============================================================================
echo "💰 Criando tabelas de CRÉDITO...\n";

$db->exec("CREATE TABLE IF NOT EXISTS credito_clientes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT, cpf TEXT, idade INTEGER, genero TEXT, estabelecimento TEXT
)");

$db->exec("CREATE TABLE IF NOT EXISTS credito_usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT, comissao REAL, custo_fixo REAL
)");

$db->exec("CREATE TABLE IF NOT EXISTS credito_contratos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idcliente INTEGER, idusuario INTEGER,
    dtinicio TEXT, dtfim TEXT,
    valor REAL, valor_parcelado REAL, qtd_parcela INTEGER, status TEXT,
    FOREIGN KEY (idcliente) REFERENCES credito_clientes(id),
    FOREIGN KEY (idusuario) REFERENCES credito_usuarios(id)
)");

$db->exec("CREATE TABLE IF NOT EXISTS credito_movimentacoes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idcontrato INTEGER,
    dtvenc TEXT, dtrecebimento TEXT,
    valorrecebido REAL, areceber REAL, desconto REAL, status TEXT,
    FOREIGN KEY (idcontrato) REFERENCES credito_contratos(id)
)");

$agentes = [
    ['Carlos', 6.0, 1500.0], ['Julio', 6.0, 1500.0], ['Marcelo', 6.0, 1500.0],
    ['Renato', 6.0, 1500.0], ['Leonardo', 6.0, 1500.0], ['Fernanda', 6.0, 1500.0],
    ['Kelly', 6.0, 1500.0], ['MVP', 6.0, 1500.0]
];
foreach ($agentes as $ag) {
    $stmt = $db->prepare("INSERT INTO credito_usuarios (nome, comissao, custo_fixo) VALUES (:n, :c, :f)");
    $stmt->bindValue(':n', $ag[0]); $stmt->bindValue(':c', $ag[1]); $stmt->bindValue(':f', $ag[2]);
    $stmt->execute();
}

for ($i = 0; $i < 200; $i++) {
    $stmt = $db->prepare("INSERT INTO credito_clientes (nome, cpf, idade, genero, estabelecimento) VALUES (:n, :c, :i, :g, :e)");
    $stmt->bindValue(':n', "Cliente " . ($i+1));
    $stmt->bindValue(':c', str_pad(rand(0, 99999999999), 11, '0', STR_PAD_LEFT));
    $stmt->bindValue(':i', rand(18, 75));
    $stmt->bindValue(':g', rand(0,1) ? 'Masculino' : 'Feminino');
    $stmt->bindValue(':e', ['Padaria','Restaurante','Bar','Salão','Oficina','Loja','Mercado'][rand(0,6)]);
    $stmt->execute();
}

for ($i = 0; $i < 150; $i++) {
    $stmt = $db->prepare("INSERT INTO credito_contratos (idcliente, idusuario, dtinicio, dtfim, valor, valor_parcelado, qtd_parcela, status) VALUES (:c, :u, :di, :df, :v, :vp, :q, :s)");
    $qtd = [30,60,90][rand(0,2)];
    $valor = round(rand(500, 5000) + rand(0,99)/100, 2);
    $vp = round($valor * (1 + 0.023 * ($qtd/30)), 2);
    $stmt->bindValue(':c', rand(1,200));
    $stmt->bindValue(':u', rand(1,8));
    $stmt->bindValue(':di', date('Y-m-d', strtotime("-" . rand(0,365) . " days")));
    $stmt->bindValue(':df', date('Y-m-d', strtotime("+" . $qtd . " days")));
    $stmt->bindValue(':v', $valor);
    $stmt->bindValue(':vp', $vp);
    $stmt->bindValue(':q', $qtd);
    $stmt->bindValue(':s', rand(1,10) <= 7 ? 'Vigente' : 'Finalizado');
    $stmt->execute();
}

echo "   ✅ Crédito: 200 clientes, 8 agentes, 150 contratos\n";

// ============================================================================
// 🎬 STREAMING
// ============================================================================
echo "🎬 Criando tabelas de STREAMING...\n";

$db->exec("CREATE TABLE IF NOT EXISTS streaming_usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT, email TEXT, plano TEXT, dt_cadastro TEXT, status TEXT
)");

$db->exec("CREATE TABLE IF NOT EXISTS streaming_titulos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    titulo TEXT, tipo TEXT, genero TEXT, duracao_min INTEGER, dt_lancamento TEXT, classificacao TEXT
)");

$db->exec("CREATE TABLE IF NOT EXISTS streaming_assistencias (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idusuario INTEGER, idtitulo INTEGER,
    dt_assistido TEXT, minutos_assistidos INTEGER, dispositivo TEXT,
    FOREIGN KEY (idusuario) REFERENCES streaming_usuarios(id),
    FOREIGN KEY (idtitulo) REFERENCES streaming_titulos(id)
)");

$db->exec("CREATE TABLE IF NOT EXISTS streaming_avaliacoes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idusuario INTEGER, idtitulo INTEGER,
    nota INTEGER, dt_avaliacao TEXT,
    FOREIGN KEY (idusuario) REFERENCES streaming_usuarios(id),
    FOREIGN KEY (idtitulo) REFERENCES streaming_titulos(id)
)");

for ($i = 0; $i < 500; $i++) {
    $stmt = $db->prepare("INSERT INTO streaming_usuarios (nome, email, plano, dt_cadastro, status) VALUES (:n, :e, :p, :d, :s)");
    $stmt->bindValue(':n', "Usuario " . ($i+1));
    $stmt->bindValue(':e', "user$i@example.com");
    $stmt->bindValue(':p', ['Basico','Padrao','Premium'][rand(0,2)]);
    $stmt->bindValue(':d', date('Y-m-d', strtotime("-" . rand(0,600) . " days")));
    $stmt->bindValue(':s', rand(1,100) <= 75 ? 'Ativo' : 'Cancelado');
    $stmt->execute();
}

for ($i = 0; $i < 200; $i++) {
    $stmt = $db->prepare("INSERT INTO streaming_titulos (titulo, tipo, genero, duracao_min, dt_lancamento, classificacao) VALUES (:t, :ti, :g, :d, :l, :c)");
    $tipo = ['Filme','Série'][rand(0,1)];
    $stmt->bindValue(':t', "Titulo $i");
    $stmt->bindValue(':ti', $tipo);
    $stmt->bindValue(':g', ['Ação','Comédia','Drama','Terror','Documentário','Animação','Romance'][rand(0,6)]);
    $stmt->bindValue(':d', $tipo == 'Filme' ? rand(20,180) : rand(30,60));
    $stmt->bindValue(':l', date('Y-m-d', strtotime("-" . rand(0,3650) . " days")));
    $stmt->bindValue(':c', ['L','10','12','14','16','18'][rand(0,5)]);
    $stmt->execute();
}

for ($i = 0; $i < 5000; $i++) {
    $stmt = $db->prepare("INSERT INTO streaming_assistencias (idusuario, idtitulo, dt_assistido, minutos_assistidos, dispositivo) VALUES (:u, :t, :d, :m, :dp)");
    $stmt->bindValue(':u', rand(1,500));
    $stmt->bindValue(':t', rand(1,200));
    $stmt->bindValue(':d', date('Y-m-d', strtotime("-" . rand(0,365) . " days")));
    $stmt->bindValue(':m', rand(10,180));
    $stmt->bindValue(':dp', ['Smart TV','Celular','Tablet','Notebook'][rand(0,3)]);
    $stmt->execute();
}

for ($i = 0; $i < 800; $i++) {
    $stmt = $db->prepare("INSERT INTO streaming_avaliacoes (idusuario, idtitulo, nota, dt_avaliacao) VALUES (:u, :t, :n, :d)");
    $stmt->bindValue(':u', rand(1,500));
    $stmt->bindValue(':t', rand(1,200));
    $stmt->bindValue(':n', rand(1,5));
    $stmt->bindValue(':d', date('Y-m-d'));
    $stmt->execute();
}

echo "   ✅ Streaming: 500 usuários, 200 títulos, 5000 assistências, 800 avaliações\n";

// ============================================================================
// 🛒 E-COMMERCE
// ============================================================================
echo "🛒 Criando tabelas de E-COMMERCE...\n";

$db->exec("CREATE TABLE IF NOT EXISTS ecommerce_clientes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT, email TEXT, cpf TEXT, cidade TEXT, estado TEXT, dt_cadastro TEXT
)");

$db->exec("CREATE TABLE IF NOT EXISTS ecommerce_produtos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT, categoria TEXT, preco_custo REAL, preco_venda REAL, estoque INTEGER
)");

$db->exec("CREATE TABLE IF NOT EXISTS ecommerce_pedidos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idcliente INTEGER, dt_pedido TEXT, status TEXT, frete REAL, desconto REAL,
    FOREIGN KEY (idcliente) REFERENCES ecommerce_clientes(id)
)");

$db->exec("CREATE TABLE IF NOT EXISTS ecommerce_itens_pedido (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idpedido INTEGER, idproduto INTEGER, quantidade INTEGER, preco_unitario REAL,
    FOREIGN KEY (idpedido) REFERENCES ecommerce_pedidos(id),
    FOREIGN KEY (idproduto) REFERENCES ecommerce_produtos(id)
)");

$db->exec("CREATE TABLE IF NOT EXISTS ecommerce_pagamentos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idpedido INTEGER, forma TEXT, valor REAL, dt_pagamento TEXT, status TEXT,
    FOREIGN KEY (idpedido) REFERENCES ecommerce_pedidos(id)
)");

for ($i = 0; $i < 400; $i++) {
    $stmt = $db->prepare("INSERT INTO ecommerce_clientes (nome, email, cpf, cidade, estado, dt_cadastro) VALUES (:n, :e, :c, :ci, :es, :d)");
    $stmt->bindValue(':n', "Cliente Ecom " . ($i+1));
    $stmt->bindValue(':e', "ecom$i@example.com");
    $stmt->bindValue(':c', str_pad(rand(0, 99999999999), 11, '0', STR_PAD_LEFT));
    $stmt->bindValue(':ci', "Cidade " . rand(1,100));
    $stmt->bindValue(':es', ['SP','RJ','MG','RS','PR','BA','SC','PE','CE','GO'][rand(0,9)]);
    $stmt->bindValue(':d', date('Y-m-d', strtotime("-" . rand(0,1000) . " days")));
    $stmt->execute();
}

for ($i = 0; $i < 150; $i++) {
    $stmt = $db->prepare("INSERT INTO ecommerce_produtos (nome, categoria, preco_custo, preco_venda, estoque) VALUES (:n, :c, :cu, :v, :e)");
    $custo = round(rand(10,500) + rand(0,99)/100, 2);
    $stmt->bindValue(':n', "Produto " . ($i+1));
    $stmt->bindValue(':c', ['Eletrônicos','Roupas','Casa','Esporte','Beleza','Livros','Brinquedos'][rand(0,6)]);
    $stmt->bindValue(':cu', $custo);
    $stmt->bindValue(':v', round($custo * (1.4 + rand(0,110)/100), 2));
    $stmt->bindValue(':e', rand(0,200));
    $stmt->execute();
}

for ($i = 0; $i < 800; $i++) {
    $stmt = $db->prepare("INSERT INTO ecommerce_pedidos (idcliente, dt_pedido, status, frete, desconto) VALUES (:c, :d, :s, :f, :de)");
    $stmt->bindValue(':c', rand(1,400));
    $stmt->bindValue(':d', date('Y-m-d', strtotime("-" . rand(0,365) . " days")));
    $stmt->bindValue(':s', ['Entregue','Enviado','Processando','Cancelado'][rand(0,3)]);
    $stmt->bindValue(':f', round(rand(0,5000)/100, 2));
    $stmt->bindValue(':de', rand(1,100) <= 20 ? round(rand(0,3000)/100, 2) : 0);
    $stmt->execute();
}

echo "   ✅ E-commerce: 400 clientes, 150 produtos, 800 pedidos\n";

// ============================================================================
// 📊 SaaS
// ============================================================================
echo "📊 Criando tabelas de SaaS...\n";

$db->exec("CREATE TABLE IF NOT EXISTS saas_clientes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT, empresa TEXT, segmento TEXT, tamanho TEXT, dt_cadastro TEXT
)");

$db->exec("CREATE TABLE IF NOT EXISTS saas_planos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT, preco_mensal REAL, limite_usuarios INTEGER, recursos TEXT
)");

$db->exec("CREATE TABLE IF NOT EXISTS saas_assinaturas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idcliente INTEGER, idplano INTEGER,
    dt_inicio TEXT, dt_fim TEXT, status TEXT, valor_mensal REAL,
    FOREIGN KEY (idcliente) REFERENCES saas_clientes(id),
    FOREIGN KEY (idplano) REFERENCES saas_planos(id)
)");

$db->exec("CREATE TABLE IF NOT EXISTS saas_faturas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idassinatura INTEGER,
    dt_vencimento TEXT, dt_pagamento TEXT, valor REAL, status TEXT,
    FOREIGN KEY (idassinatura) REFERENCES saas_assinaturas(id)
)");

$db->exec("CREATE TABLE IF NOT EXISTS saas_usos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idassinatura INTEGER,
    dt_uso TEXT, metrica TEXT, valor INTEGER,
    FOREIGN KEY (idassinatura) REFERENCES saas_assinaturas(id)
)");

for ($i = 0; $i < 300; $i++) {
    $stmt = $db->prepare("INSERT INTO saas_clientes (nome, empresa, segmento, tamanho, dt_cadastro) VALUES (:n, :e, :s, :t, :d)");
    $stmt->bindValue(':n', "Cliente SaaS " . ($i+1));
    $stmt->bindValue(':e', "Empresa " . ($i+1));
    $stmt->bindValue(':s', ['Varejo','Serviços','Indústria','Saúde','Educação','Tecnologia'][rand(0,5)]);
    $stmt->bindValue(':t', ['Pequena','Média','Grande'][rand(0,2)]);
    $stmt->bindValue(':d', date('Y-m-d', strtotime("-" . rand(0,1000) . " days")));
    $stmt->execute();
}

$planos = [
    ['Starter', 49.90, 5, 'Básico'],
    ['Professional', 149.90, 25, 'Intermediário'],
    ['Business', 399.90, 100, 'Avançado'],
    ['Enterprise', 999.90, 9999, 'Completo']
];
foreach ($planos as $p) {
    $stmt = $db->prepare("INSERT INTO saas_planos (nome, preco_mensal, limite_usuarios, recursos) VALUES (:n, :p, :l, :r)");
    $stmt->bindValue(':n', $p[0]); $stmt->bindValue(':p', $p[1]);
    $stmt->bindValue(':l', $p[2]); $stmt->bindValue(':r', $p[3]);
    $stmt->execute();
}

for ($i = 1; $i <= 300; $i++) {
    $stmt = $db->prepare("INSERT INTO saas_assinaturas (idcliente, idplano, dt_inicio, dt_fim, status, valor_mensal) VALUES (:c, :p, :di, :df, :s, :v)");
    $idplano = [1,2,3,4][rand(0,3)];
    $status = rand(1,100) <= 80 ? 'Ativa' : 'Cancelada';
    $stmt->bindValue(':c', $i);
    $stmt->bindValue(':p', $idplano);
    $stmt->bindValue(':di', date('Y-m-d', strtotime("-" . rand(0,1000) . " days")));
    $stmt->bindValue(':df', $status == 'Cancelada' ? date('Y-m-d', strtotime("+" . rand(90,365) . " days")) : null);
    $stmt->bindValue(':s', $status);
    $stmt->bindValue(':v', $planos[$idplano-1][1]);
    $stmt->execute();
}

echo "   ✅ SaaS: 300 clientes, 4 planos, 300 assinaturas\n";

// ============================================================================
// FINALIZAÇÃO
// ============================================================================
$db->close();

echo "\n╔════════════════════════════════════════════════════════════╗\n";
echo "║  ✅ BASE ÚNICA CRIADA COM SUCESSO!                        ║\n";
echo "╠════════════════════════════════════════════════════════════╣\n";
echo "║  📁 Arquivo gerado: analise_dados.db                      ║\n";
echo "║  📊 18 tabelas (4 setores × prefixos)                     ║\n";
echo "╚════════════════════════════════════════════════════════════╝\n";
?>