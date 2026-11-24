# Case Técnico Systock
## Analista de Integração de Dados — Implantação

### Sobre o projeto

Este repositório apresenta a solução desenvolvida para o case técnico da Systock, contemplando importação de dados, consultas SQL, transformações, integridade referencial e estratégia de validação com o cliente.

### Tecnologias utilizadas

- PostgreSQL 17
- DBeaver Community 26.2.5
- SQL e PL/pgSQL
- Microsoft Excel e arquivos CSV
- GitHub para versionamento e disponibilização

### Base de dados

A base original contém cinco conjuntos de dados, totalizando 122 registros:

| Tabela | Registros |
|---|---:|
| fornecedor | 20 |
| produtos_filial | 20 |
| pedido_compra | 29 |
| entradas_mercadoria | 20 |
| venda | 33 |

### Funcionalidades desenvolvidas

**Parte 1 — Importação**

Criação das tabelas, tratamento de arquivos CSV, conversão de datas e decimais, correção de inconsistências estruturais e validação das cargas.

**Parte 2 — Consultas SQL**

Análise de vendas por produto em fevereiro de 2025 e conciliação entre pedidos de compra e recebimentos.

**Parte 3 — Transformações**

Concatenação de identificadores e descrições, formatação de datas, filtros de frequência de requisições e implementação de trigger para preenchimento automático do identificador numérico de fornecedor.

**Parte 4 — Validação com o cliente**

Roteiro de homologação, técnicas de conferência, análise de divergências e critérios de aceite.

### Principais resultados da análise

- 14 registros de vendas em fevereiro de 2025.
- 10 pedidos com recebimento parcial.
- 7 pedidos com recebimento excedente.
- 1 pedido com recebimento completo.
- 11 pedidos com ordem de compra zerada, exigindo validação específica.
- 20 produtos com fornecedores válidos.

Os resultados relativos a recebimentos correspondem às 18 ordens com identificador diferente de zero.

### Arquivos do projeto

- `01_documentacao_importacao.md` — Procedimento de importação e tratamentos.
- `02_consultas.sql` — Consultas de vendas e conciliação de pedidos.
- `03_transformacoes.sql` — Transformações, função e trigger.
- `04_validacoes.sql` — Consultas de integridade e estrutura.
- `04_validacao_cliente.md` — Estratégia de validação com o cliente.
- `estrutura_tabelas.csv` — Dicionário de dados extraído do PostgreSQL.
- `systock_case_final.backup` — Backup do banco analisado.

### Restauração do banco

O arquivo `systock_case_final.backup` foi gerado utilizando `pg_dump`, no formato Custom.

Para restaurá-lo:

1. Instale o PostgreSQL e uma ferramenta de administração compatível.
2. Crie um banco vazio chamado `systock_case`.
3. Utilize o `pg_restore` ou a função de restauração do DBeaver.
4. Selecione o arquivo `systock_case_final.backup`.
5. Restaure a estrutura e os dados.
6. Execute as consultas de validação para verificar os registros importados.

O backup contém o estado analisado do banco. Os scripts SQL documentam as consultas, transformações e alterações realizadas durante o desenvolvimento; comandos de criação ou alteração estrutural não devem ser reaplicados indiscriminadamente após a restauração.

### Observações

A solução preserva os identificadores originais e documenta as inconsistências encontradas na base de teste.

As divergências de recebimento e os registros com ordem de compra zerada foram mantidos para validação das regras de negócio com o cliente.