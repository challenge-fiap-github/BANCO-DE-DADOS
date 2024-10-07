/*Luis Henrique Oliveira RM552692
  Sabrina Caf� RM553568
  Matheus Duarte RM554199*/
SET SERVEROUTPUT ON;


-- DROP das tabelas (caso existam)
DROP TABLE consulta_procedimento CASCADE CONSTRAINTS;
DROP TABLE historico_tratamento CASCADE CONSTRAINTS;
DROP TABLE mensagens CASCADE CONSTRAINTS;
DROP TABLE fatura CASCADE CONSTRAINTS;
DROP TABLE consulta CASCADE CONSTRAINTS;
DROP TABLE procedimento CASCADE CONSTRAINTS;
DROP TABLE dentista CASCADE CONSTRAINTS;
DROP TABLE plano_odontologico CASCADE CONSTRAINTS;
DROP TABLE usuario CASCADE CONSTRAINTS;
DROP TABLE sinistro CASCADE CONSTRAINTS;

/*-------------------------------------------------------------------*/

-- Cria��o das tabelas

-- Cria��o da tabela Usu�rio
CREATE TABLE usuario (
    ID NUMBER PRIMARY KEY,
    nome VARCHAR2(100) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    senha VARCHAR2(100) NOT NULL,
    dataNascimento DATE,
    cpf VARCHAR2(11) UNIQUE NOT NULL,
    endereco VARCHAR2(255),
    telefone VARCHAR2(15)
);

-- Cria��o da tabela Plano Odontol�gico
CREATE TABLE plano_odontologico (
    ID NUMBER PRIMARY KEY,
    nomePlano VARCHAR2(100) NOT NULL,
    descricao VARCHAR2(255),
    coberturas VARCHAR2(255),
    preco NUMBER(10, 2),
    validade DATE
);

-- Cria��o da tabela Dentista
CREATE TABLE dentista (
    ID NUMBER PRIMARY KEY,
    nome VARCHAR2(100) NOT NULL,
    cro VARCHAR2(20) UNIQUE NOT NULL,
    especialidade VARCHAR2(100),
    enderecoClinica VARCHAR2(255),
    telefone VARCHAR2(15),
    email VARCHAR2(100) UNIQUE NOT NULL
);

-- Cria��o da tabela Consulta
CREATE TABLE consulta (
    ID NUMBER PRIMARY KEY,
    dataHora TIMESTAMP NOT NULL,
    usuarioID NUMBER NOT NULL,
    dentistaID NUMBER NOT NULL,
    status VARCHAR2(20) CHECK (status IN ('Agendada', 'Conclu�da', 'Cancelada')),
    observacoes VARCHAR2(255),
    FOREIGN KEY (usuarioID) REFERENCES usuario(ID),
    FOREIGN KEY (dentistaID) REFERENCES dentista(ID)
);

-- Cria��o da tabela Procedimento
CREATE TABLE procedimento (
    ID NUMBER PRIMARY KEY,
    nomeProcedimento VARCHAR2(100) NOT NULL,
    descricao VARCHAR2(255),
    custo NUMBER(10, 2),
    planoOdontologicoID NUMBER,
    FOREIGN KEY (planoOdontologicoID) REFERENCES plano_odontologico(ID)
);

-- Cria��o da tabela Fatura
CREATE TABLE fatura (
    ID NUMBER PRIMARY KEY,
    dataEmissao DATE NOT NULL,
    valorTotal NUMBER(10, 2) NOT NULL,
    status VARCHAR2(20) CHECK (status IN ('Paga', 'Pendente', 'Cancelada')),
    usuarioID NUMBER NOT NULL,
    FOREIGN KEY (usuarioID) REFERENCES usuario(ID)
);

-- Cria��o da tabela Mensagens e Notifica��es
CREATE TABLE mensagens (
    ID NUMBER PRIMARY KEY,
    titulo VARCHAR2(100) NOT NULL,
    conteudo VARCHAR2(255) NOT NULL,
    dataEnvio TIMESTAMP NOT NULL,
    usuarioID NUMBER NOT NULL,
    tipo VARCHAR2(20) CHECK (tipo IN ('Mensagem', 'Notifica��o')),
    status VARCHAR2(20) CHECK (status IN ('Lida', 'N�o Lida')),
    FOREIGN KEY (usuarioID) REFERENCES usuario(ID)
);

-- Cria��o da tabela Hist�rico de Tratamento
CREATE TABLE historico_tratamento (
    ID NUMBER PRIMARY KEY,
    usuarioID NUMBER NOT NULL,
    procedimentoID NUMBER NOT NULL,
    dentistaID NUMBER NOT NULL,
    data DATE NOT NULL,
    observacoes VARCHAR2(255),
    FOREIGN KEY (usuarioID) REFERENCES usuario(ID),
    FOREIGN KEY (procedimentoID) REFERENCES procedimento(ID),
    FOREIGN KEY (dentistaID) REFERENCES dentista(ID)
);

-- Relacionamento entre Consulta e Procedimento (Muitos-para-Muitos)
CREATE TABLE consulta_procedimento (
    consultaID NUMBER,
    procedimentoID NUMBER,
    PRIMARY KEY (consultaID, procedimentoID),
    FOREIGN KEY (consultaID) REFERENCES consulta(ID),
    FOREIGN KEY (procedimentoID) REFERENCES procedimento(ID)
);

-- Cria��o da tabela Sinistro
CREATE TABLE sinistro (
    id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    paciente_id NUMBER,
    procedimento_id NUMBER,
    data_sinistro DATE,
    risco_fraude CHAR(1) CHECK (risco_fraude IN ('S', 'N')), -- 'S' para sim, 'N' para n�o
    FOREIGN KEY (paciente_id) REFERENCES usuario(ID),
    FOREIGN KEY (procedimento_id) REFERENCES procedimento(ID)
);

/*-------------------------------------------------------------------*/

-- VISUALIZA��O DAS TABELAS
SELECT * FROM usuario;
SELECT * FROM plano_odontologico;
SELECT * FROM dentista;
SELECT * FROM consulta;
SELECT * FROM procedimento;
SELECT * FROM fatura;
SELECT * FROM mensagens;
SELECT * FROM historico_tratamento;
SELECT * FROM consulta_procedimento;
SELECT * FROM sinistro;
/*-------------------------------------------------------------------*/


DECLARE
  CURSOR c_innersql IS
    SELECT u.nome, d.nome AS nome_dentista, p.nomeProcedimento, COUNT(p.ID) AS total_procedimentos
    FROM consulta c
    INNER JOIN usuario u ON c.usuarioID = u.ID
    INNER JOIN dentista d ON c.dentistaID = d.ID
    INNER JOIN consulta_procedimento cp ON c.ID = cp.consultaID
    INNER JOIN procedimento p ON cp.procedimentoID = p.ID
    GROUP BY u.nome, d.nome, p.nomeProcedimento
    ORDER BY total_procedimentos DESC;
BEGIN
  FOR r_innersql IN c_innersql LOOP
    DBMS_OUTPUT.PUT_LINE('Paciente: ' || r_innersql.nome || ' | Dentista: ' || r_innersql.nome_dentista || ' | Procedimento: ' || r_innersql.nomeProcedimento || ' | Total: ' || r_innersql.total_procedimentos);
  END LOOP;
END;


/*-------------------------------------------------------------------*/

DECLARE
  CURSOR c_leftsql IS
    SELECT u.nome, f.valorTotal, f.status, COUNT(f.ID) AS total_faturas
    FROM usuario u
    LEFT JOIN fatura f ON u.ID = f.usuarioID
    GROUP BY u.nome, f.valorTotal, f.status
    ORDER BY f.valorTotal DESC;
BEGIN
  FOR r_leftsql IN c_leftsql LOOP
    DBMS_OUTPUT.PUT_LINE('Paciente: ' || r_leftsql.nome || ' | Valor Total: ' || r_leftsql.valorTotal || ' | Status: ' || r_leftsql.status || ' | Total Faturas: ' || r_leftsql.total_faturas);
  END LOOP;
END;

/*-------------------------------------------------------------------*/

DECLARE
  CURSOR c_rightsql IS
    SELECT p.nomePlano, COUNT(s.id) AS total_sinistros, s.risco_fraude
    FROM plano_odontologico p
    RIGHT JOIN sinistro s ON p.ID = s.procedimento_id
    GROUP BY p.nomePlano, s.risco_fraude
    ORDER BY total_sinistros DESC;
BEGIN
  FOR r_rightsql IN c_rightsql LOOP
    DBMS_OUTPUT.PUT_LINE('Plano: ' || r_rightsql.nomePlano || ' | Total Sinistros: ' || r_rightsql.total_sinistros || ' | Risco Fraude: ' || r_rightsql.risco_fraude);
  END LOOP;
END;

/*-------------------------------------------------------------------*/

DECLARE
  v_paciente_id NUMBER := 1;
  v_novo_endereco VARCHAR2(255) := 'Av. Nova, 123';
BEGIN
  UPDATE usuario
  SET endereco = v_novo_endereco
  WHERE ID = v_paciente_id;
  
  IF SQL%ROWCOUNT > 0 THEN
    DBMS_OUTPUT.PUT_LINE('Atualiza��o realizada com sucesso para o Paciente ID: ' || v_paciente_id);
  ELSE
    DBMS_OUTPUT.PUT_LINE('Nenhum registro encontrado para o Paciente ID: ' || v_paciente_id);
  END IF;
END;

/*-------------------------------------------------------------------*/

DECLARE
  v_fatura_id NUMBER := 3;
BEGIN
  DELETE FROM fatura
  WHERE ID = v_fatura_id;
  
  IF SQL%ROWCOUNT > 0 THEN
    DBMS_OUTPUT.PUT_LINE('Fatura ID ' || v_fatura_id || ' foi deletada com sucesso.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Nenhuma fatura encontrada com o ID: ' || v_fatura_id);
  END IF;
END;



/*-------------------------------------------------------------------*/

-- INSERTS PARA TESTE DO BANCO

-- Inser��es na tabela 'usuario'
INSERT INTO usuario (ID, nome, email, senha, dataNascimento, cpf, endereco, telefone) VALUES 
(1, 'Carlos Silva', 'carlos.silva@email.com', 'senha123', TO_DATE('1990-03-12', 'YYYY-MM-DD'), '12345678901', 'Rua das Flores, 100', '11987654321');

INSERT INTO usuario (ID, nome, email, senha, dataNascimento, cpf, endereco, telefone) VALUES 
(2, 'Mariana Souza', 'mariana.souza@email.com', 'senha456', TO_DATE('1988-05-22', 'YYYY-MM-DD'), '98765432101', 'Av. Paulista, 500', '11876543210');

INSERT INTO usuario (ID, nome, email, senha, dataNascimento, cpf, endereco, telefone) VALUES 
(3, 'Jo�o Pereira', 'joao.pereira@email.com', 'senha789', TO_DATE('1975-11-10', 'YYYY-MM-DD'), '56473829101', 'Rua Central, 250', '11912345678');

INSERT INTO usuario (ID, nome, email, senha, dataNascimento, cpf, endereco, telefone) VALUES 
(4, 'Ana Gomes', 'ana.gomes@email.com', 'senha101', TO_DATE('1995-02-19', 'YYYY-MM-DD'), '10293847561', 'Rua Verde, 30', '11987651234');

INSERT INTO usuario (ID, nome, email, senha, dataNascimento, cpf, endereco, telefone) VALUES 
(5, 'Paulo Fernandes', 'paulo.fernandes@email.com', 'senha202', TO_DATE('1983-07-07', 'YYYY-MM-DD'), '09182736451', 'Rua Azul, 200', '11965431234');

INSERT INTO usuario (ID, nome, email, senha, dataNascimento, cpf, endereco, telefone) VALUES 
(6, 'Beatriz Costa', 'beatriz.costa@email.com', 'senha303', TO_DATE('1992-09-15', 'YYYY-MM-DD'), '09273645182', 'Rua Amarela, 45', '11912349876');

INSERT INTO usuario (ID, nome, email, senha, dataNascimento, cpf, endereco, telefone) VALUES 
(7, 'Eduardo Santos', 'eduardo.santos@email.com', 'senha404', TO_DATE('1987-04-25', 'YYYY-MM-DD'), '01928374652', 'Rua Laranja, 78', '11956783412');

INSERT INTO usuario (ID, nome, email, senha, dataNascimento, cpf, endereco, telefone) VALUES 
(8, 'Carla Mendes', 'carla.mendes@email.com', 'senha505', TO_DATE('1993-06-20', 'YYYY-MM-DD'), '91827364501', 'Rua Roxa, 321', '11943217654');

INSERT INTO usuario (ID, nome, email, senha, dataNascimento, cpf, endereco, telefone) VALUES 
(9, 'Rafael Lima', 'rafael.lima@email.com', 'senha606', TO_DATE('1985-12-12', 'YYYY-MM-DD'), '81726354012', 'Av. Brasil, 1200', '11998765432');

INSERT INTO usuario (ID, nome, email, senha, dataNascimento, cpf, endereco, telefone) VALUES 
(10, 'Juliana Andrade', 'juliana.andrade@email.com', 'senha707', TO_DATE('1991-01-01', 'YYYY-MM-DD'), '16273849501', 'Rua Prata, 85', '11976543210');


/*-------------------------------------------------------------------*/

INSERT INTO plano_odontologico (ID, nomePlano, descricao, coberturas, preco, validade) VALUES 
(1, 'Plano B�sico', 'Cobertura b�sica', 'Limpeza, Extra��o', 100.00, TO_DATE('2025-01-01', 'YYYY-MM-DD'));
 
INSERT INTO plano_odontologico (ID, nomePlano, descricao, coberturas, preco, validade) VALUES 
(2, 'Plano Plus', 'Cobertura intermedi�ria', 'Limpeza, Extra��o, Restaura��o', 200.00, TO_DATE('2025-06-01', 'YYYY-MM-DD'));

INSERT INTO plano_odontologico (ID, nomePlano, descricao, coberturas, preco, validade) VALUES 
(3, 'Plano Premium', 'Cobertura completa', 'Limpeza, Extra��o, Restaura��o, Tratamento Ortod�ntico', 300.00, TO_DATE('2025-12-01', 'YYYY-MM-DD'));

INSERT INTO plano_odontologico (ID, nomePlano, descricao, coberturas, preco, validade) VALUES 
(4, 'Plano Essencial', 'Cobertura essencial', 'Limpeza, Extra��o', 150.00, TO_DATE('2024-10-01', 'YYYY-MM-DD'));

INSERT INTO plano_odontologico (ID, nomePlano, descricao, coberturas, preco, validade) VALUES 
(5, 'Plano Fam�lia', 'Cobertura para toda a fam�lia', 'Limpeza, Extra��o, Tratamento Infantil', 250.00, TO_DATE('2025-03-01', 'YYYY-MM-DD'));

INSERT INTO plano_odontologico (ID, nomePlano, descricao, coberturas, preco, validade) VALUES 
(6, 'Plano Executivo', 'Cobertura para executivos', 'Limpeza, Clareamento', 350.00, TO_DATE('2026-01-01', 'YYYY-MM-DD'));

INSERT INTO plano_odontologico (ID, nomePlano, descricao, coberturas, preco, validade) VALUES 
(7, 'Plano Econ�mico', 'Cobertura econ�mica', 'Limpeza', 80.00, TO_DATE('2024-12-31', 'YYYY-MM-DD'));

INSERT INTO plano_odontologico (ID, nomePlano, descricao, coberturas, preco, validade) VALUES 
(8, 'Plano Plus Fam�lia', 'Cobertura intermedi�ria para fam�lias', 'Limpeza, Extra��o, Tratamento Infantil', 220.00, TO_DATE('2025-09-01', 'YYYY-MM-DD'));

INSERT INTO plano_odontologico (ID, nomePlano, descricao, coberturas, preco, validade) VALUES 
(9, 'Plano Avan�ado', 'Cobertura avan�ada', 'Limpeza, Extra��o, Tratamento Ortod�ntico', 400.00, TO_DATE('2025-11-01', 'YYYY-MM-DD'));

INSERT INTO plano_odontologico (ID, nomePlano, descricao, coberturas, preco, validade) VALUES 
(10, 'Plano S�nior', 'Cobertura para idosos', 'Limpeza, Extra��o, Dentadura', 180.00, TO_DATE('2025-05-01', 'YYYY-MM-DD'));


/*-------------------------------------------------------------------*/

-- Inser��es na tabela 'dentista'
INSERT INTO dentista (ID, nome, cro, especialidade, enderecoClinica, telefone, email) VALUES 
(1, 'Dr. Pedro Lacerda', 'CRO123456', 'Ortodontia', 'Av. Paulista, 1234', '11987651234', 'dr.pedro@email.com');

INSERT INTO dentista (ID, nome, cro, especialidade, enderecoClinica, telefone, email) VALUES 
(2, 'Dra. Ana Beatriz', 'CRO654321', 'Endodontia', 'Rua das Laranjeiras, 45', '11987654321', 'dra.ana@email.com');

INSERT INTO dentista (ID, nome, cro, especialidade, enderecoClinica, telefone, email) VALUES 
(3, 'Dr. Marcos Silva', 'CRO234567', 'Periodontia', 'Rua Floriano, 100', '11965432100', 'dr.marcos@email.com');

INSERT INTO dentista (ID, nome, cro, especialidade, enderecoClinica, telefone, email) VALUES 
(4, 'Dra. Marina Costa', 'CRO345678', 'Odontopediatria', 'Rua dos Cedros, 25', '11954321098', 'dra.marina@email.com');

INSERT INTO dentista (ID, nome, cro, especialidade, enderecoClinica, telefone, email) VALUES 
(5, 'Dr. Jos� Souza', 'CRO456789', 'Implantodontia', 'Av. do Brasil, 987', '11943219876', 'dr.jose@email.com');

INSERT INTO dentista (ID, nome, cro, especialidade, enderecoClinica, telefone, email) VALUES 
(6, 'Dra. Carla Mendes', 'CRO567890', 'Clareamento Dental', 'Rua das Palmeiras, 56', '11932108765', 'dra.carla@email.com');

INSERT INTO dentista (ID, nome, cro, especialidade, enderecoClinica, telefone, email) VALUES 
(7, 'Dr. Lucas Martins', 'CRO678901', 'Pr�tese Dent�ria', 'Av. Europa, 65', '11921097654', 'dr.lucas@email.com');

INSERT INTO dentista (ID, nome, cro, especialidade, enderecoClinica, telefone, email) VALUES 
(8, 'Dra. Juliana Lima', 'CRO789012', 'Cirurgia', 'Rua do Sol, 89', '11910987654', 'dra.juliana@email.com');

INSERT INTO dentista (ID, nome, cro, especialidade, enderecoClinica, telefone, email) VALUES 
(9, 'Dr. Fernando Braga', 'CRO890123', 'Ortodontia', 'Rua das Estrelas, 200', '11909876543', 'dr.fernando@email.com');

INSERT INTO dentista (ID, nome, cro, especialidade, enderecoClinica, telefone, email) VALUES 
(10, 'Dra. Paula Oliveira', 'CRO901234', 'Endodontia', 'Av. Santos Dumont, 789', '11908765432', 'dra.paula@email.com');


/*-------------------------------------------------------------------*/

-- Inser��es na tabela 'consulta'
INSERT INTO consulta (ID, dataHora, usuarioID, dentistaID, status, observacoes) VALUES 
(1, TO_TIMESTAMP('2024-10-01 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 1, 'Agendada', 'Consulta de rotina');

INSERT INTO consulta (ID, dataHora, usuarioID, dentistaID, status, observacoes) VALUES 
(2, TO_TIMESTAMP('2024-10-05 10:30:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 2, 'Conclu�da', 'Consulta de restaura��o');

INSERT INTO consulta (ID, dataHora, usuarioID, dentistaID, status, observacoes) VALUES 
(3, TO_TIMESTAMP('2024-10-10 14:00:00', 'YYYY-MM-DD HH24:MI:SS'), 3, 3, 'Cancelada', 'Consulta desmarcada pelo paciente');

INSERT INTO consulta (ID, dataHora, usuarioID, dentistaID, status, observacoes) VALUES 
(4, TO_TIMESTAMP('2024-10-12 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 4, 4, 'Agendada', 'Consulta ortod�ntica');

INSERT INTO consulta (ID, dataHora, usuarioID, dentistaID, status, observacoes) VALUES 
(5, TO_TIMESTAMP('2024-10-18 15:30:00', 'YYYY-MM-DD HH24:MI:SS'), 5, 5, 'Conclu�da', 'Consulta de implante');

INSERT INTO consulta (ID, dataHora, usuarioID, dentistaID, status, observacoes) VALUES 
(6, TO_TIMESTAMP('2024-10-20 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), 6, 6, 'Agendada', 'Consulta de clareamento');

INSERT INTO consulta (ID, dataHora, usuarioID, dentistaID, status, observacoes) VALUES 
(7, TO_TIMESTAMP('2024-10-22 09:30:00', 'YYYY-MM-DD HH24:MI:SS'), 7, 7, 'Conclu�da', 'Consulta de pr�tese');

INSERT INTO consulta (ID, dataHora, usuarioID, dentistaID, status, observacoes) VALUES 
(8, TO_TIMESTAMP('2024-10-25 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), 8, 8, 'Agendada', 'Consulta cir�rgica');

INSERT INTO consulta (ID, dataHora, usuarioID, dentistaID, status, observacoes) VALUES 
(9, TO_TIMESTAMP('2024-10-30 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 9, 9, 'Conclu�da', 'Consulta de ortodontia');

INSERT INTO consulta (ID, dataHora, usuarioID, dentistaID, status, observacoes) VALUES 
(10, TO_TIMESTAMP('2024-11-01 11:30:00', 'YYYY-MM-DD HH24:MI:SS'), 10, 10, 'Agendada', 'Consulta de endodontia');

/*-------------------------------------------------------------------*/

-- Inser��es na tabela 'procedimento'
INSERT INTO procedimento (ID, nomeProcedimento, descricao, custo, planoOdontologicoID) VALUES 
(1, 'Limpeza Simples', 'Limpeza dental b�sica', 80.00, 1);

INSERT INTO procedimento (ID, nomeProcedimento, descricao, custo, planoOdontologicoID) VALUES 
(2, 'Extra��o', 'Extra��o de dente', 150.00, 1);

INSERT INTO procedimento (ID, nomeProcedimento, descricao, custo, planoOdontologicoID) VALUES 
(3, 'Restaura��o', 'Restaura��o de c�rie', 200.00, 2);

INSERT INTO procedimento (ID, nomeProcedimento, descricao, custo, planoOdontologicoID) VALUES 
(4, 'Tratamento Ortod�ntico', 'Aparelho fixo', 3000.00, 3);

INSERT INTO procedimento (ID, nomeProcedimento, descricao, custo, planoOdontologicoID) VALUES 
(5, 'Clareamento Dental', 'Clareamento a laser', 600.00, 6);

INSERT INTO procedimento (ID, nomeProcedimento, descricao, custo, planoOdontologicoID) VALUES 
(6, 'Implante Dent�rio', 'Implante de dente', 5000.00, 5);

INSERT INTO procedimento (ID, nomeProcedimento, descricao, custo, planoOdontologicoID) VALUES 
(7, 'Pr�tese Dent�ria', 'Pr�tese remov�vel', 800.00, 7);

INSERT INTO procedimento (ID, nomeProcedimento, descricao, custo, planoOdontologicoID) VALUES 
(8, 'Cirurgia Ortogn�tica', 'Corre��o de mand�bula', 10000.00, 8);

INSERT INTO procedimento (ID, nomeProcedimento, descricao, custo, planoOdontologicoID) VALUES 
(9, 'Tratamento Infantil', 'Tratamento odontol�gico infantil', 400.00, 5);

INSERT INTO procedimento (ID, nomeProcedimento, descricao, custo, planoOdontologicoID) VALUES 
(10, 'Dentadura Completa', 'Dentadura superior e inferior', 1800.00, 10);

/*-------------------------------------------------------------------*/

-- Inser��es na tabela 'fatura'
INSERT INTO fatura (ID, dataEmissao, valorTotal, status, usuarioID) VALUES 
(1, TO_DATE('2024-10-01', 'YYYY-MM-DD'), 150.00, 'Pendente', 1);

INSERT INTO fatura (ID, dataEmissao, valorTotal, status, usuarioID) VALUES 
(2, TO_DATE('2024-10-05', 'YYYY-MM-DD'), 200.00, 'Paga', 2);

INSERT INTO fatura (ID, dataEmissao, valorTotal, status, usuarioID) VALUES 
(3, TO_DATE('2024-10-10', 'YYYY-MM-DD'), 300.00, 'Cancelada', 3);

INSERT INTO fatura (ID, dataEmissao, valorTotal, status, usuarioID) VALUES 
(4, TO_DATE('2024-10-15', 'YYYY-MM-DD'), 500.00, 'Paga', 4);

INSERT INTO fatura (ID, dataEmissao, valorTotal, status, usuarioID) VALUES 
(5, TO_DATE('2024-10-18', 'YYYY-MM-DD'), 600.00, 'Pendente', 5);

INSERT INTO fatura (ID, dataEmissao, valorTotal, status, usuarioID) VALUES 
(6, TO_DATE('2024-10-20', 'YYYY-MM-DD'), 700.00, 'Paga', 6);

INSERT INTO fatura (ID, dataEmissao, valorTotal, status, usuarioID) VALUES 
(7, TO_DATE('2024-10-25', 'YYYY-MM-DD'), 1000.00, 'Cancelada', 7);

INSERT INTO fatura (ID, dataEmissao, valorTotal, status, usuarioID) VALUES 
(8, TO_DATE('2024-10-30', 'YYYY-MM-DD'), 250.00, 'Paga', 8);

INSERT INTO fatura (ID, dataEmissao, valorTotal, status, usuarioID) VALUES 
(9, TO_DATE('2024-11-01', 'YYYY-MM-DD'), 400.00, 'Pendente', 9);

INSERT INTO fatura (ID, dataEmissao, valorTotal, status, usuarioID) VALUES 
(10, TO_DATE('2024-11-05', 'YYYY-MM-DD'), 450.00, 'Paga', 10);


/*-------------------------------------------------------------------*/

-- Inser��es na tabela 'mensagens'
INSERT INTO mensagens (ID, titulo, conteudo, dataEnvio, usuarioID, tipo, status) VALUES 
(1, 'Boas-vindas', 'Bem-vindo ao nosso sistema!', TO_TIMESTAMP('2024-10-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 'Mensagem', 'Lida');

INSERT INTO mensagens (ID, titulo, conteudo, dataEnvio, usuarioID, tipo, status) VALUES 
(2, 'Lembrete de Consulta', 'Sua consulta est� agendada para 05/10', TO_TIMESTAMP('2024-10-04 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 'Notifica��o', 'N�o Lida');

INSERT INTO mensagens (ID, titulo, conteudo, dataEnvio, usuarioID, tipo, status) VALUES 
(3, 'Atualiza��o de Plano', 'Seu plano foi atualizado', TO_TIMESTAMP('2024-10-06 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 3, 'Mensagem', 'Lida');

INSERT INTO mensagens (ID, titulo, conteudo, dataEnvio, usuarioID, tipo, status) VALUES 
(4, 'Pagamento Recebido', 'Seu pagamento foi recebido', TO_TIMESTAMP('2024-10-15 10:30:00', 'YYYY-MM-DD HH24:MI:SS'), 4, 'Notifica��o', 'Lida');

INSERT INTO mensagens (ID, titulo, conteudo, dataEnvio, usuarioID, tipo, status) VALUES 
(5, 'Agendamento de Consulta', 'Consulta agendada com sucesso', TO_TIMESTAMP('2024-10-18 11:45:00', 'YYYY-MM-DD HH24:MI:SS'), 5, 'Mensagem', 'N�o Lida');

INSERT INTO mensagens (ID, titulo, conteudo, dataEnvio, usuarioID, tipo, status) VALUES 
(6, 'Consulta Cancelada', 'Sua consulta foi cancelada', TO_TIMESTAMP('2024-10-20 14:30:00', 'YYYY-MM-DD HH24:MI:SS'), 6, 'Notifica��o', 'Lida');

INSERT INTO mensagens (ID, titulo, conteudo, dataEnvio, usuarioID, tipo, status) VALUES 
(7, 'Fatura Gerada', 'Uma nova fatura foi gerada', TO_TIMESTAMP('2024-10-25 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), 7, 'Mensagem', 'N�o Lida');

INSERT INTO mensagens (ID, titulo, conteudo, dataEnvio, usuarioID, tipo, status) VALUES 
(8, 'Pr�xima Consulta', 'Lembre-se da sua consulta em 25/10', TO_TIMESTAMP('2024-10-24 17:30:00', 'YYYY-MM-DD HH24:MI:SS'), 8, 'Notifica��o', 'N�o Lida');

INSERT INTO mensagens (ID, titulo, conteudo, dataEnvio, usuarioID, tipo, status) VALUES 
(9, 'Atualiza��o de Cadastro', 'Seu cadastro foi atualizado', TO_TIMESTAMP('2024-10-28 18:00:00', 'YYYY-MM-DD HH24:MI:SS'), 9, 'Mensagem', 'Lida');

INSERT INTO mensagens (ID, titulo, conteudo, dataEnvio, usuarioID, tipo, status) VALUES 
(10, 'Consulta Remarcada', 'Sua consulta foi remarcada para 01/11', TO_TIMESTAMP('2024-10-30 19:00:00', 'YYYY-MM-DD HH24:MI:SS'), 10, 'Notifica��o', 'N�o Lida');


/*-------------------------------------------------------------------*/

-- Inser��es na tabela 'historico_tratamento'
INSERT INTO historico_tratamento (ID, usuarioID, procedimentoID, dentistaID, data, observacoes) VALUES 
(1, 1, 1, 1, TO_DATE('2024-10-01', 'YYYY-MM-DD'), 'Limpeza realizada');

INSERT INTO historico_tratamento (ID, usuarioID, procedimentoID, dentistaID, data, observacoes) VALUES 
(2, 2, 2, 2, TO_DATE('2024-10-05', 'YYYY-MM-DD'), 'Extra��o conclu�da');

INSERT INTO historico_tratamento (ID, usuarioID, procedimentoID, dentistaID, data, observacoes) VALUES 
(3, 3, 3, 3, TO_DATE('2024-10-10', 'YYYY-MM-DD'), 'Restaura��o adiada');

INSERT INTO historico_tratamento (ID, usuarioID, procedimentoID, dentistaID, data, observacoes) VALUES 
(4, 4, 4, 4, TO_DATE('2024-10-15', 'YYYY-MM-DD'), 'Aparelho fixo colocado');

INSERT INTO historico_tratamento (ID, usuarioID, procedimentoID, dentistaID, data, observacoes) VALUES 
(5, 5, 5, 5, TO_DATE('2024-10-18', 'YYYY-MM-DD'), 'Clareamento dental feito');

INSERT INTO historico_tratamento (ID, usuarioID, procedimentoID, dentistaID, data, observacoes) VALUES 
(6, 6, 6, 6, TO_DATE('2024-10-20', 'YYYY-MM-DD'), 'Implante dent�rio realizado');

INSERT INTO historico_tratamento (ID, usuarioID, procedimentoID, dentistaID, data, observacoes) VALUES 
(7, 7, 7, 7, TO_DATE('2024-10-25', 'YYYY-MM-DD'), 'Pr�tese colocada');

INSERT INTO historico_tratamento (ID, usuarioID, procedimentoID, dentistaID, data, observacoes) VALUES 
(8, 8, 8, 8, TO_DATE('2024-10-30', 'YYYY-MM-DD'), 'Cirurgia realizada com sucesso');

INSERT INTO historico_tratamento (ID, usuarioID, procedimentoID, dentistaID, data, observacoes) VALUES 
(9, 9, 9, 9, TO_DATE('2024-11-01', 'YYYY-MM-DD'), 'Tratamento infantil finalizado');

INSERT INTO historico_tratamento (ID, usuarioID, procedimentoID, dentistaID, data, observacoes) VALUES 
(10, 10, 10, 10, TO_DATE('2024-11-05', 'YYYY-MM-DD'), 'Dentadura ajustada');


/*-------------------------------------------------------------------*/

-- Inser��es na tabela 'consulta_procedimento'
INSERT INTO consulta_procedimento (consultaID, procedimentoID) VALUES 
(1, 1);

INSERT INTO consulta_procedimento (consultaID, procedimentoID) VALUES 
(2, 2);

INSERT INTO consulta_procedimento (consultaID, procedimentoID) VALUES 
(3, 3);

INSERT INTO consulta_procedimento (consultaID, procedimentoID) VALUES 
(4, 4);

INSERT INTO consulta_procedimento (consultaID, procedimentoID) VALUES 
(5, 5);

INSERT INTO consulta_procedimento (consultaID, procedimentoID) VALUES 
(6, 6);

INSERT INTO consulta_procedimento (consultaID, procedimentoID) VALUES 
(7, 7);

INSERT INTO consulta_procedimento (consultaID, procedimentoID) VALUES 
(8, 8);

INSERT INTO consulta_procedimento (consultaID, procedimentoID) VALUES 
(9, 9);

INSERT INTO consulta_procedimento (consultaID, procedimentoID) VALUES 
(10, 10);


/*-------------------------------------------------------------------*/

-- Inser��es na tabela 'sinistro'
INSERT INTO sinistro (id, paciente_id, procedimento_id, data_sinistro, risco_fraude) VALUES 
(1, 1, 1, TO_DATE('2024-10-01', 'YYYY-MM-DD'), 'N');

INSERT INTO sinistro (id, paciente_id, procedimento_id, data_sinistro, risco_fraude) VALUES 
(2, 2, 2, TO_DATE('2024-10-05', 'YYYY-MM-DD'), 'S');

INSERT INTO sinistro (id, paciente_id, procedimento_id, data_sinistro, risco_fraude) VALUES 
(3, 3, 3, TO_DATE('2024-10-10', 'YYYY-MM-DD'), 'N');

INSERT INTO sinistro (id, paciente_id, procedimento_id, data_sinistro, risco_fraude) VALUES 
(4, 4, 4, TO_DATE('2024-10-15', 'YYYY-MM-DD'), 'N');

INSERT INTO sinistro (id, paciente_id, procedimento_id, data_sinistro, risco_fraude) VALUES 
(5, 5, 5, TO_DATE('2024-10-18', 'YYYY-MM-DD'), 'S');

INSERT INTO sinistro (id, paciente_id, procedimento_id, data_sinistro, risco_fraude) VALUES 
(6, 6, 6, TO_DATE('2024-10-20', 'YYYY-MM-DD'), 'N');

INSERT INTO sinistro (id, paciente_id, procedimento_id, data_sinistro, risco_fraude) VALUES 
(7, 7, 7, TO_DATE('2024-10-25', 'YYYY-MM-DD'), 'S');

INSERT INTO sinistro (id, paciente_id, procedimento_id, data_sinistro, risco_fraude) VALUES 
(8, 8, 8, TO_DATE('2024-10-30', 'YYYY-MM-DD'), 'N');

INSERT INTO sinistro (id, paciente_id, procedimento_id, data_sinistro, risco_fraude) VALUES 
(9, 9, 9, TO_DATE('2024-11-01', 'YYYY-MM-DD'), 'N');

INSERT INTO sinistro (id, paciente_id, procedimento_id, data_sinistro, risco_fraude) VALUES 
(10, 10, 10, TO_DATE('2024-11-05', 'YYYY-MM-DD'), 'S');




