# pip install oracledb

import oracledb

# Configuração da conexão ao banco de dados
def connect_to_db():
    username = "rm552692"
    password = "200899"
    dsn = "oracle.fiap.com.br:1521/orcl"
    
    try:
        connection = oracledb.connect(user=username, password=password, dsn=dsn)
        print("Conexão bem-sucedida ao banco de dados Oracle!")
        return connection
    except oracledb.DatabaseError as e:
        print(f"Erro ao conectar ao banco de dados Oracle: {e}")
        return None

class Usuario:
    def __init__(self, id, nome, email, senha, data_nascimento, cpf, endereco, telefone):
        self.id = id
        self.nome = nome
        self.email = email
        self.senha = senha
        self.data_nascimento = data_nascimento
        self.cpf = cpf
        self.endereco = endereco
        self.telefone = telefone

class PlanoOdontologico:
    def __init__(self, id, nome_plano, descricao, coberturas, preco, validade):
        self.id = id
        self.nome_plano = nome_plano
        self.descricao = descricao
        self.coberturas = coberturas
        self.preco = preco
        self.validade = validade

class Dentista:
    def __init__(self, id, nome, especialidade, email, telefone, endereco, crm):
        self.id = id
        self.nome = nome
        self.especialidade = especialidade
        self.email = email
        self.telefone = telefone
        self.endereco = endereco
        self.crm = crm

class Consulta:
    def __init__(self, id, data_consulta, horario, usuario_id, dentista_id, plano_id):
        self.id = id
        self.data_consulta = data_consulta
        self.horario = horario
        self.usuario_id = usuario_id
        self.dentista_id = dentista_id
        self.plano_id = plano_id

class Procedimento:
    def __init__(self, id, nome, descricao, preco):
        self.id = id
        self.nome = nome
        self.descricao = descricao
        self.preco = preco

class Fatura:
    def __init__(self, id, valor, data_emissao, data_vencimento, usuario_id):
        self.id = id
        self.valor = valor
        self.data_emissao = data_emissao
        self.data_vencimento = data_vencimento
        self.usuario_id = usuario_id

class Mensagem:
    def __init__(self, id, conteudo, data_envio, usuario_id):
        self.id = id
        self.conteudo = conteudo
        self.data_envio = data_envio
        self.usuario_id = usuario_id

class HistoricoTratamento:
    def __init__(self, id, descricao, data_inicio, data_fim, usuario_id, dentista_id, procedimento_id):
        self.id = id
        self.descricao = descricao
        self.data_inicio = data_inicio
        self.data_fim = data_fim
        self.usuario_id = usuario_id
        self.dentista_id = dentista_id
        self.procedimento_id = procedimento_id

def insert_usuario(connection, usuario):
    cursor = connection.cursor()
    query = """INSERT INTO usuario (ID, nome, email, senha, dataNascimento, cpf, endereco, telefone) 
               VALUES (:id, :nome, :email, :senha, TO_DATE(:data_nascimento, 'YYYY-MM-DD'), :cpf, :endereco, :telefone)"""
    
    try:
        cursor.execute(query, vars(usuario))
        connection.commit()
        print("Usuário inserido com sucesso!")
    except oracledb.DatabaseError as e:
        print(f"Erro ao inserir usuário: {e}")

def insert_plano_odontologico(connection, plano):
    cursor = connection.cursor()
    query = """INSERT INTO plano_odontologico (ID, nomePlano, descricao, coberturas, preco, validade) 
               VALUES (:id, :nome_plano, :descricao, :coberturas, :preco, TO_DATE(:validade, 'YYYY-MM-DD'))"""
    
    try:
        cursor.execute(query, vars(plano))
        connection.commit()
        print("Plano Odontológico inserido com sucesso!")
    except oracledb.DatabaseError as e:
        print(f"Erro ao inserir plano odontológico: {e}")

def insert_dentista(connection, dentista):
    cursor = connection.cursor()
    query = """INSERT INTO dentista (ID, nome, especialidade, email, telefone, endereco, crm) 
               VALUES (:id, :nome, :especialidade, :email, :telefone, :endereco, :crm)"""
    
    try:
        cursor.execute(query, vars(dentista))
        connection.commit()
        print("Dentista inserido com sucesso!")
    except oracledb.DatabaseError as e:
        print(f"Erro ao inserir dentista: {e}")

def insert_consulta(connection, consulta):
    cursor = connection.cursor()
    query = """INSERT INTO consulta (ID, dataConsulta, horario, usuarioID, dentistaID, planoID) 
               VALUES (:id, TO_DATE(:data_consulta, 'YYYY-MM-DD'), :horario, :usuario_id, :dentista_id, :plano_id)"""
    
    try:
        cursor.execute(query, vars(consulta))
        connection.commit()
        print("Consulta inserida com sucesso!")
    except oracledb.DatabaseError as e:
        print(f"Erro ao inserir consulta: {e}")

def insert_procedimento(connection, procedimento):
    cursor = connection.cursor()
    query = """INSERT INTO procedimento (ID, nome, descricao, preco) 
               VALUES (:id, :nome, :descricao, :preco)"""
    
    try:
        cursor.execute(query, vars(procedimento))
        connection.commit()
        print("Procedimento inserido com sucesso!")
    except oracledb.DatabaseError as e:
        print(f"Erro ao inserir procedimento: {e}")

def insert_fatura(connection, fatura):
    cursor = connection.cursor()
    query = """INSERT INTO fatura (ID, valor, dataEmissao, dataVencimento, usuarioID) 
               VALUES (:id, :valor, TO_DATE(:data_emissao, 'YYYY-MM-DD'), TO_DATE(:data_vencimento, 'YYYY-MM-DD'), :usuario_id)"""
    
    try:
        cursor.execute(query, vars(fatura))
        connection.commit()
        print("Fatura inserida com sucesso!")
    except oracledb.DatabaseError as e:
        print(f"Erro ao inserir fatura: {e}")

def insert_mensagem(connection, mensagem):
    cursor = connection.cursor()
    query = """INSERT INTO mensagem (ID, conteudo, dataEnvio, usuarioID) 
               VALUES (:id, :conteudo, TO_DATE(:data_envio, 'YYYY-MM-DD'), :usuario_id)"""
    
    try:
        cursor.execute(query, vars(mensagem))
        connection.commit()
        print("Mensagem inserida com sucesso!")
    except oracledb.DatabaseError as e:
        print(f"Erro ao inserir mensagem: {e}")

def insert_historico_tratamento(connection, historico):
    cursor = connection.cursor()
    query = """INSERT INTO historico_tratamento (ID, descricao, dataInicio, dataFim, usuarioID, dentistaID, procedimentoID) 
               VALUES (:id, :descricao, TO_DATE(:data_inicio, 'YYYY-MM-DD'), TO_DATE(:data_fim, 'YYYY-MM-DD'), :usuario_id, :dentista_id, :procedimento_id)"""
    
    try:
        cursor.execute(query, vars(historico))
        connection.commit()
        print("Histórico de Tratamento inserido com sucesso!")
    except oracledb.DatabaseError as e:
        print(f"Erro ao inserir histórico de tratamento: {e}")

def menu():
    connection = connect_to_db()
    if not connection:
        return
    
    while True:
        print("\nBem-vindo à Odontoprev")
        print("1. Cadastrar Usuário")
        print("2. Cadastrar Plano Odontológico")
        print("3. Cadastrar Dentista")
        print("4. Cadastrar Consulta")
        print("5. Cadastrar Procedimento")
        print("6. Cadastrar Fatura")
        print("7. Cadastrar Mensagem")
        print("8. Cadastrar Histórico de Tratamento")
        print("9. Sair")
        
        choice = input("Escolha uma opção: ")
        
        if choice == '1':
            id = input("ID: ")
            nome = input("Nome: ")
            email = input("Email: ")
            senha = input("Senha: ")
            data_nascimento = input("Data de Nascimento (YYYY-MM-DD): ")
            cpf = input("CPF: ")
            endereco = input("Endereço: ")
            telefone = input("Telefone: ")
            usuario = Usuario(id, nome, email, senha, data_nascimento, cpf, endereco, telefone)
            insert_usuario(connection, usuario)
        elif choice == '2':
            id = input("ID: ")
            nome_plano = input("Nome do Plano: ")
            descricao = input("Descrição: ")
            coberturas = input("Coberturas: ")
            preco = input("Preço: ")
            validade = input("Validade (YYYY-MM-DD): ")
            plano = PlanoOdontologico(id, nome_plano, descricao, coberturas, preco, validade)
            insert_plano_odontologico(connection, plano)
        elif choice == '3':
            id = input("ID: ")
            nome = input("Nome: ")
            especialidade = input("Especialidade: ")
            email = input("Email: ")
            telefone = input("Telefone: ")
            endereco = input("Endereço: ")
            crm = input("CRM: ")
            dentista = Dentista(id, nome, especialidade, email, telefone, endereco, crm)
            insert_dentista(connection, dentista)
        elif choice == '4':
            id = input("ID: ")
            data_consulta = input("Data da Consulta (YYYY-MM-DD): ")
            horario = input("Horário: ")
            usuario_id = input("ID do Usuário: ")
            dentista_id = input("ID do Dentista: ")
            plano_id = input("ID do Plano: ")
            consulta = Consulta(id, data_consulta, horario, usuario_id, dentista_id, plano_id)
            insert_consulta(connection, consulta)
        elif choice == '5':
            id = input("ID: ")
            nome = input("Nome: ")
            descricao = input("Descrição: ")
            preco = input("Preço: ")
            procedimento = Procedimento(id, nome, descricao, preco)
            insert_procedimento(connection, procedimento)
        elif choice == '6':
            id = input("ID: ")
            valor = input("Valor: ")
            data_emissao = input("Data de Emissão (YYYY-MM-DD): ")
            data_vencimento = input("Data de Vencimento (YYYY-MM-DD): ")
            usuario_id = input("ID do Usuário: ")
            fatura = Fatura(id, valor, data_emissao, data_vencimento, usuario_id)
            insert_fatura(connection, fatura)
        elif choice == '7':
            id = input("ID: ")
            conteudo = input("Conteúdo: ")
            data_envio = input("Data de Envio (YYYY-MM-DD): ")
            usuario_id = input("ID do Usuário: ")
            mensagem = Mensagem(id, conteudo, data_envio, usuario_id)
            insert_mensagem(connection, mensagem)
        elif choice == '8':
            id = input("ID: ")
            descricao = input("Descrição: ")
            data_inicio = input("Data de Início (YYYY-MM-DD): ")
            data_fim = input("Data de Fim (YYYY-MM-DD): ")
            usuario_id = input("ID do Usuário: ")
            dentista_id = input("ID do Dentista: ")
            procedimento_id = input("ID do Procedimento: ")
            historico = HistoricoTratamento(id, descricao, data_inicio, data_fim, usuario_id, dentista_id, procedimento_id)
            insert_historico_tratamento(connection, historico)
        elif choice == '9':
            connection.close()
            print("Conexão fechada.")
            break
        else:
            print("Opção inválida. Tente novamente.")

# Executa o menu
if __name__ == "__main__":
    menu()
