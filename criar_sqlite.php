<?php
/**
 * GERADOR COMPLETO DE BASES DE DADOS PARA ANÁLISE
 * Cria 4 bases: Crédito, Streaming, E-commerce, SaaS
 * 
 * USO: php criar_todos_sqlite.php
 */

echo "╔════════════════════════════════════════════════════════════╗\n";
echo "║  GERADOR DE BASES DE DADOS PARA ANÁLISE                   ║\n";
echo "║  Crédito | Streaming | E-commerce | SaaS                  ║\n";
echo "╚════════════════════════════════════════════════════════════╝\n\n";

// ============================================================================
// BASE 1: CRÉDITO / MICROCREDITO
// ============================================================================
echo "💰 Criando base de CRÉDITO...\n";
$db_credito = new SQLite3('credito.db');

$db_credito->exec("CREATE TABLE IF NOT EXISTS clientes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT,
    cpf TEXT,
    idade INTEGER,
    genero TEXT,
    estabelecimento TEXT
)");

$db_credito->exec("CREATE TABLE IF NOT EXISTS usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT,
    comissao REAL,
    custo_fixo REAL
)");

$db_credito->exec("CREATE TABLE IF NOT EXISTS contratos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idcliente INTEGER,
    idusuario INTEGER,
    dtinicio TEXT,
    dtfim TEXT,
    valor REAL,
    valor_parcelado REAL,
    qtd_parcela INTEGER,
    status TEXT,
    FOREIGN KEY (idcliente) REFERENCES clientes(id),
    FOREIGN KEY (idusuario) REFERENCES usuarios(id)
)");

$db_credito->exec("CREATE TABLE IF NOT EXISTS movimentacoes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idcontrato INTEGER,
    dtvenc TEXT,
    dtrecebimento TEXT,
    valorrecebido REAL,
    areceber REAL,
    desconto REAL,
    status TEXT,
    FOREIGN KEY (idcontrato) REFERENCES contratos(id)
)");

// Popular agentes
$agentes_credito = [
    ['Carlos', 6.0, 1500.0], ['Julio', 6.0, 1500.0], ['Marcelo', 6.0, 1500.0],
    ['Renato', 6.0, 1500.0], ['Leonardo', 6.0, 1500.0], ['Fernanda', 6.0, 1500.0],
    ['Kelly', 6.0, 1500.0], ['MVP', 6.0, 1500.0]
];

foreach ($agentes_credito as $ag) {
    $stmt = $db_credito->prepare("INSERT INTO usuarios (nome, comissao, custo_fixo) VALUES (:nome, :com, :custo)");
    $stmt->bindValue(':nome', $ag[0]);
    $stmt->bindValue(':com', $ag[1]);
    $stmt->bindValue(':custo', $ag[2]);
    $stmt->execute();
}

// Popular clientes
for ($i = 0; $i < 200; $i++) {
    $nome = "Cliente " . ($i + 1);
    $cpf = str_pad(rand(0, 99999999999), 11, '0', STR_PAD_LEFT);
    $idade = rand(18, 75);
    $genero = rand(0, 1) ? 'Masculino' : 'Feminino';
    $estab = ['Padaria', 'Restaurante', 'Bar', 'Salão', 'Oficina', 'Loja', 'Mercado'][rand(0, 6)];
    
    $stmt = $db_credito->prepare("INSERT INTO clientes (nome, cpf, idade, genero, estabelecimento) VALUES (:nome, :cpf, :idade, :genero, :estab)");
    $stmt->bindValue(':nome', $nome);
    $stmt->bindValue(':cpf', $cpf);
    $stmt->bindValue(':idade', $idade);
    $stmt->bindValue(':genero', $genero);
    $stmt->bindValue(':estab', $estab);
    $stmt->execute();
}

// Popular contratos
for ($i = 0; $i < 150; $i++) {
    $idcliente = rand(1, 200);
    $idusuario = rand(1, 8);
    $dias_inicio = rand(0, 365);
    $dtinicio = date('Y-m-d', strtotime("-$dias_inicio days"));
    $valor = round(rand(500, 5000) + (rand(0, 99) / 100), 2);
    $qtd = [30, 60, 90][rand(0, 2)];
    $valor_parcelado = round($valor * (1 + 0.023 * ($qtd / 30)), 2);
    $dtfim = date('Y-m-d', strtotime($dtinicio . " +$qtd days"));
    $status = rand(1, 10) <= 7 ? 'Vigente' : 'Finalizado';
    
    $stmt = $db_credito->prepare("INSERT INTO contratos (idcliente, idusuario, dtinicio, dtfim, valor, valor_parcelado, qtd_parcela, status) VALUES (:cli, :usu, :dti, :dtf, :val, :vpar, :qtd, :st)");
    $stmt->bindValue(':cli', $idcliente);
    $stmt->bindValue(':usu', $idusuario);
    $stmt->bindValue(':dti', $dtinicio);
    $stmt->bindValue(':dtf', $dtfim);
    $stmt->bindValue(':val', $valor);
    $stmt->bindValue(':vpar', $valor_parcelado);
    $stmt->bindValue(':qtd', $qtd);
    $stmt->bindValue(':st', $status);
    $stmt->execute();
}

$db_credito->close();
echo "   ✅ credito.db criado (200 clientes, 8 agentes, 150 contratos)\n\n";

// ============================================================================
// BASE 2: STREAMING
// ============================================================================
echo "🎬 Criando base de STREAMING...\n";
$db_streaming = new SQLite3('streaming.db');

$db_streaming->exec("CREATE TABLE IF NOT EXISTS usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT,
    email TEXT,
    plano TEXT,
    dt_cadastro TEXT,
    status TEXT
)");

$db_streaming->exec("CREATE TABLE IF NOT EXISTS titulos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    titulo TEXT,
    tipo TEXT,
    genero TEXT,
    duracao_min INTEGER,
    dt_lancamento TEXT,
    classificacao TEXT
)");

$db_streaming->exec("CREATE TABLE IF NOT EXISTS assistencias (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idusuario INTEGER,
    idtitulo INTEGER,
    dt_assistido TEXT,
    minutos_assistidos INTEGER,
    dispositivo TEXT,
    FOREIGN KEY (idusuario) REFERENCES usuarios(id),
    FOREIGN KEY (idtitulo) REFERENCES titulos(id)
)");

$db_streaming->exec("CREATE TABLE IF NOT EXISTS avaliacoes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idusuario INTEGER,
    idtitulo INTEGER,
    nota INTEGER,
    dt_avaliacao TEXT,
    FOREIGN KEY (idusuario) REFERENCES usuarios(id),
    FOREIGN KEY (idtitulo) REFERENCES titulos(id)
)");

// Popular usuários
$planos_streaming = ['Basico', 'Padrao', 'Premium'];
for ($i = 0; $i < 500; $i++) {
    $nome = "Usuario " . ($i + 1);
    $email = "user$i@example.com";
    $plano = $planos_streaming[rand(0, 2)];
    $dias = rand(0, 600);
    $dt_cadastro = date('Y-m-d', strtotime("-$dias days"));
    $status = rand(1, 100) <= 75 ? 'Ativo' : 'Cancelado';
    
    $stmt = $db_streaming->prepare("INSERT INTO usuarios (nome, email, plano, dt_cadastro, status) VALUES (:nome, :email, :plano, :dt, :status)");
    $stmt->bindValue(':nome', $nome);
    $stmt->bindValue(':email', $email);
    $stmt->bindValue(':plano', $plano);
    $stmt->bindValue(':dt', $dt_cadastro);
    $stmt->bindValue(':status', $status);
    $stmt->execute();
}

// Popular títulos
$generos_streaming = ['Ação', 'Comédia', 'Drama', 'Terror', 'Documentário', 'Animação', 'Romance'];
$tipos_streaming = ['Filme', 'Série'];
for ($i = 0; $i < 200; $i++) {
    $titulo = "Titulo $i";
    $tipo = $tipos_streaming[rand(0, 1)];
    $genero = $generos_streaming[rand(0, 6)];
    $duracao = $tipo == 'Filme' ? rand(20, 180) : rand(30, 60);
    $dias = rand(0, 3650);
    $dt_lanc = date('Y-m-d', strtotime("-$dias days"));
    $classif = ['L', '10', '12', '14', '16', '18'][rand(0, 5)];
    
    $stmt = $db_streaming->prepare("INSERT INTO titulos (titulo, tipo, genero, duracao_min, dt_lancamento, classificacao) VALUES (:tit, :tipo, :gen, :dur, :dt, :class)");
    $stmt->bindValue(':tit', $titulo);
    $stmt->bindValue(':tipo', $tipo);
    $stmt->bindValue(':gen', $genero);
    $stmt->bindValue(':dur', $duracao);
    $stmt->bindValue(':dt', $dt_lanc);
    $stmt->bindValue(':class', $classif);
    $stmt->execute();
}

// Popular assistências
$dispositivos = ['Smart TV', 'Celular', 'Tablet', 'Notebook'];
for ($i = 0; $i < 5000; $i++) {
    $iduser = rand(1, 500);
    $idtit = rand(1, 200);
    $dias = rand(0, 365);
    $dt_assist = date('Y-m-d', strtotime("-$dias days"));
    $minutos = rand(10, 180);
    $disp = $dispositivos[rand(0, 3)];
    
    $stmt = $db_streaming->prepare("INSERT INTO assistencias (idusuario, idtitulo, dt_assistido, minutos_assistidos, dispositivo) VALUES (:user, :tit, :dt, :min, :disp)");
    $stmt->bindValue(':user', $iduser);
    $stmt->bindValue(':tit', $idtit);
    $stmt->bindValue(':dt', $dt_assist);
    $stmt->bindValue(':min', $minutos);
    $stmt->bindValue(':disp', $disp);
    $stmt->execute();
}

// Popular avaliações
for ($i = 0; $i < 800; $i++) {
    $iduser = rand(1, 500);
    $idtit = rand(1, 200);
    $nota = rand(1, 5);
    $dt_avaliacao = date('Y-m-d');
    
    $stmt = $db_streaming->prepare("INSERT INTO avaliacoes (idusuario, idtitulo, nota, dt_avaliacao) VALUES (:user, :tit, :nota, :dt)");
    $stmt->bindValue(':user', $iduser);
    $stmt->bindValue(':tit', $idtit);
    $stmt->bindValue(':nota', $nota);
    $stmt->bindValue(':dt', $dt_avaliacao);
    $stmt->execute();
}

$db_streaming->close();
echo "   ✅ streaming.db criado (500 usuários, 200 títulos, 5000 assistências)\n\n";

// ============================================================================
// BASE 3: E-COMMERCE
// ============================================================================
echo "🛒 Criando base de E-COMMERCE...\n";
$db_ecommerce = new SQLite3('ecommerce.db');

$db_ecommerce->exec("CREATE TABLE IF NOT EXISTS clientes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT,
    email TEXT,
    cpf TEXT,
    cidade TEXT,
    estado TEXT,
    dt_cadastro TEXT
)");

$db_ecommerce->exec("CREATE TABLE IF NOT EXISTS produtos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT,
    categoria TEXT,
    preco_custo REAL,
    preco_venda REAL,
    estoque INTEGER
)");

$db_ecommerce->exec("CREATE TABLE IF NOT EXISTS pedidos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idcliente INTEGER,
    dt_pedido TEXT,
    status TEXT,
    frete REAL,
    desconto REAL,
    FOREIGN KEY (idcliente) REFERENCES clientes(id)
)");

$db_ecommerce->exec("CREATE TABLE IF NOT EXISTS itens_pedido (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idpedido INTEGER,
    idproduto INTEGER,
    quantidade INTEGER,
    preco_unitario REAL,
    FOREIGN KEY (idpedido) REFERENCES pedidos(id),
    FOREIGN KEY (idproduto) REFERENCES produtos(id)
)");

$db_ecommerce->exec("CREATE TABLE IF NOT EXISTS pagamentos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idpedido INTEGER,
    forma TEXT,
    valor REAL,
    dt_pagamento TEXT,
    status TEXT,
    FOREIGN KEY (idpedido) REFERENCES pedidos(id)
)");

// Popular clientes
$estados = ['SP', 'RJ', 'MG', 'RS', 'PR', 'BA', 'SC', 'PE', 'CE', 'GO'];
for ($i = 0; $i < 400; $i++) {
    $nome = "Cliente Ecom " . ($i + 1);
    $email = "ecom$i@example.com";
    $cpf = str_pad(rand(0, 99999999999), 11, '0', STR_PAD_LEFT);
    $cidade = "Cidade " . rand(1, 100);
    $estado = $estados[rand(0, 9)];
    $dias = rand(0, 1000);
    $dt_cadastro = date('Y-m-d', strtotime("-$dias days"));
    
    $stmt = $db_ecommerce->prepare("INSERT INTO clientes (nome, email, cpf, cidade, estado, dt_cadastro) VALUES (:nome, :email, :cpf, :cid, :est, :dt)");
    $stmt->bindValue(':nome', $nome);
    $stmt->bindValue(':email', $email);
    $stmt->bindValue(':cpf', $cpf);
    $stmt->bindValue(':cid', $cidade);
    $stmt->bindValue(':est', $estado);
    $stmt->bindValue(':dt', $dt_cadastro);
    $stmt->execute();
}

// Popular produtos
$categorias = ['Eletrônicos', 'Roupas', 'Casa', 'Esporte', 'Beleza', 'Livros', 'Brinquedos'];
for ($i = 0; $i < 150; $i++) {
    $nome = "Produto " . ($i + 1);
    $categoria = $categorias[rand(0, 6)];
    $custo = round(rand(10, 500) + (rand(0, 99) / 100), 2);
    $venda = round($custo * (1.4 + (rand(0, 110) / 100)), 2);
    $estoque = rand(0, 200);
    
    $stmt = $db_ecommerce->prepare("INSERT INTO produtos (nome, categoria, preco_custo, preco_venda, estoque) VALUES (:nome, :cat, :custo, :venda, :est)");
    $stmt->bindValue(':nome', $nome);
    $stmt->bindValue(':cat', $categoria);
    $stmt->bindValue(':custo', $custo);
    $stmt->bindValue(':venda', $venda);
    $stmt->bindValue(':est', $estoque);
    $stmt->execute();
}

// Popular pedidos
$status_pedidos = ['Entregue', 'Enviado', 'Processando', 'Cancelado'];
for ($i = 0; $i < 800; $i++) {
    $idcliente = rand(1, 400);
    $dias = rand(0, 365);
    $dt_pedido = date('Y-m-d', strtotime("-$dias days"));
    $status = $status_pedidos[array_rand(['Entregue' => 6, 'Enviado' => 1.5, 'Processando' => 1.5, 'Cancelado' => 1])];
    $frete = round(rand(0, 5000) / 100, 2);
    $desconto = rand(1, 100) <= 20 ? round(rand(0, 3000) / 100, 2) : 0;
    
    $stmt = $db_ecommerce->prepare("INSERT INTO pedidos (idcliente, dt_pedido, status, frete, desconto) VALUES (:cli, :dt, :st, :frete, :desc)");
    $stmt->bindValue(':cli', $idcliente);
    $stmt->bindValue(':dt', $dt_pedido);
    $stmt->bindValue(':st', $status);
    $stmt->bindValue(':frete', $frete);
    $stmt->bindValue(':desc', $desconto);
    $stmt->execute();
}

// Popular itens de pedido
for ($idped = 1; $idped <= 800; $idped++) {
    $qtd_itens = rand(1, 5);
    for ($j = 0; $j < $qtd_itens; $j++) {
        $idproduto = rand(1, 150);
        $quantidade = rand(1, 4);
        
        $stmt_prod = $db_ecommerce->prepare("SELECT preco_venda FROM produtos WHERE id = :id");
        $stmt_prod->bindValue(':id', $idproduto);
        $result = $stmt_prod->execute();
        $row = $result->fetchArray();
        $preco = $row ? $row['preco_venda'] : 100;
        
        $stmt = $db_ecommerce->prepare("INSERT INTO itens_pedido (idpedido, idproduto, quantidade, preco_unitario) VALUES (:ped, :prod, :qtd, :preco)");
        $stmt->bindValue(':ped', $idped);
        $stmt->bindValue(':prod', $idproduto);
        $stmt->bindValue(':qtd', $quantidade);
        $stmt->bindValue(':preco', $preco);
        $stmt->execute();
    }
}

// Popular pagamentos
$formas_pagamento = ['Cartão Crédito', 'Cartão Débito', 'Pix', 'Boleto'];
for ($idped = 1; $idped <= 800; $idped++) {
    if (rand(1, 100) <= 95) {
        $forma = $formas_pagamento[rand(0, 3)];
        
        $stmt_total = $db_ecommerce->prepare("SELECT SUM(quantidade * preco_unitario) as total FROM itens_pedido WHERE idpedido = :id");
        $stmt_total->bindValue(':id', $idped);
        $result = $stmt_total->execute();
        $row = $result->fetchArray();
        $valor = $row ? $row['total'] : 0;
        
        $dias = rand(0, 365);
        $dt_pagamento = date('Y-m-d', strtotime("-$dias days"));
        $status = rand(1, 10) <= 9 ? 'Aprovado' : 'Recusado';
        
        $stmt = $db_ecommerce->prepare("INSERT INTO pagamentos (idpedido, forma, valor, dt_pagamento, status) VALUES (:ped, :forma, :val, :dt, :st)");
        $stmt->bindValue(':ped', $idped);
        $stmt->bindValue(':forma', $forma);
        $stmt->bindValue(':val', $valor);
        $stmt->bindValue(':dt', $dt_pagamento);
        $stmt->bindValue(':st', $status);
        $stmt->execute();
    }
}

$db_ecommerce->close();
echo "   ✅ ecommerce.db criado (400 clientes, 150 produtos, 800 pedidos)\n\n";

// ============================================================================
// BASE 4: SaaS / ASSINATURAS
// ============================================================================
echo "📊 Criando base de SaaS...\n";
$db_saas = new SQLite3('saas.db');

$db_saas->exec("CREATE TABLE IF NOT EXISTS clientes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT,
    empresa TEXT,
    segmento TEXT,
    tamanho TEXT,
    dt_cadastro TEXT
)");

$db_saas->exec("CREATE TABLE IF NOT EXISTS planos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT,
    preco_mensal REAL,
    limite_usuarios INTEGER,
    recursos TEXT
)");

$db_saas->exec("CREATE TABLE IF NOT EXISTS assinaturas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idcliente INTEGER,
    idplano INTEGER,
    dt_inicio TEXT,
    dt_fim TEXT,
    status TEXT,
    valor_mensal REAL,
    FOREIGN KEY (idcliente) REFERENCES clientes(id),
    FOREIGN KEY (idplano) REFERENCES planos(id)
)");

$db_saas->exec("CREATE TABLE IF NOT EXISTS faturas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idassinatura INTEGER,
    dt_vencimento TEXT,
    dt_pagamento TEXT,
    valor REAL,
    status TEXT,
    FOREIGN KEY (idassinatura) REFERENCES assinaturas(id)
)");

$db_saas->exec("CREATE TABLE IF NOT EXISTS usos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    idassinatura INTEGER,
    dt_uso TEXT,
    metrica TEXT,
    valor INTEGER,
    FOREIGN KEY (idassinatura) REFERENCES assinaturas(id)
)");

// Popular clientes B2B
$segmentos = ['Varejo', 'Serviços', 'Indústria', 'Saúde', 'Educação', 'Tecnologia'];
$tamanhos = ['Pequena', 'Média', 'Grande'];
for ($i = 0; $i < 300; $i++) {
    $nome = "Cliente SaaS " . ($i + 1);
    $empresa = "Empresa " . ($i + 1);
    $segmento = $segmentos[rand(0, 5)];
    $tamanho = $tamanhos[rand(0, 2)];
    $dias = rand(0, 1000);
    $dt_cadastro = date('Y-m-d', strtotime("-$dias days"));
    
    $stmt = $db_saas->prepare("INSERT INTO clientes (nome, empresa, segmento, tamanho, dt_cadastro) VALUES (:nome, :emp, :seg, :tam, :dt)");
    $stmt->bindValue(':nome', $nome);
    $stmt->bindValue(':emp', $empresa);
    $stmt->bindValue(':seg', $segmento);
    $stmt->bindValue(':tam', $tamanho);
    $stmt->bindValue(':dt', $dt_cadastro);
    $stmt->execute();
}

// Popular planos
$planos_saas = [
    ['Starter', 49.90, 5, 'Básico'],
    ['Professional', 149.90, 25, 'Intermediário'],
    ['Business', 399.90, 100, 'Avançado'],
    ['Enterprise', 999.90, 9999, 'Completo']
];

foreach ($planos_saas as $plano) {
    $stmt = $db_saas->prepare("INSERT INTO planos (nome, preco_mensal, limite_usuarios, recursos) VALUES (:nome, :preco, :lim, :rec)");
    $stmt->bindValue(':nome', $plano[0]);
    $stmt->bindValue(':preco', $plano[1]);
    $stmt->bindValue(':lim', $plano[2]);
    $stmt->bindValue(':rec', $plano[3]);
    $stmt->execute();
}

// Popular assinaturas
for ($idcli = 1; $idcli <= 300; $idcli++) {
    $idplano = [1, 2, 3, 4][array_rand([1 => 40, 2 => 35, 3 => 20, 4 => 5])];
    $dias = rand(0, 1000);
    $dt_inicio = date('Y-m-d', strtotime("-$dias days"));
    $preco = $planos_saas[$idplano - 1][1];
    $status = rand(1, 100) <= 80 ? 'Ativa' : 'Cancelada';
    $dt_fim = $status == 'Cancelada' ? date('Y-m-d', strtotime($dt_inicio . " +" . rand(90, 365) . " days")) : null;
    
    $stmt = $db_saas->prepare("INSERT INTO assinaturas (idcliente, idplano, dt_inicio, dt_fim, status, valor_mensal) VALUES (:cli, :plano, :dti, :dtf, :st, :val)");
    $stmt->bindValue(':cli', $idcli);
    $stmt->bindValue(':plano', $idplano);
    $stmt->bindValue(':dti', $dt_inicio);
    $stmt->bindValue(':dtf', $dt_fim);
    $stmt->bindValue(':st', $status);
    $stmt->bindValue(':val', $preco);
    $stmt->execute();
}

// Popular faturas
for ($idass = 1; $idass <= 300; $idass++) {
    $stmt_ass = $db_saas->prepare("SELECT dt_inicio, dt_fim, valor_mensal, status FROM assinaturas WHERE id = :id");
    $stmt_ass->bindValue(':id', $idass);
    $result = $stmt_ass->execute();
    $row = $result->fetchArray();
    
    if (!$row) continue;
    
    $dt_inicio = new DateTime($row['dt_inicio']);
    $dt_fim = $row['dt_fim'] ? new DateTime($row['dt_fim']) : new DateTime();
    $valor = $row['valor_mensal'];
    
    $dt_atual = clone $dt_inicio;
    while ($dt_atual <= $dt_fim && $dt_atual <= new DateTime()) {
        $dt_venc = (clone $dt_atual)->modify('+30 days')->format('Y-m-d');
        $dt_pag = rand(1, 100) <= 85 ? (clone $dt_atual)->modify('+' . rand(-5, 15) . ' days')->format('Y-m-d') : null;
        $status = $dt_pag ? 'Paga' : (rand(0, 1) ? 'Pendente' : 'Atrasada');
        
        $stmt = $db_saas->prepare("INSERT INTO faturas (idassinatura, dt_vencimento, dt_pagamento, valor, status) VALUES (:ass, :dtv, :dtp, :val, :st)");
        $stmt->bindValue(':ass', $idass);
        $stmt->bindValue(':dtv', $dt_venc);
        $stmt->bindValue(':dtp', $dt_pag);
        $stmt->bindValue(':val', $valor);
        $stmt->bindValue(':st', $status);
        $stmt->execute();
        
        $dt_atual->modify('+30 days');
    }
}

// Popular usos
$metricas = ['logins', 'api_calls', 'relatorios_gerados'];
for ($idass = 1; $idass <= 300; $idass++) {
    $stmt_ass = $db_saas->prepare("SELECT dt_inicio, dt_fim, status FROM assinaturas WHERE id = :id");
    $stmt_ass->bindValue(':id', $idass);
    $result = $stmt_ass->execute();
    $row = $result->fetchArray();
    
    if (!$row) continue;
    
    $dt_inicio = new DateTime($row['dt_inicio']);
    $dt_fim = $row['dt_fim'] ? new DateTime($row['dt_fim']) : new DateTime();
    
    $dt_atual = clone $dt_inicio;
    while ($dt_atual <= $dt_fim && $dt_atual <= new DateTime()) {
        for ($j = 0; $j < rand(1, 3); $j++) {
            $metrica = $metricas[rand(0, 2)];
            $valor = rand(1, 100);
            
            $stmt = $db_saas->prepare("INSERT INTO usos (idassinatura, dt_uso, metrica, valor) VALUES (:ass, :dt, :met, :val)");
            $stmt->bindValue(':ass', $idass);
            $stmt->bindValue(':dt', $dt_atual->format('Y-m-d'));
            $stmt->bindValue(':met', $metrica);
            $stmt->bindValue(':val', $valor);
            $stmt->execute();
        }
        $dt_atual->modify('+1 day');
    }
}

$db_saas->close();
echo "   ✅ saas.db criado (300 clientes, 4 planos, 300 assinaturas)\n\n";

// ============================================================================
// FINALIZAÇÃO
// ============================================================================
echo "╔════════════════════════════════════════════════════════════╗\n";
echo "║  ✅ TODAS AS BASES CRIADAS COM SUCESSO!                   ║\n";
echo "╠════════════════════════════════════════════════════════════╣\n";
echo "║  📁 Arquivos gerados:                                     ║\n";
echo "║     • credito.db     (Crédito/Microcrédito)              ║\n";
echo "║     • streaming.db   (Streaming/Entretenimento)          ║\n";
echo "║     • ecommerce.db   (E-commerce/Vendas)                 ║\n";
echo "║     • saas.db        (SaaS/Assinaturas)                  ║\n";
echo "╚════════════════════════════════════════════════════════════╝\n";
?>