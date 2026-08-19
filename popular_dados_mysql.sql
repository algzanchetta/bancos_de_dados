<?php
/**
 * POPULADOR DE DADOS PARA ANÁLISE
 * Gera volume realista em todas as 18 tabelas
 * 
 * USO: php popular_dados.php
 */

error_reporting(E_ALL);
ini_set('display_errors', 1);
set_time_limit(0);

echo "╔════════════════════════════════════════════════════════════╗\n";
echo "║  POPULANDO BASES COM DADOS PARA ANÁLISE                   ║\n";
echo "╚════════════════════════════════════════════════════════════╝\n\n";

$db = new SQLite3('analise_dados.db');
$db->exec("PRAGMA synchronous = OFF");
$db->exec("PRAGMA journal_mode = MEMORY");

// ============================================================================
// 💰 CRÉDITO — 500 clientes, 300 contratos, ~18.000 movimentações
// ============================================================================
echo "💰 Populando CRÉDITO...\n";

// Limpar dados existentes
$db->exec("DELETE FROM credito_movimentacoes");
$db->exec("DELETE FROM credito_contratos");
$db->exec("DELETE FROM credito_clientes");
$db->exec("DELETE FROM credito_usuarios");

// Agentes (8)
$agentes = [
    ['Carlos', 6.0, 1500.0], ['Julio', 6.0, 1500.0], ['Marcelo', 6.0, 1500.0],
    ['Renato', 6.0, 1500.0], ['Leonardo', 6.0, 1500.0], ['Fernanda', 6.0, 1500.0],
    ['Kelly', 6.0, 1500.0], ['MVP', 6.0, 1500.0]
];
$db->exec("BEGIN TRANSACTION");
foreach ($agentes as $ag) {
    $stmt = $db->prepare("INSERT INTO credito_usuarios (nome, comissao, custo_fixo) VALUES (:n, :c, :f)");
    $stmt->bindValue(':n', $ag[0]); $stmt->bindValue(':c', $ag[1]); $stmt->bindValue(':f', $ag[2]);
    $stmt->execute();
}

// Clientes (500)
$estabelecimentos = ['Padaria', 'Restaurante', 'Bar', 'Salão de Beleza', 'Oficina Mecânica', 'Loja de Roupas', 'Mercado', 'Farmácia', 'Açougue', 'Lanchonete'];
for ($i = 0; $i < 500; $i++) {
    $stmt = $db->prepare("INSERT INTO credito_clientes (nome, cpf, idade, genero, estabelecimento) VALUES (:n, :c, :i, :g, :e)");
    $stmt->bindValue(':n', "Cliente Credito " . ($i+1));
    $stmt->bindValue(':c', sprintf('%03d.%03d.%03d-%02d', rand(0,999), rand(0,999), rand(0,999), rand(0,99)));
    $stmt->bindValue(':i', rand(18, 75));
    $stmt->bindValue(':g', rand(0,1) ? 'Masculino' : 'Feminino');
    $stmt->bindValue(':e', $estabelecimentos[rand(0, count($estabelecimentos)-1)]);
    $stmt->execute();
}

// Contratos (300)
for ($i = 0; $i < 300; $i++) {
    $idcliente = rand(1, 500);
    $idusuario = rand(1, 8);
    $dias_atras = rand(30, 400);
    $dtinicio = date('Y-m-d', strtotime("-$dias_atras days"));
    $qtd_parcela = [30, 60, 90][rand(0, 2)];
    $valor = round(rand(500, 8000) + rand(0,99)/100, 2);
    $taxa_mensal = 0.023;
    $valor_parcelado = round($valor * (1 + $taxa_mensal * ($qtd_parcela / 30)), 2);
    $dtfim = date('Y-m-d', strtotime($dtinicio . " +$qtd_parcela days"));
    $status = rand(1, 100) <= 70 ? 'Vigente' : 'Finalizado';
    
    $stmt = $db->prepare("INSERT INTO credito_contratos (idcliente, idusuario, dtinicio, dtfim, valor, valor_parcelado, qtd_parcela, status) VALUES (:c, :u, :di, :df, :v, :vp, :q, :s)");
    $stmt->bindValue(':c', $idcliente);
    $stmt->bindValue(':u', $idusuario);
    $stmt->bindValue(':di', $dtinicio);
    $stmt->bindValue(':df', $dtfim);
    $stmt->bindValue(':v', $valor);
    $stmt->bindValue(':vp', $valor_parcelado);
    $stmt->bindValue(':q', $qtd_parcela);
    $stmt->bindValue(':s', $status);
    $stmt->execute();
}

// Movimentações (~18.000 parcelas)
$total_mov = 0;
for ($idcontrato = 1; $idcontrato <= 300; $idcontrato++) {
    $res = $db->querySingle("SELECT dtinicio, valor_parcelado, qtd_parcela FROM credito_contratos WHERE id = $idcontrato", true);
    if (!$res) continue;
    
    $dtinicio = new DateTime($res['dtinicio']);
    $valor_parcelado = $res['valor_parcelado'];
    $qtd = $res['qtd_parcela'];
    $parcela = round($valor_parcelado / $qtd, 2);
    
    for ($p = 0; $p < $qtd; $p++) {
        $dtvenc = (clone $dtinicio)->modify("+$p days");
        
        // Se ainda não venceu, não cria movimentação
        if ($dtvenc > new DateTime()) continue;
        
        // 68% pagas, 32% em aberto
        if (rand(1, 100) <= 68) {
            // Paga: 60% no dia, 25% até 5 dias, 10% até 30, 5% até 90
            $r = rand(1, 100);
            if ($r <= 60) $atraso = 0;
            elseif ($r <= 85) $atraso = rand(1, 5);
            elseif ($r <= 95) $atraso = rand(6, 30);
            else $atraso = rand(31, 90);
            
            $dtrec = (clone $dtvenc)->modify("+$atraso days");
            if ($dtrec > new DateTime()) {
                $dtrec = null;
                $valorrecebido = 0;
                $status = 'Aberto';
            } else {
                $valorrecebido = $parcela;
                $status = 'Pago';
            }
        } else {
            $dtrec = null;
            $valorrecebido = 0;
            $status = 'Aberto';
        }
        
        $stmt = $db->prepare("INSERT INTO credito_movimentacoes (idcontrato, dtvenc, dtrecebimento, valorrecebido, areceber, desconto, status) VALUES (:c, :dv, :dr, :vr, :ar, :d, :s)");
        $stmt->bindValue(':c', $idcontrato);
        $stmt->bindValue(':dv', $dtvenc->format('Y-m-d'));
        $stmt->bindValue(':dr', $dtrec ? $dtrec->format('Y-m-d') : null);
        $stmt->bindValue(':vr', $valorrecebido);
        $stmt->bindValue(':ar', $parcela);
        $stmt->bindValue(':d', 0);
        $stmt->bindValue(':s', $status);
        $stmt->execute();
        $total_mov++;
    }
}
$db->exec("COMMIT TRANSACTION");

echo "   ✅ Crédito: 500 clientes, 300 contratos, $total_mov movimentações\n\n";

// ============================================================================
// 🎬 STREAMING — 1.000 usuários, 300 títulos, 25.000 assistências
// ============================================================================
echo "🎬 Populando STREAMING...\n";

$db->exec("DELETE FROM streaming_avaliacoes");
$db->exec("DELETE FROM streaming_assistencias");
$db->exec("DELETE FROM streaming_titulos");
$db->exec("DELETE FROM streaming_usuarios");

$db->exec("BEGIN TRANSACTION");

// Usuários (1.000)
$planos = ['Basico', 'Padrao', 'Premium'];
for ($i = 0; $i < 1000; $i++) {
    $dias = rand(30, 800);
    $stmt = $db->prepare("INSERT INTO streaming_usuarios (nome, email, plano, dt_cadastro, status) VALUES (:n, :e, :p, :d, :s)");
    $stmt->bindValue(':n', "Usuario Stream " . ($i+1));
    $stmt->bindValue(':e', "stream$i@example.com");
    $stmt->bindValue(':p', $planos[rand(0, 2)]);
    $stmt->bindValue(':d', date('Y-m-d', strtotime("-$dias days")));
    $stmt->bindValue(':s', rand(1, 100) <= 78 ? 'Ativo' : 'Cancelado');
    $stmt->execute();
}

// Títulos (300)
$generos = ['Ação', 'Comédia', 'Drama', 'Terror', 'Documentário', 'Animação', 'Romance', 'Ficção Científica', 'Suspense'];
for ($i = 0; $i < 300; $i++) {
    $tipo = rand(0, 1) ? 'Filme' : 'Série';
    $stmt = $db->prepare("INSERT INTO streaming_titulos (titulo, tipo, genero, duracao_min, dt_lancamento, classificacao) VALUES (:t, :ti, :g, :d, :l, :c)");
    $stmt->bindValue(':t', "Titulo Stream $i");
    $stmt->bindValue(':ti', $tipo);
    $stmt->bindValue(':g', $generos[rand(0, count($generos)-1)]);
    $stmt->bindValue(':d', $tipo == 'Filme' ? rand(80, 180) : rand(25, 60));
    $stmt->bindValue(':l', date('Y-m-d', strtotime("-" . rand(100, 4000) . " days")));
    $stmt->bindValue(':c', ['L', '10', '12', '14', '16', '18'][rand(0, 5)]);
    $stmt->execute();
}

// Assistências (25.000)
$dispositivos = ['Smart TV', 'Celular', 'Tablet', 'Notebook', 'Console'];
for ($i = 0; $i < 25000; $i++) {
    $stmt = $db->prepare("INSERT INTO streaming_assistencias (idusuario, idtitulo, dt_assistido, minutos_assistidos, dispositivo) VALUES (:u, :t, :d, :m, :dp)");
    $stmt->bindValue(':u', rand(1, 1000));
    $stmt->bindValue(':t', rand(1, 300));
    $stmt->bindValue(':d', date('Y-m-d', strtotime("-" . rand(0, 365) . " days")));
    $stmt->bindValue(':m', rand(5, 180));
    $stmt->bindValue(':dp', $dispositivos[rand(0, count($dispositivos)-1)]);
    $stmt->execute();
}

// Avaliações (2.000)
for ($i = 0; $i < 2000; $i++) {
    $stmt = $db->prepare("INSERT INTO streaming_avaliacoes (idusuario, idtitulo, nota, dt_avaliacao) VALUES (:u, :t, :n, :d)");
    $stmt->bindValue(':u', rand(1, 1000));
    $stmt->bindValue(':t', rand(1, 300));
    $stmt->bindValue(':n', rand(1, 5));
    $stmt->bindValue(':d', date('Y-m-d', strtotime("-" . rand(0, 365) . " days")));
    $stmt->execute();
}

$db->exec("COMMIT TRANSACTION");
echo "   ✅ Streaming: 1.000 usuários, 300 títulos, 25.000 assistências, 2.000 avaliações\n\n";

// ============================================================================
// 🛒 E-COMMERCE — 800 clientes, 200 produtos, 2.500 pedidos
// ============================================================================
echo "🛒 Populando E-COMMERCE...\n";

$db->exec("DELETE FROM ecommerce_pagamentos");
$db->exec("DELETE FROM ecommerce_itens_pedido");
$db->exec("DELETE FROM ecommerce_pedidos");
$db->exec("DELETE FROM ecommerce_produtos");
$db->exec("DELETE FROM ecommerce_clientes");

$db->exec("BEGIN TRANSACTION");

// Clientes (800)
$estados = ['SP', 'RJ', 'MG', 'RS', 'PR', 'BA', 'SC', 'PE', 'CE', 'GO', 'DF', 'ES'];
for ($i = 0; $i < 800; $i++) {
    $stmt = $db->prepare("INSERT INTO ecommerce_clientes (nome, email, cpf, cidade, estado, dt_cadastro) VALUES (:n, :e, :c, :ci, :es, :d)");
    $stmt->bindValue(':n', "Cliente Ecom " . ($i+1));
    $stmt->bindValue(':e', "ecom$i@example.com");
    $stmt->bindValue(':c', sprintf('%03d.%03d.%03d-%02d', rand(0,999), rand(0,999), rand(0,999), rand(0,99)));
    $stmt->bindValue(':ci', "Cidade " . rand(1, 150));
    $stmt->bindValue(':es', $estados[rand(0, count($estados)-1)]);
    $stmt->bindValue(':d', date('Y-m-d', strtotime("-" . rand(30, 1200) . " days")));
    $stmt->execute();
}

// Produtos (200)
$categorias = ['Eletrônicos', 'Roupas', 'Casa & Decoração', 'Esporte', 'Beleza', 'Livros', 'Brinquedos', 'Alimentos'];
for ($i = 0; $i < 200; $i++) {
    $custo = round(rand(8, 800) + rand(0,99)/100, 2);
    $margem = 1.3 + rand(0, 120)/100;
    $stmt = $db->prepare("INSERT INTO ecommerce_produtos (nome, categoria, preco_custo, preco_venda, estoque) VALUES (:n, :c, :cu, :v, :e)");
    $stmt->bindValue(':n', "Produto Ecom " . ($i+1));
    $stmt->bindValue(':c', $categorias[rand(0, count($categorias)-1)]);
    $stmt->bindValue(':cu', $custo);
    $stmt->bindValue(':v', round($custo * $margem, 2));
    $stmt->bindValue(':e', rand(0, 300));
    $stmt->execute();
}

// Pedidos (2.500)
$status_pedidos = ['Entregue', 'Entregue', 'Entregue', 'Entregue', 'Entregue', 'Entregue', 'Enviado', 'Enviado', 'Processando', 'Cancelado'];
for ($i = 0; $i < 2500; $i++) {
    $stmt = $db->prepare("INSERT INTO ecommerce_pedidos (idcliente, dt_pedido, status, frete, desconto) VALUES (:c, :d, :s, :f, :de)");
    $stmt->bindValue(':c', rand(1, 800));
    $stmt->bindValue(':d', date('Y-m-d', strtotime("-" . rand(0, 400) . " days")));
    $stmt->bindValue(':s', $status_pedidos[rand(0, count($status_pedidos)-1)]);
    $stmt->bindValue(':f', round(rand(0, 4500)/100, 2));
    $stmt->bindValue(':de', rand(1, 100) <= 25 ? round(rand(500, 5000)/100, 2) : 0);
    $stmt->execute();
}

// Itens de pedido (~6.000)
$total_itens = 0;
for ($idped = 1; $idped <= 2500; $idped++) {
    $qtd_itens = rand(1, 5);
    for ($j = 0; $j < $qtd_itens; $j++) {
        $idproduto = rand(1, 200);
        $preco = $db->querySingle("SELECT preco_venda FROM ecommerce_produtos WHERE id = $idproduto");
        
        $stmt = $db->prepare("INSERT INTO ecommerce_itens_pedido (idpedido, idproduto, quantidade, preco_unitario) VALUES (:p, :pr, :q, :pu)");
        $stmt->bindValue(':p', $idped);
        $stmt->bindValue(':pr', $idproduto);
        $stmt->bindValue(':q', rand(1, 4));
        $stmt->bindValue(':pu', $preco);
        $stmt->execute();
        $total_itens++;
    }
}

// Pagamentos (~2.300)
$formas = ['Cartão Crédito', 'Cartão Crédito', 'Pix', 'Pix', 'Pix', 'Cartão Débito', 'Boleto'];
$total_pag = 0;
for ($idped = 1; $idped <= 2500; $idped++) {
    if (rand(1, 100) <= 92) {
        $total = $db->querySingle("SELECT COALESCE(SUM(quantidade * preco_unitario), 0) FROM ecommerce_itens_pedido WHERE idpedido = $idped");
        $frete = $db->querySingle("SELECT frete FROM ecommerce_pedidos WHERE id = $idped");
        $desconto = $db->querySingle("SELECT desconto FROM ecommerce_pedidos WHERE id = $idped");
        $valor_final = max(0, $total + $frete - $desconto);
        
        $stmt = $db->prepare("INSERT INTO ecommerce_pagamentos (idpedido, forma, valor, dt_pagamento, status) VALUES (:p, :f, :v, :d, :s)");
        $stmt->bindValue(':p', $idped);
        $stmt->bindValue(':f', $formas[rand(0, count($formas)-1)]);
        $stmt->bindValue(':v', round($valor_final, 2));
        $stmt->bindValue(':d', date('Y-m-d', strtotime("-" . rand(0, 400) . " days")));
        $stmt->bindValue(':s', rand(1, 100) <= 94 ? 'Aprovado' : 'Recusado');
        $stmt->execute();
        $total_pag++;
    }
}

$db->exec("COMMIT TRANSACTION");
echo "   ✅ E-commerce: 800 clientes, 200 produtos, 2.500 pedidos, $total_itens itens, $total_pag pagamentos\n\n";

// ============================================================================
// 📊 SaaS — 400 clientes, 500 assinaturas, 4.000 faturas
// ============================================================================
echo "📊 Populando SaaS...\n";

$db->exec("DELETE FROM saas_usos");
$db->exec("DELETE FROM saas_faturas");
$db->exec("DELETE FROM saas_assinaturas");
$db->exec("DELETE FROM saas_planos");
$db->exec("DELETE FROM saas_clientes");

$db->exec("BEGIN TRANSACTION");

// Clientes B2B (400)
$segmentos = ['Varejo', 'Serviços', 'Indústria', 'Saúde', 'Educação', 'Tecnologia', 'Logística', 'Financeiro'];
$tamanhos = ['Pequena', 'Pequena', 'Média', 'Média', 'Grande'];
for ($i = 0; $i < 400; $i++) {
    $stmt = $db->prepare("INSERT INTO saas_clientes (nome, empresa, segmento, tamanho, dt_cadastro) VALUES (:n, :e, :s, :t, :d)");
    $stmt->bindValue(':n', "Contato SaaS " . ($i+1));
    $stmt->bindValue(':e', "Empresa SaaS " . ($i+1));
    $stmt->bindValue(':s', $segmentos[rand(0, count($segmentos)-1)]);
    $stmt->bindValue(':t', $tamanhos[rand(0, count($tamanhos)-1)]);
    $stmt->bindValue(':d', date('Y-m-d', strtotime("-" . rand(60, 1200) . " days")));
    $stmt->execute();
}

// Planos (5)
$planos_saas = [
    ['Starter', 49.90, 5, 'Básico: 5 usuários, suporte email'],
    ['Professional', 149.90, 25, 'Intermediário: 25 usuários, suporte prioritário'],
    ['Business', 399.90, 100, 'Avançado: 100 usuários, API completa'],
    ['Enterprise', 999.90, 9999, 'Completo: ilimitado, suporte dedicado'],
    ['Custom', 1999.90, 9999, 'Personalizado: sob demanda']
];
foreach ($planos_saas as $p) {
    $stmt = $db->prepare("INSERT INTO saas_planos (nome, preco_mensal, limite_usuarios, recursos) VALUES (:n, :p, :l, :r)");
    $stmt->bindValue(':n', $p[0]); $stmt->bindValue(':p', $p[1]);
    $stmt->bindValue(':l', $p[2]); $stmt->bindValue(':r', $p[3]);
    $stmt->execute();
}

// Assinaturas (500)
for ($i = 0; $i < 500; $i++) {
    $idcliente = rand(1, 400);
    $r = rand(1, 100);
    if ($r <= 40) $idplano = 1;
    elseif ($r <= 70) $idplano = 2;
    elseif ($r <= 88) $idplano = 3;
    elseif ($r <= 97) $idplano = 4;
    else $idplano = 5;
    
    $dias = rand(60, 900);
    $dt_inicio = date('Y-m-d', strtotime("-$dias days"));
    $status = rand(1, 100) <= 82 ? 'Ativa' : 'Cancelada';
    $dt_fim = $status == 'Cancelada' ? date('Y-m-d', strtotime($dt_inicio . " +" . rand(60, 400) . " days")) : null;
    
    $stmt = $db->prepare("INSERT INTO saas_assinaturas (idcliente, idplano, dt_inicio, dt_fim, status, valor_mensal) VALUES (:c, :p, :di, :df, :s, :v)");
    $stmt->bindValue(':c', $idcliente);
    $stmt->bindValue(':p', $idplano);
    $stmt->bindValue(':di', $dt_inicio);
    $stmt->bindValue(':df', $dt_fim);
    $stmt->bindValue(':s', $status);
    $stmt->bindValue(':v', $planos_saas[$idplano-1][1]);
    $stmt->execute();
}

// Faturas (~4.000)
$total_fat = 0;
for ($idass = 1; $idass <= 500; $idass++) {
    $res = $db->querySingle("SELECT dt_inicio, dt_fim, valor_mensal FROM saas_assinaturas WHERE id = $idass", true);
    if (!$res) continue;
    
    $dt_inicio = new DateTime($res['dt_inicio']);
    $dt_fim = $res['dt_fim'] ? new DateTime($res['dt_fim']) : new DateTime();
    $valor = $res['valor_mensal'];
    
    $dt_atual = clone $dt_inicio;
    while ($dt_atual <= $dt_fim && $dt_atual <= new DateTime()) {
        $dt_venc = (clone $dt_atual)->modify('+30 days');
        $pago = rand(1, 100) <= 87;
        $dt_pag = $pago ? (clone $dt_venc)->modify("+" . rand(-3, 10) . " days")->format('Y-m-d') : null;
        $status = $pago ? 'Paga' : (rand(0,1) ? 'Pendente' : 'Atrasada');
        
        if ($dt_venc <= new DateTime()) {
            $stmt = $db->prepare("INSERT INTO saas_faturas (idassinatura, dt_vencimento, dt_pagamento, valor, status) VALUES (:a, :dv, :dp, :v, :s)");
            $stmt->bindValue(':a', $idass);
            $stmt->bindValue(':dv', $dt_venc->format('Y-m-d'));
            $stmt->bindValue(':dp', $dt_pag);
            $stmt->bindValue(':v', $valor);
            $stmt->bindValue(':s', $status);
            $stmt->execute();
            $total_fat++;
        }
        
        $dt_atual->modify('+30 days');
    }
}

// Usos (~15.000)
$metricas = ['logins', 'api_calls', 'relatorios_gerados', 'exportacoes'];
$total_usos = 0;
for ($idass = 1; $idass <= 500; $idass++) {
    $res = $db->querySingle("SELECT dt_inicio, dt_fim FROM saas_assinaturas WHERE id = $idass", true);
    if (!$res) continue;
    
    $dt_inicio = new DateTime($res['dt_inicio']);
    $dt_fim = $res['dt_fim'] ? new DateTime($res['dt_fim']) : new DateTime();
    
    $dt_atual = clone $dt_inicio;
    $dias = 0;
    while ($dt_atual <= $dt_fim && $dt_atual <= new DateTime() && $dias < 120) {
        if (rand(1, 100) <= 70) {
            $qtd_registros = rand(1, 3);
            for ($j = 0; $j < $qtd_registros; $j++) {
                $stmt = $db->prepare("INSERT INTO saas_usos (idassinatura, dt_uso, metrica, valor) VALUES (:a, :d, :m, :v)");
                $stmt->bindValue(':a', $idass);
                $stmt->bindValue(':d', $dt_atual->format('Y-m-d'));
                $stmt->bindValue(':m', $metricas[rand(0, count($metricas)-1)]);
                $stmt->bindValue(':v', rand(1, 150));
                $stmt->execute();
                $total_usos++;
            }
        }
        $dt_atual->modify('+1 day');
        $dias++;
    }
}

$db->exec("COMMIT TRANSACTION");
echo "   ✅ SaaS: 400 clientes, 5 planos, 500 assinaturas, $total_fat faturas, $total_usos usos\n\n";

// ============================================================================
// RESUMO FINAL
// ============================================================================
$db->close();

echo "╔════════════════════════════════════════════════════════════╗\n";
echo "║  ✅ BASES POPULADAS COM SUCESSO!                          ║\n";
echo "╠════════════════════════════════════════════════════════════╣\n";
echo "║  💰 Crédito:    500 clientes, 300 contratos, ~18k movs    ║\n";
echo "║  🎬 Streaming:  1.000 usuários, 300 títulos, 25k assist   ║\n";
echo "║  🛒 E-commerce: 800 clientes, 2.500 pedidos, 6k itens     ║\n";
echo "║  📊 SaaS:       400 clientes, 500 assinaturas, 4k faturas ║\n";
echo "║                                                           ║\n";
echo "║  📊 TOTAL: ~70.000 registros para análise!                ║\n";
echo "╚════════════════════════════════════════════════════════════╝\n";
?>