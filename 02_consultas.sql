
-- =============================================
-- CASE SYSTOCK
-- PARTE 2 - CONSULTAS SQL
-- CONSULTA 1: Vendas por produto - Fevereiro/2025
-- =============================================

SELECT
    produto_id,

    SUM(qtde_vendida) AS quantidade_total,

    ROUND(
        SUM(qtde_vendida * valor_unitario)::NUMERIC,
        2
    ) AS valor_total_rs

FROM public.venda

WHERE data_emissao >= DATE '2025-02-01'
  AND data_emissao < DATE '2025-03-01'

GROUP BY produto_id

ORDER BY valor_total_rs DESC;




-- ==========================================
-- CONSULTA 2: Produtos requisitados,
-- mas sem registro de recebimento
-- ==========================================

SELECT
    pc.pedido_id,
    pc.ordem_compra,
    pc.produto_id,
    pc.descricao_produto,
    pc.qtde_pedida
FROM public.pedido_compra pc
WHERE pc.qtde_pedida > 0
  AND pc.ordem_compra <> 0
  AND NOT EXISTS (
      SELECT 1
      FROM public.entradas_mercadoria em
      WHERE em.ordem_compra = pc.ordem_compra
        AND em.produto_id = pc.produto_id
        AND em.item = pc.item
        AND em.filial_id = pc.filial_id
  )
ORDER BY pc.pedido_id;

        
        
        
-- ==========================================
-- CONSULTA 3: Conciliacao entre pedidos
-- e recebimentos - ordens validas
-- ==========================================

WITH recebimentos AS (
    SELECT
        ordem_compra,
        produto_id,
        item,
        filial_id,
        SUM(COALESCE(qtde_recebida, 0))
            AS total_recebido
    FROM public.entradas_mercadoria
    GROUP BY
        ordem_compra,
        produto_id,
        item,
        filial_id
)

SELECT
    pc.pedido_id,
    pc.ordem_compra,
    pc.produto_id,
    pc.qtde_pedida,

    COALESCE(r.total_recebido, 0)
        AS qtde_recebida,

    pc.qtde_pedida -
    COALESCE(r.total_recebido, 0)
        AS diferenca,

    CASE
        WHEN r.ordem_compra IS NULL
            THEN 'SEM RECEBIMENTO'
        WHEN COALESCE(r.total_recebido, 0) = 0
            THEN 'SEM QUANTIDADE RECEBIDA'
        WHEN r.total_recebido < pc.qtde_pedida
            THEN 'PARCIAL'
        WHEN r.total_recebido = pc.qtde_pedida
            THEN 'COMPLETO'
        ELSE 'EXCEDENTE'
    END AS situacao

FROM public.pedido_compra pc


LEFT JOIN recebimentos r
    ON pc.ordem_compra = r.ordem_compra
   AND pc.produto_id = r.produto_id
   AND pc.item = r.item
   AND pc.filial_id = r.filial_id

WHERE pc.ordem_compra <> 0

ORDER BY pc.pedido_id;





-- ==========================================
-- CONSULTA 4: Resumo da conciliacao
-- entre pedidos e recebimentos
-- ==========================================

WITH recebimentos AS (
    SELECT
        ordem_compra,
        produto_id,
        item,
        filial_id,
        SUM(COALESCE(qtde_recebida, 0))
            AS total_recebido
    FROM public.entradas_mercadoria
    GROUP BY
        ordem_compra,
        produto_id,
        item,
        filial_id
),
conciliacao AS (
    SELECT
        pc.pedido_id,
        CASE
            WHEN r.ordem_compra IS NULL
                THEN 'SEM RECEBIMENTO'
            WHEN COALESCE(r.total_recebido, 0) = 0
                THEN 'SEM QUANTIDADE RECEBIDA'
            WHEN r.total_recebido < pc.qtde_pedida
                THEN 'PARCIAL'
            WHEN r.total_recebido = pc.qtde_pedida
                THEN 'COMPLETO'
            ELSE 'EXCEDENTE'
        END AS situacao
    FROM public.pedido_compra pc
    LEFT JOIN recebimentos r
        ON pc.ordem_compra = r.ordem_compra
       AND pc.produto_id = r.produto_id
       AND pc.item = r.item
       AND pc.filial_id = r.filial_id
    WHERE pc.ordem_compra <> 0
)

SELECT
    situacao,
    COUNT(*) AS quantidade_pedidos
FROM conciliacao
GROUP BY situacao
ORDER BY quantidade_pedidos DESC;
