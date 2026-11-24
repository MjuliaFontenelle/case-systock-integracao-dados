# Parte 4 — Estratégia de Validação com o Cliente
## Case Técnico Systock

### 1. Objetivo

Validar a integridade, consistência e confiabilidade dos dados importados para o PostgreSQL, com foco nas operações de fevereiro de 2025.

A validação será conduzida por meio da comparação entre os arquivos de origem, as informações armazenadas no banco de dados e as regras de negócio confirmadas pelo cliente.

### 2. Principais pontos de validação

**2.1. Integridade da carga**

- Conferir as quantidades de registros importados por tabela.
- Verificar identificadores duplicados e campos obrigatórios.
- Confirmar a conversão de datas e valores monetários.
- Validar os relacionamentos entre produtos e fornecedores.

**2.2. Vendas de fevereiro de 2025**

- Conferir os registros de vendas correspondentes ao período.
- Validar as quantidades comercializadas por produto.
- Confirmar os valores totais calculados a partir da quantidade vendida e do valor unitário.
- Comparar os resultados com os relatórios de origem do cliente.

**2.3. Pedidos de compra e recebimentos**

A análise inicial identificou, entre os 18 pedidos com ordem de compra diferente de zero:

- 10 pedidos com recebimento parcial.
- 7 pedidos com recebimento excedente.
- 1 pedido com recebimento completo.

Também foram identificados 11 pedidos com `ordem_compra = 0`, que não foram incluídos na conciliação automática por ausência de um identificador de relacionamento confiável.

Essas divergências serão apresentadas ao cliente para esclarecimento das regras de recebimento, eventuais tolerâncias, entregas parciais e procedimentos de regularização.

### 3. Questões para validação com o cliente

1. Uma ordem de compra pode receber mercadorias em várias notas fiscais?
2. O sistema permite recebimentos superiores às quantidades solicitadas?
3. O que representa uma ordem de compra com identificador zero?
4. Como devem ser tratados pedidos parcialmente atendidos?
5. Qual é a fonte oficial para confirmar as quantidades efetivamente recebidas?
6. Qual critério determina o período de competência de vendas e recebimentos?
7. Quem é responsável por aprovar as divergências identificadas?



### 4. Técnicas para garantir a exatidão e a precisão dos dados

**4.1. Reconciliação entre origem e destino**

Comparar a quantidade de registros e os totais calculados no PostgreSQL com os arquivos originais fornecidos pelo cliente.

A carga inicial apresentou:

| Tabela | Registros importados |
|---|---:|
| fornecedor | 20 |
| produtos_filial | 20 |
| pedido_compra | 29 |
| entradas_mercadoria | 20 |
| venda | 33 |
| **Total** | **122** |

**4.2. Validação de tipos e formatos**

Verificar se datas, identificadores, quantidades e valores monetários foram importados corretamente.

Durante a implantação, foi identificada uma interpretação incorreta dos separadores decimais na tabela de produtos. O arquivo de carga foi corrigido, e os valores foram novamente conferidos no PostgreSQL.

**4.3. Integridade referencial**

Verificar se os produtos possuem fornecedores cadastrados e se os identificadores numéricos gerados preservam os relacionamentos existentes.

A análise confirmou 20 produtos com fornecedores válidos e nenhum relacionamento inválido.

**4.4. Validação das regras de negócio**

Conciliar as quantidades pedidas e recebidas, classificando os pedidos como completos, parciais ou excedentes.

Registros com ordem de compra zerada serão tratados como pendências de identificação, sem associação automática a recebimentos.

**4.5. Validação por amostragem e tratamento de divergências**

Conferir registros individuais com os documentos de origem, especialmente os que apresentam divergências.

Cada inconsistência deverá ser documentada com o identificador do registro, valor de origem, valor de destino, impacto identificado, responsável pela análise e decisão tomada.

### 5. Consultas SQL de apoio

Durante a reunião, serão utilizadas consultas previamente preparadas para:

1. Conferir a quantidade de registros importados por tabela.
2. Consultar o total de vendas por produto em fevereiro de 2025.
3. Identificar pedidos sem registro de recebimento.
4. Comparar quantidades pedidas e recebidas.
5. Listar pedidos com ordem de compra zerada.
6. Identificar relacionamentos inválidos entre produtos e fornecedores.

Os scripts correspondentes estão documentados nos arquivos `02_consultas.sql`, `03_transformacoes.sql` e `04_validacoes.sql`.

### 6. Critérios de aceite

A validação será considerada concluída quando:

- Os totais das cargas corresponderem aos arquivos de origem.
- Os valores monetários e as datas estiverem corretos.
- As regras de cálculo e os critérios de associação entre pedidos e recebimentos forem aprovados pelo cliente.
- As divergências forem corrigidas ou formalmente justificadas.
- As pendências remanescentes tiverem responsáveis e encaminhamentos definidos.
- O responsável de negócio confirmar o aceite, com registro da evidência.

### 7. Encerramento da validação

Ao final da reunião, será elaborado um registro contendo os resultados apresentados, divergências identificadas, decisões do cliente, pendências e responsáveis.

A homologação deverá ser formalizada somente após a aprovação dos critérios de aceite estabelecidos.