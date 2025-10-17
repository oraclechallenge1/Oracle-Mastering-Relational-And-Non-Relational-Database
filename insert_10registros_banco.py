

import cx_Oracle
import random
from faker import Faker

# Configurações da conexão com o banco de dados Oracle
dsn = cx_Oracle.makedsn('host', 'port', service_name='service_name')  # Substitua pelos valores do seu ambiente
connection = cx_Oracle.connect(user='rm560442', password='fiap25', dsn=dsn)

# Gerador de dados fictícios
fake = Faker()

# Função para inserir dados na tabela STATES
def insert_states():
    cursor = connection.cursor()
    try:
        for _ in range(10):
            state_name = fake.state()
            cursor.execute("INSERT INTO STATES (STATE_NAME) VALUES (:state_name)", [state_name])
        connection.commit()
        print("10 estados inseridos com sucesso.")
    except cx_Oracle.Error as error:
        print(f"Erro ao inserir estados: {error}")
    finally:
        cursor.close()

# Função para inserir dados na tabela CITY
def insert_city():
    cursor = connection.cursor()
    try:
        for _ in range(10):
            city_name = fake.city()
            state_id = random.randint(1, 10)  # Assumindo que o ID do estado está no intervalo 1-10
            cursor.execute("INSERT INTO CITY (NAME_CITY, STATE_ID) VALUES (:city_name, :state_id)",
                           [city_name, state_id])
        connection.commit()
        print("10 cidades inseridas com sucesso.")
    except cx_Oracle.Error as error:
        print(f"Erro ao inserir cidades: {error}")
    finally:
        cursor.close()

# Função para inserir dados na tabela NEIGHBOURHOOD
def insert_neighbourhood():
    cursor = connection.cursor()
    try:
        for _ in range(10):
            neigh_name = fake.street_name()
            city_id = random.randint(1, 10)  # Assumindo que o ID da cidade está no intervalo 1-10
            cursor.execute("INSERT INTO NEIGHBOURHOOD (NEIGH_NAME, CITY_ID) VALUES (:neigh_name, :city_id)",
                           [neigh_name, city_id])
        connection.commit()
        print("10 bairros inseridos com sucesso.")
    except cx_Oracle.Error as error:
        print(f"Erro ao inserir bairros: {error}")
    finally:
        cursor.close()

# Função para inserir dados na tabela ADDRESS_MANUFACTURER
def insert_address_manufacturer():
    cursor = connection.cursor()
    try:
        for _ in range(10):
            complement = fake.secondary_address()
            number_manu = random.randint(1000, 9999)
            address_description = fake.address()
            cep = random.randint(10000000, 99999999)
            neigh_id = random.randint(1, 10)  # Assumindo que o ID do bairro está no intervalo 1-10
            cursor.execute("""
                INSERT INTO ADDRESS_MANUFACTURER (COMPLEMENT, NUMBER_MANU, ADDRESS_DESCRIPTION, CEP, NEIGH_ID)
                VALUES (:complement, :number_manu, :address_description, :cep, :neigh_id)
            """, [complement, number_manu, address_description, cep, neigh_id])
        connection.commit()
        print("10 endereços de fabricantes inseridos com sucesso.")
    except cx_Oracle.Error as error:
        print(f"Erro ao inserir endereços de fabricantes: {error}")
    finally:
        cursor.close()

# Função para inserir dados na tabela ADDRESS_STOCK
def insert_address_stock():
    cursor = connection.cursor()
    try:
        for _ in range(10):
            complement = fake.secondary_address()
            number_stock = random.randint(1000, 9999)
            address_description = fake.address()
            cep = random.randint(10000000, 99999999)
            neigh_id = random.randint(1, 10)  # Assumindo que o ID do bairro está no intervalo 1-10
            cursor.execute("""
                INSERT INTO ADDRESS_STOCK (COMPLEMENT, NUMBER_STOCK, ADDRESS_DESCRIPTION, CEP, NEIGH_ID)
                VALUES (:complement, :number_stock, :address_description, :cep, :neigh_id)
            """, [complement, number_stock, address_description, cep, neigh_id])
        connection.commit()
        print("10 endereços de estoque inseridos com sucesso.")
    except cx_Oracle.Error as error:
        print(f"Erro ao inserir endereços de estoque: {error}")
    finally:
        cursor.close()

# Função para inserir dados na tabela LOCATION_STOCK
def insert_location_stock():
    cursor = connection.cursor()
    try:
        for _ in range(10):
            name_location = fake.word()
            location_stock_name = fake.word()
            address_id_stock = random.randint(1, 10)  # Assumindo que o ID de endereço de estoque está no intervalo 1-10
            cursor.execute("""
                INSERT INTO LOCATION_STOCK (NAME_LOCATION, LOCATION_STOCK_NAME, ADDRESS_ID_STOCK)
                VALUES (:name_location, :location_stock_name, :address_id_stock)
            """, [name_location, location_stock_name, address_id_stock])
        connection.commit()
        print("10 localizações de estoque inseridas com sucesso.")
    except cx_Oracle.Error as error:
        print(f"Erro ao inserir localizações de estoque: {error}")
    finally:
        cursor.close()

# Função para inserir dados na tabela USERS_SYS
def insert_users_sys():
    cursor = connection.cursor()
    try:
        for _ in range(10):
            name_user = fake.name()
            login = fake.user_name()
            password_user = fake.password()
            role_user_id = random.randint(1, 10)  # Assumindo que o ID de role está no intervalo 1-10
            prof_user_id = random.randint(1, 10)  # Assumindo que o ID de perfil está no intervalo 1-10
            contact_user_id = random.randint(1, 10)  # Assumindo que o ID de contato está no intervalo 1-10
            cursor.execute("""
                INSERT INTO USERS_SYS (NAME_USER, LOGIN, PASSWORD_USER, ROLE_USER_ID, PROF_USER_ID, CONTACT_USER_ID)
                VALUES (:name_user, :login, :password_user, :role_user_id, :prof_user_id, :contact_user_id)
            """, [name_user, login, password_user, role_user_id, prof_user_id, contact_user_id])
        connection.commit()
        print("10 usuários inseridos com sucesso.")
    except cx_Oracle.Error as error:
        print(f"Erro ao inserir usuários: {error}")
    finally:
        cursor.close()

# Executando as funções
insert_states()
insert_city()
insert_neighbourhood()
insert_address_manufacturer()
insert_address_stock()
insert_location_stock()
insert_users_sys()

# Fechar a conexão
connection.close()
