
-- ==========================================
-- CASE SYSTOCK
-- PARTE 3 - TRANSFORMACOES DE DADOS
-- CONSULTA 1: Produto e data formatados
-- ==========================================

SELECT
    CONCAT(
        produto_id,
        ' - ',
        descricao_produto
    ) AS produto,

    qtde_pedida AS qtde_requisitada,

    TO_CHAR(
        data_pedido,
        'DD/MM/YYYY'
    ) AS data_solicitacao

FROM public.pedido_compra

ORDER BY data_pedido, produto_id;





-- ==========================================
-- CONSULTA 2: Produtos requisitados
-- mais de 10 vezes no periodo
-- ==========================================

SELECT
    pc.produto_id,
    pc.descricao_produto,

    COUNT(*) AS numero_requisicoes,

    SUM(pc.qtde_pedida) AS quantidade_total

FROM public.pedido_compra pc

WHERE pc.data_pedido >= DATE '2025-01-01'
  AND pc.data_pedido < DATE '2025-03-01'

GROUP BY
    pc.produto_id,
    pc.descricao_produto

HAVING COUNT(*) > 10

ORDER BY numero_requisicoes DESC;




-- ==========================================
-- CONSULTA 3: Frequencia das requisicoes
-- por produto
-- ==========================================

SELECT
    produto_id,
    descricao_produto,
    COUNT(*) AS numero_requisicoes,
    SUM(qtde_pedida) AS quantidade_total
FROM public.pedido_compra
WHERE data_pedido >= DATE '2025-01-01'
  AND data_pedido < DATE '2025-03-01'
GROUP BY produto_id, descricao_produto
ORDER BY numero_requisicoes DESC,
         produto_id;




-- ==========================================
-- CONSULTA 4: Validacao dos fornecedores
-- associados aos produtos
-- ==========================================

SELECT
    p.idproduto,
    p.descricao,
    p.idfornecedor,
    f.razao_social,

    CASE
        WHEN p.idfornecedor IS NULL
            THEN 'SEM FORNECEDOR'
        WHEN f.idfornecedor IS NULL
            THEN 'FORNECEDOR NAO CADASTRADO'
        ELSE 'FORNECEDOR VALIDO'
    END AS situacao

FROM public.produtos_filial p

LEFT JOIN public.fornecedor f
    ON p.idfornecedor = f.idfornecedor

ORDER BY p.idproduto;




-- CONSULTA 5: Resumo da integridade dos fornecedores

SELECT
    COUNT(*) AS total_produtos,
    COUNT(*) FILTER (
        WHERE f.idfornecedor IS NOT NULL
    ) AS fornecedores_validos,
    COUNT(*) FILTER (
        WHERE f.idfornecedor IS NULL
    ) AS fornecedores_invalidos

FROM public.produtos_filial p

LEFT JOIN public.fornecedor f
    ON p.idfornecedor = f.idfornecedor;




-- ==========================================
-- CONSULTA 6: Identificador numerico
-- para fornecedores
-- ==========================================

ALTER TABLE public.fornecedor
ADD COLUMN idfornecedor_num BIGINT
GENERATED ALWAYS AS IDENTITY;

ALTER TABLE public.fornecedor
ADD CONSTRAINT fornecedor_num_unique
UNIQUE (idfornecedor_num);




-- ==========================================
-- CONSULTA 7: Verificar IDs numericos
-- gerados para os fornecedores
-- ==========================================

SELECT
    idfornecedor,
    idfornecedor_num,
    razao_social
FROM public.fornecedor
ORDER BY idfornecedor_num;




-- ==========================================
-- ETAPA 8: Adicionar identificador numerico
-- na tabela de produtos
-- ==========================================

ALTER TABLE public.produtos_filial
ADD COLUMN idfornecedor_num BIGINT;





-- ==========================================
-- ETAPA 9: Atualizar produtos existentes
-- ==========================================

UPDATE public.produtos_filial p
SET idfornecedor_num = f.idfornecedor_num
FROM public.fornecedor f
WHERE p.idfornecedor = f.idfornecedor;





SELECT
    p.idproduto,
    p.idfornecedor,
    p.idfornecedor_num,
    f.idfornecedor_num AS id_num_fornecedor
FROM public.produtos_filial p
LEFT JOIN public.fornecedor f
    ON p.idfornecedor = f.idfornecedor
ORDER BY p.idproduto;




-- ==========================================
-- ETAPA 10: Criar chave estrangeira
-- entre produtos e fornecedores
-- ==========================================

ALTER TABLE public.produtos_filial
ADD CONSTRAINT fk_produto_fornecedor_num
FOREIGN KEY (idfornecedor_num)
REFERENCES public.fornecedor(idfornecedor_num);




-- ==========================================
-- ETAPA 11: Funcao para preencher
-- o identificador numerico do fornecedor
-- ==========================================

CREATE OR REPLACE FUNCTION public.fn_definir_fornecedor_num()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.idfornecedor IS NULL THEN
        RAISE EXCEPTION
            'Produto sem fornecedor informado';
    END IF;

    SELECT f.idfornecedor_num
    INTO NEW.idfornecedor_num
    FROM public.fornecedor f
    WHERE f.idfornecedor = NEW.idfornecedor;

    IF NEW.idfornecedor_num IS NULL THEN
        RAISE EXCEPTION
            'Fornecedor % nao cadastrado',
            NEW.idfornecedor;
    END IF;

    RETURN NEW;
END;
$$;




-- ==========================================
-- ETAPA 12: Criar trigger de fornecedor
-- ==========================================

CREATE TRIGGER trg_definir_fornecedor_num
BEFORE INSERT OR UPDATE OF idfornecedor
ON public.produtos_filial
FOR EACH ROW
EXECUTE FUNCTION public.fn_definir_fornecedor_num();






-- ==========================================
-- ETAPA 13: Teste controlado da trigger
-- ==========================================

BEGIN;

INSERT INTO public.produtos_filial (
    filial_id,
    idproduto,
    descricao,
    estoque,
    preco_unitario,
    preco_compra,
    preco_venda,
    idfornecedor
)
VALUES (
    1,
    'TESTE_TRIGGER',
    'Produto de teste da trigger',
    0,
    0,
    0,
    0,
    'F8'
);

SELECT
    idproduto,
    idfornecedor,
    idfornecedor_num
FROM public.produtos_filial
WHERE idproduto = 'TESTE_TRIGGER';

ROLLBACK;




-- ==========================================
-- ETAPA 14: Validacao final da trigger
-- ==========================================

-- Verificar quantidade de produtos
-- e ausencia do registro de teste

SELECT
    COUNT(*) AS total_produtos,
    COUNT(*) FILTER (
        WHERE idproduto = 'TESTE_TRIGGER'
    ) AS produtos_teste
FROM public.produtos_filial;


-- Verificar a chave estrangeira

SELECT
    conname AS nome_restricao,
    pg_get_constraintdef(oid) AS definicao
FROM pg_constraint
WHERE conrelid = 'public.produtos_filial'::regclass
  AND contype = 'f';
