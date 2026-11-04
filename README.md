# Trabalho de Banco de Dados — ByteStore

**Domínio:** gestão de uma loja fictícia de informática.  
**SGBD:** MySQL 8.0 ou superior.  
**Objetivo:** organizar clientes, catálogo, fornecedores, pedidos, itens e pagamentos.

## 1. Domínio do banco de dados
A ByteStore é uma loja fictícia que comercializa periféricos, hardware, monitores, armazenamento e áudio. O banco controla o cadastro de clientes e fornecedores, o catálogo, o estoque, os pedidos, seus itens e os pagamentos.

## 2. Contextualização: problemas sem SGBD relacional
Sem um SGBD, a empresa dependeria de planilhas e arquivos separados. Isso causaria:
- duplicidade de clientes, produtos e fornecedores;
- divergência de preços e estoque entre planilhas;
- dificuldade para descobrir quais itens pertencem a cada pedido;
- risco de perder ou sobrescrever registros;
- consultas demoradas para calcular faturamento e vendas;
- ausência de integridade entre pedido, cliente, produto e pagamento;
- dificuldade de controlar acessos, backups e recuperação de dados.

## 3. Proposta de melhoria
Adotar MySQL, um SGBD relacional, centralizando os dados em tabelas relacionadas por chaves primárias e estrangeiras. Restrições `NOT NULL`, `UNIQUE`, `CHECK` e `FOREIGN KEY` reduzem inconsistências. Consultas SQL permitem relatórios rápidos; backups/dumps permitem recuperação e transporte do banco.

## 4. Modelagem lógica

### Tabelas, campos e tipos

| Tabela | Campos |
|---|---|
| clientes | id_cliente INT PK AI; nome VARCHAR(100); email VARCHAR(120) UNIQUE; telefone VARCHAR(20); cidade VARCHAR(80); data_cadastro DATE |
| categorias | id_categoria INT PK AI; nome VARCHAR(60) UNIQUE; descricao VARCHAR(255) |
| fornecedores | id_fornecedor INT PK AI; razao_social VARCHAR(120); cnpj CHAR(14) UNIQUE; email VARCHAR(120); cidade VARCHAR(80) |
| produtos | id_produto INT PK AI; nome VARCHAR(120); descricao VARCHAR(255); preco DECIMAL(10,2); estoque INT; id_categoria INT FK |
| produto_fornecedor | id_produto INT PK/FK; id_fornecedor INT PK/FK; codigo_no_fornecedor VARCHAR(40); custo_compra DECIMAL(10,2) |
| pedidos | id_pedido INT PK AI; id_cliente INT FK; data_pedido DATETIME; status VARCHAR(20) |
| itens_pedido | id_item INT PK AI; id_pedido INT FK; id_produto INT FK; quantidade INT; preco_unitario DECIMAL(10,2); UNIQUE(id_pedido,id_produto) |
| pagamentos | id_pagamento INT PK AI; id_pedido INT FK UNIQUE; forma_pagamento VARCHAR(20); valor DECIMAL(10,2); data_pagamento DATETIME; status VARCHAR(20) |
| produto_tags | id_produto INT PK/FK; tag VARCHAR(40) PK |
| produto_compatibilidades | id_produto INT PK/FK; plataforma VARCHAR(60) PK |

**AI** = AUTO_INCREMENT; **PK** = chave primária; **FK** = chave estrangeira.

### Relacionamentos e cardinalidades
- categorias 1:N produtos — uma categoria pode classificar vários produtos; cada produto pertence a uma categoria.
- clientes 1:N pedidos — um cliente pode fazer vários pedidos; cada pedido pertence a um cliente.
- pedidos 1:N itens_pedido — um pedido possui um ou mais itens; cada item pertence a um pedido.
- produtos 1:N itens_pedido — um produto pode aparecer em vários itens de pedidos.
- pedidos 1:0..1 pagamentos — cada pedido pode ter no máximo um registro de pagamento; cada pagamento pertence a um pedido.
- produtos N:N fornecedores — resolvido pela tabela associativa produto_fornecedor.
- produtos 1:N produto_tags — cada produto pode ter várias tags.
- produtos 1:N produto_compatibilidades — cada produto pode ser compatível com várias plataformas.

## 5. Formas Normais

### 1FN — Primeira Forma Normal
Cada campo contém um único valor atômico, sem listas ou grupos repetidos. Por isso, tags e plataformas não são armazenadas como texto separado por vírgulas dentro de `produtos`; cada valor fica em uma linha própria nas tabelas `produto_tags` e `produto_compatibilidades`.

### 2FN — Segunda Forma Normal
A tabela deve estar na 1FN e todo atributo não-chave deve depender da chave inteira. Na tabela associativa `produto_fornecedor`, a chave é composta por `(id_produto,id_fornecedor)`: `codigo_no_fornecedor` e `custo_compra` descrevem a associação entre aquele produto e aquele fornecedor, não apenas uma das partes. Nas tabelas de tags e compatibilidades, a chave composta identifica exatamente cada associação.

### 3FN — Terceira Forma Normal
A tabela deve estar na 2FN e não possuir dependências transitivas de atributos não-chave. Os dados da categoria ficam em `categorias`, os dados do cliente em `clientes` e os dados do fornecedor em `fornecedores`; `produtos` guarda somente a chave da categoria, evitando repetir o nome/descrição da categoria em cada produto. O pedido guarda o ID do cliente, sem repetir e-mail e cidade do cliente.

### 4FN — Quarta Forma Normal
A tabela deve estar na 3FN e não conter dependências multivaloradas independentes. Um produto pode ter várias tags e várias compatibilidades, e essas listas são independentes. Se fossem colocadas juntas em uma única tabela, haveria combinações artificiais (produto × tag × plataforma) e redundância. A separação em `produto_tags` e `produto_compatibilidades` elimina essa anomalia.

## 6. Scripts SQL e carga de dados
- `bytestore.sql`: cria o banco, as 10 tabelas, restrições e insere pelo menos 5 registros em cada tabela.
- `consultas.sql`: contém 15 consultas com `INNER JOIN`, `LEFT JOIN`, `WHERE`, `LIKE`, `BETWEEN`, `GROUP BY`, `ORDER BY`, `SUM`, `COUNT` e `GROUP_CONCAT`.

### Como executar
1. Instale o MySQL Server e o MySQL Workbench.
2. Abra o Workbench e conecte-se ao servidor local.
3. Abra `bytestore.sql` em **File > Open SQL Script**.
4. Execute o script pelo ícone de raio. Ele cria o schema `bytestore` e carrega os dados.
5. Abra `consultas.sql` e execute as consultas.
6. Para conferir a carga: `USE bytestore; SHOW TABLES;` e `SELECT COUNT(*) FROM nome_da_tabela;`.

### Respostas esperadas das consultas
1. Lista os 10 produtos com suas categorias.
2. Lista os cinco produtos com preço acima de R$ 300, em ordem decrescente.
3. Ana Souza — ana@email.com.
4. Pedidos 1, 2, 3 e 4.
5. Pedido 1: R$ 379,70; 2: R$ 849,70; 3: R$ 559,80; 4: R$ 1.349,80; 5: R$ 2.429,80.
6. Faturamento aprovado: R$ 4.219,00.
7. Periféricos: 3; Hardware: 3; Armazenamento: 2; Monitores: 1; Áudio: 1.
8. Ana: pedidos 1 e 4; Bruno: 2; Carla: 3; Eduarda: 5. Diego não possui pedido.
9. GPU: 5; Monitor: 8; HD Externo: 9; Fonte: 10 unidades.
10. Exibe os cinco pagamentos e respectivos clientes, formas e status.
11. HD Externo 2TB — R$ 529,90.
12. Exibe 11 associações produto-fornecedor; Mouse Gamer X1 possui dois fornecedores.
13. Lista sete produtos acima de R$ 200, do mais caro ao mais barato.
14. Mouse Gamer X1: 2; Memória RAM 16GB: 2; demais produtos: 1 unidade cada.
15. Lista cada produto e suas tags cadastradas.

> Observação: as respostas textuais resumem o resultado. Para evidenciar a execução, rode cada consulta no Workbench e capture a grade de resultados.

## 7. Como gerar o dump (estrutura + dados)

### Pelo MySQL Workbench
1. Abra o Workbench e conecte ao servidor.
2. Vá em **Server > Data Export**.
3. Marque o schema `bytestore`.
4. Selecione **Dump Structure and Data**.
5. Escolha **Export to Self-Contained File** e indique `bytestore_dump.sql`.
6. Clique em **Start Export**.
7. Confira se o arquivo foi criado e se contém `CREATE TABLE` e `INSERT INTO`.

### Pelo terminal (alternativa)
```bash
mysqldump -u root -p --databases bytestore --routines --triggers --events > bytestore_dump.sql
```
Digite a senha quando solicitado. Para restaurar:
```bash
mysql -u root -p < bytestore_dump.sql
```

## 8. Git e entrega

No terminal, entre na pasta do projeto e execute:
```bash
git init
git add bytestore.sql consultas.sql README.md modelagem.png
git commit -m "Adiciona projeto de banco de dados ByteStore"
git branch -M main
git remote add origin https://github.com/SEU-USUARIO/SEU-REPOSITORIO.git
git push -u origin main
```
Se o repositório já existir e já estiver conectado, não repita `git remote add origin`; use `git add`, `git commit` e `git push`.

## 9. Envio no Classroom
1. Entre no Classroom e abra a atividade.
2. Clique em **Adicionar ou criar > Link** e cole o endereço do repositório GitHub.
3. Anexe também `modelagem.png` como imagem/arquivo, se a atividade permitir. Se o professor exigir print do Workbench, abra o diagrama no Workbench, ajuste o zoom para mostrar todas as tabelas e tire um print com `Win + Shift + S`.
4. Confira se o link está acessível e se os arquivos estão no repositório.
5. Clique em **Entregar** e confirme o envio.

## Roteiro curto para apresentação
“Este projeto representa uma loja de informática. O banco centraliza clientes, produtos, fornecedores, pedidos e pagamentos. As chaves estrangeiras garantem que os relacionamentos apontem para registros existentes. A tabela associativa resolve o relacionamento muitos-para-muitos entre produtos e fornecedores. A normalização reduz repetição e anomalias, e a 4FN foi demonstrada separando tags e compatibilidades, que são atributos multivalorados independentes. Por fim, as consultas SQL geram relatórios de estoque, vendas e faturamento.”
