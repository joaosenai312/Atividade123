CREATE TABLE investidores (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    nivel_experiencia INT NOT NULL DEFAULT 0 CHECK (nivel_experiencia >= 0)
);

CREATE TABLE carteiras (
    id SERIAL PRIMARY KEY,
    investidor_id INT NOT NULL REFERENCES investidores(id),
    endereco_wallet VARCHAR(150) NOT NULL UNIQUE,
    rede_blockchain VARCHAR(50) NOT NULL,
    saldo_usd NUMERIC(15, 2) NOT NULL CHECK (saldo_usd > 0),
    status VARCHAR(20) NOT NULL DEFAULT 'Ativa' CHECK (status IN ('Ativa', 'Em Analise', 'Bloqueada', 'Pausada'))
);

CREATE TABLE corretoras (
    id SERIAL PRIMARY KEY,
    nome_exchange VARCHAR(100) NOT NULL,
    cnpj CHAR(14) NOT NULL UNIQUE,
    email_suporte VARCHAR(120) NOT NULL UNIQUE
);

CREATE TABLE criptomoedas (
    id SERIAL PRIMARY KEY,
    corretora_id INT NOT NULL REFERENCES corretoras(id),
    nome_moeda VARCHAR(60) NOT NULL,
    preco_unitario_usd NUMERIC(18, 6) NOT NULL CHECK (preco_unitario_usd > 0),
    categoria VARCHAR(20) NOT NULL DEFAULT 'Layer1' CHECK (categoria IN ('Layer1', 'DeFi', 'Memecoin', 'Stablecoin'))
);

CREATE TABLE transacoes_cripto (
    id SERIAL PRIMARY KEY,
    carteira_id INT NOT NULL REFERENCES carteiras(id),
    criptomoeda_id INT NOT NULL REFERENCES criptomoedas(id),
    quantidade NUMERIC(18, 8) NOT NULL CHECK (quantidade > 0),
    valor_pago NUMERIC(15, 2) NOT NULL CHECK (valor_pago > 0),
    data_transacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


INSERT INTO investidores (nome, cpf, nivel_experiencia) VALUES
    ('Gabriel Lima', '87678678691', 3),
    ('Artur Hipólito', '28374659182', 5),
    ('Theo pastel', '12345678901', 0),
    ('Arthur Melzi', '67676767676', 2),
    ('Batman', '12312312312', 4);

INSERT INTO corretoras (nome_exchange, cnpj, email_suporte) VALUES
    ('KuCoin', '73647581928324', 'suporte@kucoin.com'),
    ('Bitso', '18290574638291', 'ajuda@bitso.com'),
    ('NovaDAX', '17592371928340', 'contato@novadax.com.br'),
    ('Bybit', '87865467801213', 'support@bybit.com'),
    ('OKX', '19485029473645', 'help@okx.com');

INSERT INTO carteiras (investidor_id, endereco_wallet, rede_blockchain, saldo_usd, status) VALUES
    (1, '0x4F8a2B9c1D3e5F7a8B0c2D4e6F8a1B3c5D7e9F2A', 'Arbitrum', 4150.00, 'Ativa'),
    (2, 'bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq', 'Bitcoin', 22800.00, 'Ativa'),
    (3, '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin', 'Solana', 740.00, 'Em Analise'),
    (4, '5d3B7c9D1e2F4a6B8c0D2e4F6a8B0c2D4e6F8a0B1C', 'BNB Chain', 1890.75, 'Bloqueada'),
    (5, '3h6E1d4C7b9A2f5E8d1C4b7A0f3E6d9C2b5A8f1E4D', 'Avalanche', 1120.00, 'Pausada');

INSERT INTO criptomoedas (corretora_id, nome_moeda, preco_unitario_usd, categoria) VALUES
    (1, 'Bitcoin', 63500.00, 'Layer1'),
    (2, 'Ethereum', 1800.00, 'Layer1'),
    (3, 'Avalanche', 7.50, 'Layer1'),
    (4, 'Cardano', 0.20, 'Layer1'),
    (5, 'Maker', 1250.00, 'DeFi');

INSERT INTO transacoes_cripto (carteira_id, criptomoeda_id, quantidade, valor_pago) VALUES
    (1, 1, 0.05000000, 3175.00),
    (2, 2, 1.20000000, 2160.00),
    (3, 3, 40.00000000, 300.00),
    (1, 4, 1500.00000000, 300.00),
    (5, 5, 0.80000000, 1000.00);

SELECT 
    carteiras.endereco_wallet,
    carteiras.rede_blockchain,
    carteiras.saldo_usd,
    investidores.nome,
    investidores.cpf
FROM carteiras
JOIN investidores ON carteiras.investidor_id = investidores.id
WHERE carteiras.status = 'Ativa' 
   OR carteiras.status = 'Em Analise';

SELECT 
    corretoras.nome_exchange AS corretora,
    SUM(transacoes_cripto.valor_pago) AS soma_valores_pagos
FROM transacoes_cripto
JOIN criptomoedas ON transacoes_cripto.criptomoeda_id = criptomoedas.id
JOIN corretoras ON criptomoedas.corretora_id = corretoras.id
GROUP BY corretoras.nome_exchange
ORDER BY soma_valores_pagos DESC;

SELECT 
    carteiras.endereco_wallet,
    criptomoedas.nome_moeda,
    transacoes_cripto.quantidade,
    transacoes_cripto.valor_pago,
    transacoes_cripto.data_transacao
FROM transacoes_cripto
JOIN carteiras ON transacoes_cripto.carteira_id = carteiras.id
JOIN criptomoedas ON transacoes_cripto.criptomoeda_id = criptomoedas.id
WHERE transacoes_cripto.valor_pago > 500.00
ORDER BY transacoes_cripto.valor_pago DESC;

CREATE VIEW vw_painel_carteiras AS
SELECT 
    carteiras.endereco_wallet,
    carteiras.rede_blockchain,
    carteiras.status,
    carteiras.saldo_usd,
    investidores.nome AS nome_investidor,
    investidores.cpf
FROM carteiras
JOIN investidores ON carteiras.investidor_id = investidores.id;

CREATE VIEW vw_investimento_total_carteiras AS
SELECT 
    carteiras.id AS carteira_id,
    carteiras.endereco_wallet,
    carteiras.saldo_usd,
    COUNT(transacoes_cripto.id) AS quantidade_transacoes,
    SUM(transacoes_cripto.valor_pago) AS custo_total_acumulado
FROM carteiras
JOIN transacoes_cripto ON carteiras.id = transacoes_cripto.carteira_id
GROUP BY 
    carteiras.id,
    carteiras.endereco_wallet,
    carteiras.saldo_usd;