
SELECT 'fornecedor' AS tabela, COUNT(*) AS registros
FROM public.fornecedor

UNION ALL

SELECT 'produtos_filial', COUNT(*)
FROM public.produtos_filial

UNION ALL

SELECT 'pedido_compra', COUNT(*)
FROM public.pedido_compra

UNION ALL

SELECT 'entradas_mercadoria', COUNT(*)
FROM public.entradas_mercadoria

UNION ALL

SELECT 'venda', COUNT(*)
FROM public.venda;



-- ==========================================
-- VALIDACAO 2: Estrutura e tipos de dados
-- das cinco tabelas
-- ==========================================

SELECT
    table_name AS tabela,
    ordinal_position AS posicao,
    column_name AS coluna,
    data_type AS tipo_dado,
    is_nullable AS permite_nulo,
    column_default AS valor_padrao
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN (
      'fornecedor',
      'produtos_filial',
      'pedido_compra',
      'entradas_mercadoria',
      'venda'
  )
ORDER BY table_name, ordinal_position;

