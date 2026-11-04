-- Trabalho: Banco de Dados - Loja ByteStore
-- SGBD: MySQL 8.0+
-- Execute este arquivo inteiro no MySQL Workbench.

DROP DATABASE IF EXISTS bytestore;
CREATE DATABASE bytestore CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bytestore;

CREATE TABLE clientes (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  telefone VARCHAR(20),
  cidade VARCHAR(80) NOT NULL,
  data_cadastro DATE NOT NULL
);

CREATE TABLE categorias (
  id_categoria INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(60) NOT NULL UNIQUE,
  descricao VARCHAR(255)
);

CREATE TABLE fornecedores (
  id_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
  razao_social VARCHAR(120) NOT NULL,
  cnpj CHAR(14) NOT NULL UNIQUE,
  email VARCHAR(120) NOT NULL,
  cidade VARCHAR(80) NOT NULL
);

CREATE TABLE produtos (
  id_produto INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(120) NOT NULL,
  descricao VARCHAR(255),
  preco DECIMAL(10,2) NOT NULL,
  estoque INT NOT NULL DEFAULT 0,
  id_categoria INT NOT NULL,
  CONSTRAINT chk_produto_preco CHECK (preco >= 0),
  CONSTRAINT chk_produto_estoque CHECK (estoque >= 0),
  CONSTRAINT fk_produto_categoria FOREIGN KEY (id_categoria)
    REFERENCES categorias(id_categoria)
);

CREATE TABLE produto_fornecedor (
  id_produto INT NOT NULL,
  id_fornecedor INT NOT NULL,
  codigo_no_fornecedor VARCHAR(40),
  custo_compra DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (id_produto, id_fornecedor),
  CONSTRAINT fk_pf_produto FOREIGN KEY (id_produto) REFERENCES produtos(id_produto),
  CONSTRAINT fk_pf_fornecedor FOREIGN KEY (id_fornecedor) REFERENCES fornecedores(id_fornecedor),
  CONSTRAINT chk_pf_custo CHECK (custo_compra >= 0)
);

CREATE TABLE pedidos (
  id_pedido INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  data_pedido DATETIME NOT NULL,
  status VARCHAR(20) NOT NULL,
  CONSTRAINT chk_pedido_status CHECK (status IN ('ABERTO','PAGO','ENVIADO','CANCELADO')),
  CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

CREATE TABLE itens_pedido (
  id_item INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido INT NOT NULL,
  id_produto INT NOT NULL,
  quantidade INT NOT NULL,
  preco_unitario DECIMAL(10,2) NOT NULL,
  CONSTRAINT uq_pedido_produto UNIQUE (id_pedido, id_produto),
  CONSTRAINT chk_item_qtd CHECK (quantidade > 0),
  CONSTRAINT chk_item_preco CHECK (preco_unitario >= 0),
  CONSTRAINT fk_item_pedido FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
  CONSTRAINT fk_item_produto FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);

CREATE TABLE pagamentos (
  id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido INT NOT NULL UNIQUE,
  forma_pagamento VARCHAR(20) NOT NULL,
  valor DECIMAL(10,2) NOT NULL,
  data_pagamento DATETIME,
  status VARCHAR(20) NOT NULL,
  CONSTRAINT chk_pagamento_forma CHECK (forma_pagamento IN ('PIX','CARTAO','BOLETO')),
  CONSTRAINT chk_pagamento_status CHECK (status IN ('APROVADO','PENDENTE','RECUSADO')),
  CONSTRAINT chk_pagamento_valor CHECK (valor >= 0),
  CONSTRAINT fk_pagamento_pedido FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
);

-- Atributos multivalorados independentes ficam em tabelas próprias (4FN).
CREATE TABLE produto_tags (
  id_produto INT NOT NULL,
  tag VARCHAR(40) NOT NULL,
  PRIMARY KEY (id_produto, tag),
  FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);

CREATE TABLE produto_compatibilidades (
  id_produto INT NOT NULL,
  plataforma VARCHAR(60) NOT NULL,
  PRIMARY KEY (id_produto, plataforma),
  FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);

INSERT INTO clientes (nome,email,telefone,cidade,data_cadastro) VALUES
('Ana Souza','ana@email.com','11990000001','São Paulo','2026-01-10'),
('Bruno Lima','bruno@email.com','11990000002','Santo André','2026-01-12'),
('Carla Mendes','carla@email.com','11990000003','São Paulo','2026-02-01'),
('Diego Alves','diego@email.com','11990000004','Guarulhos','2026-02-15'),
('Eduarda Costa','eduarda@email.com','11990000005','Osasco','2026-03-03');

INSERT INTO categorias (nome,descricao) VALUES
('Periféricos','Teclados, mouses e acessórios'),
('Hardware','Componentes internos de computador'),
('Monitores','Telas e monitores'),
('Armazenamento','Discos e unidades SSD'),
('Áudio','Fones e caixas de som');

INSERT INTO fornecedores (razao_social,cnpj,email,cidade) VALUES
('Tech Distribuidora Ltda','12345678000101','vendas@techdist.com','São Paulo'),
('Info Atacado SA','12345678000102','contato@infoatacado.com','Campinas'),
('Mega Hardware Ltda','12345678000103','comercial@megahw.com','Santos'),
('Digital Parts ME','12345678000104','vendas@digitalparts.com','São Paulo'),
('Conecta Suprimentos','12345678000105','contato@conecta.com','Guarulhos');

INSERT INTO produtos (nome,descricao,preco,estoque,id_categoria) VALUES
('Mouse Gamer X1','Mouse óptico  RGB',89.90,30,1),
('Teclado Mecânico K2','Teclado mecânico ABNT2',249.90,15,1),
('Memória RAM 16GB','DDR4 3200MHz',299.90,20,2),
('SSD 1TB','SSD SATA 2.5 polegadas',399.90,12,4),
('Monitor 24 IPS','Full HD 75Hz',899.90,8,3),
('Headset Pro','Headset com microfone',199.90,18,5),
('Placa de Vídeo RTX A','GPU 8GB',1899.90,5,2),
('Fonte 650W','Fonte 80 Plus Bronze',449.90,10,2),
('Webcam HD','Webcam 1080p',159.90,22,1),
('HD Externo 2TB','Armazenamento USB',529.90,9,4);

INSERT INTO produto_fornecedor VALUES
(1,1,'MOU-X1',45.00),(2,2,'TEC-K2',150.00),(3,3,'RAM16',190.00),
(4,4,'SSD1T',260.00),(5,1,'MON24',620.00),(6,5,'HEAD-P',110.00),
(7,3,'GPU-A',1450.00),(8,2,'FON650',300.00),(9,4,'WEB-HD',90.00),
(10,5,'HD2T',360.00),(1,4,'MOUSE-X1B',47.00);

INSERT INTO pedidos (id_cliente,data_pedido,status) VALUES
(1,'2026-04-01 10:00:00','PAGO'),
(2,'2026-04-02 11:30:00','ENVIADO'),
(3,'2026-04-03 14:00:00','PAGO'),
(1,'2026-04-05 09:15:00','ABERTO'),
(5,'2026-04-06 16:45:00','PAGO');

INSERT INTO itens_pedido (id_pedido,id_produto,quantidade,preco_unitario) VALUES
(1,1,2,89.90),(1,6,1,199.90),
(2,2,1,249.90),(2,3,2,299.90),
(3,4,1,399.90),(3,9,1,159.90),
(4,5,1,899.90),(4,8,1,449.90),
(5,7,1,1899.90),(5,10,1,529.90);

INSERT INTO pagamentos (id_pedido,forma_pagamento,valor,data_pagamento,status) VALUES
(1,'PIX',379.70,'2026-04-01 10:05:00','APROVADO'),
(2,'CARTAO',849.70,'2026-04-02 11:35:00','APROVADO'),
(3,'BOLETO',559.80,'2026-04-03 14:10:00','APROVADO'),
(4,'PIX',1349.80,NULL,'PENDENTE'),
(5,'CARTAO',2429.80,'2026-04-06 16:50:00','APROVADO');

INSERT INTO produto_tags VALUES
(1,'gamer'),(1,'USB'),(2,'gamer'),(2,'mecânico'),(3,'DDR4'),
(3,'memória'),(4,'SATA'),(4,'SSD'),(5,'Full HD'),(5,'IPS'),
(6,'gamer'),(6,'áudio'),(7,'gamer'),(7,'GPU'),(8,'energia'),
(9,'vídeo'),(9,'USB'),(10,'externo');

INSERT INTO produto_compatibilidades VALUES
(1,'Windows'),(1,'Linux'),(2,'Windows'),(2,'Linux'),(3,'Desktop DDR4'),
(4,'Desktop SATA'),(4,'Notebook SATA'),(5,'HDMI'),(6,'Windows'),
(6,'PlayStation'),(7,'PCIe'),(8,'ATX'),(9,'Windows'),(9,'macOS'),
(10,'Windows'),(10,'macOS');

-- Fim da criação e carga inicial.
