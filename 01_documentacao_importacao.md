# Parte 1 — Documentação do Processo de Importação

## Case Técnico Systock — Analista de Integração de Dados

### 1. Objetivo

Realizar a importação dos dados fornecidos em planilha Excel para um banco PostgreSQL local, preservando a estrutura dos registros e aplicando os tratamentos necessários para garantir sua integridade e consistência.

O processo contemplou cinco tabelas: `fornecedor`, `produtos_filial`, `pedido_compra`, `entradas_mercadoria` e `venda`.

### 2. Ferramentas utilizadas

- **Microsoft Excel:** inspeção da planilha original, separação das abas e preparação dos arquivos CSV.
- **Bloco de Notas:** inspeção dos arquivos CSV e padronização dos separadores decimais.
- **PostgreSQL 17:** banco de dados relacional utilizado para armazenamento.
- **DBeaver Community 26.2.5:** criação das tabelas, configuração das importações, execução dos scripts SQL e validação dos registros.

### 3. Estrutura da origem e destino

A fonte de dados utilizada foi a planilha `base_teste_systock.xlsx`, composta pelas abas:

| Aba | Registros | Colunas importadas |
|---|---:|---|
| fornecedor | 20 | `idfornecedor`, `razao_social` |
| produtos_filial | 20 | `filial_id`, `idproduto`, `descricao`, `estoque`, `preco_unitario`, `preco_compra`, `preco_venda`, `idfornecedor` |
| pedido_compra | 29 | `pedido_id`, `data_pedido`, `item`, `produto_id`, `descricao_produto`, `ordem_compra`, `qtde_pedida`, `filial_id`, `data_entrega`, `qtde_entregue`, `preco_compra`, `fornecedor_id` |
| entradas_mercadoria | 20 | `data_entrada`, `nro_nfe`, `item`, `produto_id`, `descricao_produto`, `ordem_compra`, `qtde_recebida`, `filial_id`, `custo_unitario` |
| venda | 33 | `venda_id`, `data_emissao`, `horariomov`, `produto_id`, `qtde_vendida`, `valor_unitario`, `filial_id`, `item`, `unidade_medida` |

Total de registros importados: **122**.

### 4. Procedimento de importação

**4.1. Preparação da origem**

Cada aba da planilha original foi analisada e exportada individualmente para CSV UTF-8.

Foram preservados os cabeçalhos e os registros relevantes para cada tabela.

**4.2. Tratamento de dados**

Foram aplicados os seguintes tratamentos:

- Remoção de linhas vazias excedentes nos arquivos de importação.
- Separação de dados adicionais sem cabeçalho encontrados na aba `pedido_compra`, preservando o arquivo original para investigação.
- Conversão dos separadores decimais de vírgula para ponto nos arquivos CSV, quando aplicável.
- Padronização das datas de vendas para `YYYY-MM-DD`.
- Preservação dos identificadores e das quantidades originais para análise posterior de inconsistências.

**4.3. Preparação do PostgreSQL**

Foi criado o banco de dados `systock_case`, com as cinco tabelas previstas no desafio.

Durante a criação das estruturas, foram identificadas inconsistências no SQL fornecido, incluindo referências a colunas inexistentes em determinadas definições de chave primária.

As estruturas foram ajustadas para permitir sua execução no PostgreSQL, preservando os campos necessários às consultas.

Na tabela `entradas_mercadoria`, foi incluído o campo `ordem_compra`, necessário para relacionar entradas e pedidos.

**4.4. Carga pelo DBeaver**

Para cada tabela, foi utilizado o assistente de importação de dados do DBeaver, configurando:

- Origem: arquivo CSV correspondente.
- Codificação: UTF-8.
- Delimitador: ponto e vírgula (`;`).
- Primeira linha: cabeçalho.
- Destino: tabela correspondente no esquema `public`.
- Mapeamento: associação entre as colunas do CSV e do PostgreSQL.

As verificações de integridade foram mantidas habilitadas.

### 5. Ajustes e correções realizados

**5.1. Conversão incorreta de valores monetários**

Na primeira importação de `produtos_filial`, foi identificada interpretação incorreta dos separadores decimais.

O preço de compra do produto P1, originalmente R$ 144,13, foi carregado incorretamente.

O CSV foi corrigido com ponto decimal e a carga refeita. Após a correção, os valores foram conferidos novamente no PostgreSQL.

**5.2. Estrutura irregular na aba de pedidos**

A planilha de pedidos apresentava células adicionais sem cabeçalho e linhas vazias excedentes.

Foi criado um CSV contendo somente as colunas identificadas no cabeçalho principal e os 29 pedidos correspondentes.

Os dados adicionais foram mantidos no arquivo original para análise, sem serem incorporados automaticamente à tabela de destino.

**5.3. Campo `qtde_pendente`**

O campo existe na estrutura de `pedido_compra`, mas não constava no CSV de origem.

Foi mantido o valor padrão definido na tabela, sem considerá-lo evidência de que os pedidos estavam integralmente atendidos.

As pendências foram analisadas posteriormente por meio da conciliação entre pedidos e recebimentos.

**5.4. Ordens de compra zeradas**

Foram identificados 11 registros com `ordem_compra = 0`.

Esses registros foram preservados e separados das conciliações automáticas que dependem de uma ordem de compra válida.

### 6. Validação após a importação

Foram realizadas consultas SQL para conferir:

- Quantidade de registros por tabela.
- Unicidade de identificadores.
- Faixas de valores monetários.
- Integridade dos relacionamentos entre produtos e fornecedores.
- Correspondência de registros específicos com os arquivos de origem.
- Consistência entre pedidos de compra e entradas de mercadoria.

Os totais de carga foram confirmados:

| Tabela | Registros |
|---|---:|
| fornecedor | 20 |
| produtos_filial | 20 |
| pedido_compra | 29 |
| entradas_mercadoria | 20 |
| venda | 33 |
| **Total** | **122** |

### 7. Considerações finais

A importação foi concluída com os 122 registros esperados.

As inconsistências identificadas foram tratadas quando relacionadas a formatos e estruturas de importação ou preservadas para validação com o cliente quando relacionadas a regras de negócio.

A abordagem adotada priorizou rastreabilidade, preservação da origem, conferência dos resultados e documentação dos tratamentos realizados.

### 8. Dicionário de dados

A estrutura final das tabelas foi extraída diretamente do catálogo `information_schema.columns` do PostgreSQL.

O arquivo `estrutura_tabelas.csv` apresenta as colunas das cinco tabelas, seus tipos de dados, a possibilidade de valores nulos e os valores padrão.

A extração contempla também as modificações estruturais realizadas durante a implementação, incluindo os identificadores numéricos de fornecedores.