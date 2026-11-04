-- 15 consultas contextualizadas - MySQL 8.0+
USE bytestore;

-- 1. Listar todos os produtos e suas categorias
SELECT p.nome AS produto, c.nome AS categoria, p.preco
FROM produtos p INNER JOIN categorias c ON c.id_categoria=p.id_categoria
ORDER BY p.nome;

-- 2. Encontrar produtos com preço acima de R$ 300
SELECT nome, preco FROM produtos WHERE preco > 300 ORDER BY preco DESC;

-- 3. Buscar clientes cujo nome começa com 'A'
SELECT nome,email FROM clientes WHERE nome LIKE 'A%';

-- 4. Consultar pedidos realizados entre 01/04 e 05/04/2026
SELECT id_pedido,id_cliente,data_pedido,status FROM pedidos
WHERE data_pedido BETWEEN '2026-04-01 00:00:00' AND '2026-04-05 23:59:59'
ORDER BY data_pedido;

-- 5. Calcular o total de cada pedido
SELECT p.id_pedido, SUM(i.quantidade*i.preco_unitario) AS total_pedido
FROM pedidos p INNER JOIN itens_pedido i ON i.id_pedido=p.id_pedido
GROUP BY p.id_pedido ORDER BY p.id_pedido;

-- 6. Somar o faturamento dos pagamentos aprovados
SELECT SUM(valor) AS faturamento_aprovado FROM pagamentos WHERE status='APROVADO';

-- 7. Contar quantos produtos existem em cada categoria
SELECT c.nome, COUNT(p.id_produto) AS quantidade_produtos
FROM categorias c LEFT JOIN produtos p ON p.id_categoria=c.id_categoria
GROUP BY c.id_categoria,c.nome ORDER BY quantidade_produtos DESC,c.nome;

-- 8. Mostrar clientes e seus pedidos
SELECT c.nome,p.id_pedido,p.status FROM clientes c
INNER JOIN pedidos p ON p.id_cliente=c.id_cliente ORDER BY c.nome,p.id_pedido;

-- 9. Encontrar produtos com estoque menor ou igual a 10
SELECT nome,estoque FROM produtos WHERE estoque <= 10 ORDER BY estoque;

-- 10. Exibir pagamentos com forma e cliente
SELECT p.id_pedido,c.nome,pg.forma_pagamento,pg.valor,pg.status
FROM pagamentos pg INNER JOIN pedidos p ON p.id_pedido=pg.id_pedido
INNER JOIN clientes c ON c.id_cliente=p.id_cliente ORDER BY p.id_pedido;

-- 11. Encontrar produtos que possuem a palavra 'HD' no nome
SELECT nome,preco FROM produtos WHERE nome LIKE '%HD%';

-- 12. Listar fornecedores de cada produto
SELECT p.nome AS produto,f.razao_social AS fornecedor,pf.custo_compra
FROM produto_fornecedor pf INNER JOIN produtos p ON p.id_produto=pf.id_produto
INNER JOIN fornecedores f ON f.id_fornecedor=pf.id_fornecedor
ORDER BY p.nome,f.razao_social;

-- 13. Mostrar os produtos mais caros que R$ 200 e ordenar do maior para o menor
SELECT nome,preco FROM produtos WHERE preco > 200 ORDER BY preco DESC;

-- 14. Calcular quantidade vendida por produto
SELECT pr.nome,SUM(i.quantidade) AS unidades_vendidas
FROM itens_pedido i INNER JOIN produtos pr ON pr.id_produto=i.id_produto
GROUP BY pr.id_produto,pr.nome ORDER BY unidades_vendidas DESC,pr.nome;

-- 15. Listar tags cadastradas para cada produto
SELECT p.nome, GROUP_CONCAT(t.tag ORDER BY t.tag SEPARATOR ', ') AS tags
FROM produtos p INNER JOIN produto_tags t ON t.id_produto=p.id_produto
GROUP BY p.id_produto,p.nome ORDER BY p.nome;

