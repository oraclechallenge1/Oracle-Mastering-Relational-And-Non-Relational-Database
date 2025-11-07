SET SERVEROUTPUT ON;

--------------------------------------------------------------------------------
-- 1) FUNÇÕES DE VALIDAÇÃO DE ENTRADA
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- 1) Válida email
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION valida_email(p_email IN VARCHAR2)
  RETURN VARCHAR2
IS
BEGIN
  IF p_email IS NULL THEN
    RETURN 'E-mail inválido';
  END IF;

  IF REGEXP_LIKE(
       p_email,
       '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$'
     ) THEN
    RETURN 'E-mail válido';
  ELSE
    RETURN 'E-mail inválido';
  END IF;
END valida_email;
/
SHOW ERRORS;


-----------------------------------------------------
-- TESTE EMAIL
-----------------------------------------------------
SELECT valida_email('teste@dominio.com') FROM dual; -- Válido;
SELECT valida_email('testedominio.com') FROM dual; -- Inválido;

--------------------------------------------------------------------------------
-- 1) Válida quantidade
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION valida_qtd_positiva(p_qtd IN NUMBER)
  RETURN VARCHAR2
IS
BEGIN
  IF p_qtd IS NULL OR p_qtd <= 0 THEN
    RETURN 'Quantidade inválida';
  ELSE
    RETURN 'Quantidade válida';
  END IF;
END valida_qtd_positiva;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE QUANTIDADE
-----------------------------------------------------
SELECT valida_qtd_positiva(10) FROM dual;
SELECT valida_qtd_positiva(-2) FROM dual;


--------------------------------------------------------------------------------
-- 2) LOCALIZAÇÃO / ENDEREÇOS
-- STATES / CITY / NEIGHBOURHOOD /
-- ADDRESS_MANUFACTURER / ADDRESS_STOCK / LOCATION_STOCK
--------------------------------------------------------------------------------

/* STATES */
CREATE OR REPLACE PROCEDURE oracle_challenge_create_state (
  p_state_name IN STATES.STATE_NAME%TYPE,
  p_state_id   OUT STATES.STATE_ID%TYPE
) IS
BEGIN
  INSERT INTO STATES (STATE_NAME)
  VALUES (p_state_name)
  RETURNING STATE_ID INTO p_state_id;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao criar estado: '||SQLERRM);
END oracle_challenge_create_state;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE CREATE STATE
-----------------------------------------------------
DECLARE
  v_id NUMBER;
BEGIN
  oracle_challenge_create_state('Sergipe', v_id);
  DBMS_OUTPUT.PUT_LINE('Estado criado com ID: ' || v_id);
END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_update_state (
  p_state_id   IN STATES.STATE_ID%TYPE,
  p_state_name IN STATES.STATE_NAME%TYPE
) IS
BEGIN
  UPDATE STATES
     SET STATE_NAME = p_state_name
   WHERE STATE_ID   = p_state_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Estado não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao atualizar estado: '||SQLERRM);
END oracle_challenge_update_state;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE UPDATE STATE
-----------------------------------------------------
BEGIN
  oracle_challenge_update_state(64, 'Amapá');
END;
/

CREATE OR REPLACE PROCEDURE oracle_challenge_delete_state (
  p_state_id IN STATES.STATE_ID%TYPE
) IS
BEGIN
  DELETE FROM STATES
   WHERE STATE_ID = p_state_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Estado não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20002, 'Não é possível excluir o estado. Ele pode ter cidades vinculadas.');
END oracle_challenge_delete_state;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE DELETE STATE
-----------------------------------------------------
DECLARE
  v_id NUMBER;
BEGIN
  v_id :=63;  
  oracle_challenge_delete_state(v_id);
  DBMS_OUTPUT.PUT_LINE('Excluído com sucesso: ' || v_id);
END;
/


/* CITY */
CREATE OR REPLACE PROCEDURE oracle_challenge_create_city (
  p_name_city IN CITY.NAME_CITY%TYPE,
  p_state_id  IN CITY.STATE_ID%TYPE,
  p_city_id   OUT CITY.CITY_ID%TYPE
) IS
BEGIN
  INSERT INTO CITY (NAME_CITY, STATE_ID)
  VALUES (p_name_city, p_state_id)
  RETURNING CITY_ID INTO p_city_id;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20010, 'Erro ao criar cidade (verifique STATE_ID): '||SQLERRM);
END oracle_challenge_create_city;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE CREATE CITY
-----------------------------------------------------
DECLARE
  v_state NUMBER;
  v_city  NUMBER;
BEGIN
  oracle_challenge_create_state('Sergipe', v_state);
  oracle_challenge_create_city('Aracaju', v_state, v_city);
  DBMS_OUTPUT.PUT_LINE('Cidade criada ID='||v_city);
END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_update_city (
  p_city_id    IN CITY.CITY_ID%TYPE,
  p_name_city  IN CITY.NAME_CITY%TYPE,
  p_state_id   IN CITY.STATE_ID%TYPE
) IS
BEGIN
  UPDATE CITY
     SET NAME_CITY = p_name_city,
         STATE_ID  = p_state_id
   WHERE CITY_ID   = p_city_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20011, 'Cidade não encontrada.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20010, 'Erro ao atualizar cidade: '||SQLERRM);
END oracle_challenge_update_city;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE UPDATE CITY
-----------------------------------------------------
BEGIN
  oracle_challenge_update_city( 61, 'Lagarto',  65 );
END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_city (
  p_city_id IN CITY.CITY_ID%TYPE
) IS
BEGIN
  DELETE FROM CITY
   WHERE CITY_ID = p_city_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20011, 'Cidade não encontrada.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20012, 'Não é possível excluir a cidade. Pode haver bairros vinculados.');
END oracle_challenge_delete_city;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE DELETE CITY
-----------------------------------------------------
DECLARE
  v_state NUMBER := 65;
  v_city  NUMBER := 61;
BEGIN
  oracle_challenge_delete_city(v_city);
  DBMS_OUTPUT.PUT_LINE('Cidade excluída com sucesso: ' || v_city);
END;
/

/* NEIGHBOURHOOD */
CREATE OR REPLACE PROCEDURE oracle_challenge_create_neighbourhood (
  p_neigh_name IN NEIGHBOURHOOD.NEIGH_NAME%TYPE,
  p_city_id    IN NEIGHBOURHOOD.CITY_ID%TYPE,
  p_neigh_id   OUT NEIGHBOURHOOD.NEIGH_ID%TYPE
) IS
BEGIN
  INSERT INTO NEIGHBOURHOOD (NEIGH_NAME, CITY_ID)
  VALUES (p_neigh_name, p_city_id)
  RETURNING NEIGH_ID INTO p_neigh_id;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20020, 'Erro ao criar bairro (verifique CITY_ID): '||SQLERRM);
END oracle_challenge_create_neighbourhood;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE CREATE NEIGHBOURHOOD
-----------------------------------------------------
DECLARE
  v_state NUMBER;
  v_city  NUMBER;
  v_neigh NUMBER;
BEGIN
  oracle_challenge_create_state('Alagoas '||TO_CHAR(SYSTIMESTAMP,'FF3'), v_state);
  oracle_challenge_create_city('Maceió '||TO_CHAR(SYSTIMESTAMP,'FF3'), v_state, v_city);
  oracle_challenge_create_neighbourhood('Centro', v_city, v_neigh);
  DBMS_OUTPUT.PUT_LINE('NEIGH_ID='||v_neigh);
END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_update_neighbourhood (
  p_neigh_id   IN NEIGHBOURHOOD.NEIGH_ID%TYPE,
  p_neigh_name IN NEIGHBOURHOOD.NEIGH_NAME%TYPE,
  p_city_id    IN NEIGHBOURHOOD.CITY_ID%TYPE
) IS
BEGIN
  UPDATE NEIGHBOURHOOD
     SET NEIGH_NAME = p_neigh_name,
         CITY_ID    = p_city_id
   WHERE NEIGH_ID   = p_neigh_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20021, 'Bairro não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20020, 'Erro ao atualizar bairro: '||SQLERRM);
END oracle_challenge_update_neighbourhood;
/
SHOW ERRORS;

-----------------------------------------------------
-- TESTE UPDATE
-----------------------------------------------------
DECLARE
  v_state NUMBER := 77;
  v_city  NUMBER := 74;
  v_neigh NUMBER := 62;
BEGIN

  oracle_challenge_update_neighbourhood(v_neigh, 'Novo Horizonte', v_city);

  DBMS_OUTPUT.PUT_LINE('Bairro atualizado com sucesso!');
  DBMS_OUTPUT.PUT_LINE('NEIGH_ID: ' || v_neigh);
  DBMS_OUTPUT.PUT_LINE('Novo nome: Novo Horizonte');
END;
/

CREATE OR REPLACE PROCEDURE oracle_challenge_delete_neighbourhood (
  p_neigh_id IN NEIGHBOURHOOD.NEIGH_ID%TYPE
) IS
BEGIN
  DELETE FROM NEIGHBOURHOOD
   WHERE NEIGH_ID = p_neigh_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20021, 'Bairro não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20022, 'Não é possível excluir o bairro. Pode ter endereços vinculados.');
END oracle_challenge_delete_neighbourhood;
/
SHOW ERRORS;

DECLARE
  v_state NUMBER := 77;
  v_city  NUMBER := 74;
  v_neigh NUMBER := 62;
BEGIN
  oracle_challenge_delete_neighbourhood(v_neigh);

  DBMS_OUTPUT.PUT_LINE('Bairro excluído com sucesso!');
  DBMS_OUTPUT.PUT_LINE('NEIGH_ID: ' || v_neigh);
END;
/

/* ADDRESS_MANUFACTURER */
CREATE OR REPLACE PROCEDURE oracle_challenge_create_address_manufacturer (
  p_complement              IN ADDRESS_MANUFACTURER.COMPLEMENT%TYPE,
  p_number_manu             IN ADDRESS_MANUFACTURER.NUMBER_MANU%TYPE,
  p_address_description     IN ADDRESS_MANUFACTURER.ADDRESS_DESCRIPTION%TYPE,
  p_cep                     IN ADDRESS_MANUFACTURER.CEP%TYPE,
  p_neigh_id                IN ADDRESS_MANUFACTURER.NEIGH_ID%TYPE,
  p_address_id_manufacturer OUT ADDRESS_MANUFACTURER.ADDRESS_ID_MANUFACTURER%TYPE
) IS
BEGIN
  INSERT INTO ADDRESS_MANUFACTURER (
    COMPLEMENT, NUMBER_MANU, ADDRESS_DESCRIPTION, CEP, NEIGH_ID
  ) VALUES (
    p_complement, p_number_manu, p_address_description, p_cep, p_neigh_id
  )
  RETURNING ADDRESS_ID_MANUFACTURER INTO p_address_id_manufacturer;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20030, 'Erro ao criar endereço de fabricante (verifique bairro): '||SQLERRM);
END oracle_challenge_create_address_manufacturer;
/
SHOW ERRORS;

-----------------------------------------------------
-- TESTE CREATE     
-----------------------------------------------------
DECLARE
  v_state   NUMBER;
  v_city    NUMBER;
  v_neigh   NUMBER := 14;
  v_addr_id NUMBER;
BEGIN
 

  oracle_challenge_create_address_manufacturer(
    p_complement          => 'Galpão 1',
    p_number_manu         => 123,
    p_address_description => 'Av. Principal, Qd 2',
    p_cep                 => 49000000,
    p_neigh_id            => v_neigh,
    p_address_id_manufacturer => v_addr_id
  );

  DBMS_OUTPUT.PUT_LINE('CREATE AM OK');
  DBMS_OUTPUT.PUT_LINE('STATE_ID: ' || v_state);
  DBMS_OUTPUT.PUT_LINE('CITY_ID:  ' || v_city);
  DBMS_OUTPUT.PUT_LINE('NEIGH_ID: ' || v_neigh);
  DBMS_OUTPUT.PUT_LINE('ADDRESS_ID_MANUFACTURER: ' || v_addr_id);

END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_update_address_manufacturer (
  p_address_id_manufacturer IN ADDRESS_MANUFACTURER.ADDRESS_ID_MANUFACTURER%TYPE,
  p_complement              IN ADDRESS_MANUFACTURER.COMPLEMENT%TYPE,
  p_number_manu             IN ADDRESS_MANUFACTURER.NUMBER_MANU%TYPE,
  p_address_description     IN ADDRESS_MANUFACTURER.ADDRESS_DESCRIPTION%TYPE,
  p_cep                     IN ADDRESS_MANUFACTURER.CEP%TYPE,
  p_neigh_id                IN ADDRESS_MANUFACTURER.NEIGH_ID%TYPE
) IS
BEGIN
  UPDATE ADDRESS_MANUFACTURER
     SET COMPLEMENT          = p_complement,
         NUMBER_MANU         = p_number_manu,
         ADDRESS_DESCRIPTION = p_address_description,
         CEP                 = p_cep,
         NEIGH_ID            = p_neigh_id
   WHERE ADDRESS_ID_MANUFACTURER = p_address_id_manufacturer;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20031, 'Endereço de fabricante não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20030, 'Erro ao atualizar endereço de fabricante: '||SQLERRM);
END oracle_challenge_update_address_manufacturer;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE UPDATE     
-----------------------------------------------------
DECLARE
  v_state   NUMBER := 78;
  v_city    NUMBER := 74;
  v_neigh   NUMBER := 14;
  v_addr_id NUMBER := 61;
BEGIN
  
  oracle_challenge_update_address_manufacturer(
    p_address_id_manufacturer => v_addr_id,
    p_complement              => 'Bloco A - Fundos',
    p_number_manu             => 51,
    p_address_description     => 'Rua das Flores, prox. praça',
    p_cep                     => 40000001,
    p_neigh_id                => v_neigh
  );

  DBMS_OUTPUT.PUT_LINE('UPDATE AM OK');
  DBMS_OUTPUT.PUT_LINE('ADDRESS_ID_MANUFACTURER atualizado: ' || v_addr_id);

END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_address_manufacturer (
  p_address_id_manufacturer IN ADDRESS_MANUFACTURER.ADDRESS_ID_MANUFACTURER%TYPE
) IS
BEGIN
  DELETE FROM ADDRESS_MANUFACTURER
   WHERE ADDRESS_ID_MANUFACTURER = p_address_id_manufacturer;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20031, 'Endereço de fabricante não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20032, 'Não é possível excluir: endereço ainda vinculado a fabricante.');
END oracle_challenge_delete_address_manufacturer;
/
SHOW ERRORS;

-----------------------------------------------------
-- TESTE DELETE     
-----------------------------------------------------
DECLARE
  v_state   NUMBER := 78;
  v_city    NUMBER := 74;
  v_neigh   NUMBER := 14;
  v_addr_id NUMBER := 61;
BEGIN

  oracle_challenge_delete_address_manufacturer(v_addr_id);

  DBMS_OUTPUT.PUT_LINE('DELETE AM OK');
  DBMS_OUTPUT.PUT_LINE('ADDRESS_ID_MANUFACTURER excluído: ' || v_addr_id);
END;
/

/* ADDRESS_STOCK */
CREATE OR REPLACE PROCEDURE oracle_challenge_create_address_stock (
  p_complement              IN ADDRESS_STOCK.COMPLEMENT%TYPE,
  p_number_stock            IN ADDRESS_STOCK.NUMBER_STOCK%TYPE,
  p_address_description     IN ADDRESS_STOCK.ADDRESS_DESCRIPTION%TYPE,
  p_cep                     IN ADDRESS_STOCK.CEP%TYPE,
  p_neigh_id                IN ADDRESS_STOCK.NEIGH_ID%TYPE,
  p_address_id_stock        OUT ADDRESS_STOCK.ADDRESS_ID_STOCK%TYPE
) IS
BEGIN
  INSERT INTO ADDRESS_STOCK (
    COMPLEMENT, NUMBER_STOCK, ADDRESS_DESCRIPTION, CEP, NEIGH_ID
  ) VALUES (
    p_complement, p_number_stock, p_address_description, p_cep, p_neigh_id
  )
  RETURNING ADDRESS_ID_STOCK INTO p_address_id_stock;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20040, 'Erro ao criar endereço de estoque (verifique bairro): '||SQLERRM);
END oracle_challenge_create_address_stock;
/
SHOW ERRORS;

-----------------------------------------------------
-- TESTE CREATE     
-----------------------------------------------------
DECLARE
  v_state_id      NUMBER;
  v_city_id       NUMBER;
  v_neigh_id      NUMBER;
  v_addr_stock_id NUMBER;
  v_loc_id        NUMBER;
BEGIN

  oracle_challenge_create_state('SE - LOC TEST', v_state_id);
  oracle_challenge_create_city('Aracaju LOC', v_state_id, v_city_id);
  oracle_challenge_create_neighbourhood('Centro LOC', v_city_id, v_neigh_id);

  oracle_challenge_create_address_stock(
    p_complement          => 'Depósito L1',
    p_number_stock        => 100,
    p_address_description => 'Rua A, 10',
    p_cep                 => 49020000,
    p_neigh_id            => v_neigh_id,
    p_address_id_stock    => v_addr_stock_id
  );


  oracle_challenge_create_location_stock(
    p_name_location       => 'SEDE',
    p_location_stock_name => 'Armazém Central',
    p_address_id_stock    => v_addr_stock_id,
    p_location_id_stock   => v_loc_id
  );

  DBMS_OUTPUT.PUT_LINE('CREATE OK - LOCATION_ID_STOCK='||v_loc_id||
                       ' (ADDR='||v_addr_stock_id||')');
END;
/

CREATE OR REPLACE PROCEDURE oracle_challenge_update_address_stock (
  p_address_id_stock        IN ADDRESS_STOCK.ADDRESS_ID_STOCK%TYPE,
  p_complement              IN ADDRESS_STOCK.COMPLEMENT%TYPE,
  p_number_stock            IN ADDRESS_STOCK.NUMBER_STOCK%TYPE,
  p_address_description     IN ADDRESS_STOCK.ADDRESS_DESCRIPTION%TYPE,
  p_cep                     IN ADDRESS_STOCK.CEP%TYPE,
  p_neigh_id                IN ADDRESS_STOCK.NEIGH_ID%TYPE
) IS
BEGIN
  UPDATE ADDRESS_STOCK
     SET COMPLEMENT          = p_complement,
         NUMBER_STOCK        = p_number_stock,
         ADDRESS_DESCRIPTION = p_address_description,
         CEP                 = p_cep,
         NEIGH_ID            = p_neigh_id
   WHERE ADDRESS_ID_STOCK    = p_address_id_stock;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20041, 'Endereço de estoque não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20040, 'Erro ao atualizar endereço de estoque: '||SQLERRM);
END oracle_challenge_update_address_stock;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE UPDATE     
-----------------------------------------------------
DECLARE
  v_state_id      NUMBER;
  v_city_id       NUMBER;
  v_neigh_id      NUMBER;
  v_addr_stock_id NUMBER := 61;
  v_loc_id        NUMBER :=41;
BEGIN

  oracle_challenge_update_location_stock(
    p_location_id_stock   => v_loc_id,
    p_name_location       => 'SEDE (Atualizada)',
    p_location_stock_name => 'Galpão Norte - Setor 1',
    p_address_id_stock    => v_addr_stock_id
  );

  DBMS_OUTPUT.PUT_LINE('UPDATE OK - LOCATION_ID_STOCK='||v_loc_id);
END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_address_stock (
  p_address_id_stock IN ADDRESS_STOCK.ADDRESS_ID_STOCK%TYPE
) IS
BEGIN
  DELETE FROM ADDRESS_STOCK
   WHERE ADDRESS_ID_STOCK = p_address_id_stock;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20041, 'Endereço de estoque não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20042, 'Não é possível excluir: endereço usado em local de estoque.');
END oracle_challenge_delete_address_stock;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE DELETE     
-----------------------------------------------------
DECLARE
  v_state_id      NUMBER;
  v_city_id       NUMBER;
  v_neigh_id      NUMBER;
  v_addr_stock_id NUMBER := 64;
  v_loc_id        NUMBER := 45;
BEGIN

  oracle_challenge_delete_location_stock(v_loc_id);

  DBMS_OUTPUT.PUT_LINE('DELETE OK - LOCATION_ID_STOCK='||v_loc_id);
END;
/

/* LOCATION_STOCK */

CREATE OR REPLACE PROCEDURE oracle_challenge_create_location_stock (
  p_name_location       IN LOCATION_STOCK.NAME_LOCATION%TYPE,
  p_location_stock_name IN LOCATION_STOCK.LOCATION_STOCK_NAME%TYPE,
  p_address_id_stock    IN LOCATION_STOCK.ADDRESS_ID_STOCK%TYPE,
  p_location_id_stock   OUT LOCATION_STOCK.LOCATION_ID_STOCK%TYPE
) IS
BEGIN
  INSERT INTO LOCATION_STOCK (
    NAME_LOCATION, LOCATION_STOCK_NAME, ADDRESS_ID_STOCK
  ) VALUES (
    p_name_location, p_location_stock_name, p_address_id_stock
  )
  RETURNING LOCATION_ID_STOCK INTO p_location_id_stock;

EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    
    RAISE_APPLICATION_ERROR(-20051, 'Endereço já vinculado a outro local de estoque.');
  WHEN OTHERS THEN
    
    RAISE_APPLICATION_ERROR(-20050, 'Erro ao criar local de estoque: '||SQLERRM);
END oracle_challenge_create_location_stock;
/
SHOW ERRORS;

-----------------------------------------------------
-- TESTE CREATE    
-----------------------------------------------------

DECLARE
  v_id   LOCATION_STOCK.LOCATION_ID_STOCK%TYPE;
  v_addr LOCATION_STOCK.ADDRESS_ID_STOCK%TYPE := 61;
BEGIN
  oracle_challenge_create_location_stock(
    p_name_location       => 'Almox 0711000850',
    p_location_stock_name => 'Depósito Central',
    p_address_id_stock    => v_addr,
    p_location_id_stock   => v_id
  );
  DBMS_OUTPUT.PUT_LINE('Local criado! ID: '||v_id||' (ADDR='||v_addr||')');
END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_update_location_stock (
  p_location_id_stock   IN LOCATION_STOCK.LOCATION_ID_STOCK%TYPE,
  p_name_location       IN LOCATION_STOCK.NAME_LOCATION%TYPE,
  p_location_stock_name IN LOCATION_STOCK.LOCATION_STOCK_NAME%TYPE,
  p_address_id_stock    IN LOCATION_STOCK.ADDRESS_ID_STOCK%TYPE
) IS
BEGIN
  UPDATE LOCATION_STOCK
     SET NAME_LOCATION       = p_name_location,
         LOCATION_STOCK_NAME = p_location_stock_name,
         ADDRESS_ID_STOCK    = p_address_id_stock
   WHERE LOCATION_ID_STOCK   = p_location_id_stock;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20052, 'Local de estoque não encontrado.');
  END IF;

EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20051, 'Endereço já vinculado a outro local de estoque.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20053, 'Erro ao atualizar local de estoque: '||SQLERRM);
END oracle_challenge_update_location_stock;
/
SHOW ERRORS;

-----------------------------------------------------
-- TESTE UPDATE     
------------------------------------------------------
DECLARE
  v_loc_id   LOCATION_STOCK.LOCATION_ID_STOCK%TYPE :=54;
  v_new_addr LOCATION_STOCK.ADDRESS_ID_STOCK%TYPE := 64;
BEGIN

  oracle_challenge_update_location_stock(
    p_location_id_stock   => v_loc_id,
    p_name_location       => 'Almoxarifado Atualizado',
    p_location_stock_name => 'Depósito Principal - Atualizado',
    p_address_id_stock    => v_new_addr
  );

  DBMS_OUTPUT.PUT_LINE('Local atualizado com sucesso! ID: '||v_loc_id);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro no UPDATE: '||SQLCODE||' - '||SQLERRM);
END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_location_stock (
  p_location_id_stock IN LOCATION_STOCK.LOCATION_ID_STOCK%TYPE
) IS
BEGIN
  DELETE FROM LOCATION_STOCK
   WHERE LOCATION_ID_STOCK = p_location_id_stock;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20052, 'Local de estoque não encontrado.');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    
    RAISE_APPLICATION_ERROR(-20054, 'Não é possível excluir local. Ele pode estar em uso: '||SQLERRM);
END oracle_challenge_delete_location_stock;
/
SHOW ERRORS;

-----------------------------------------------------
-- TESTE DELETE     
-----------------------------------------------------

DECLARE
  v_loc_id LOCATION_STOCK.LOCATION_ID_STOCK%TYPE := 54;
BEGIN
  oracle_challenge_delete_location_stock(
    p_location_id_stock => v_loc_id
  );

  DBMS_OUTPUT.PUT_LINE('Local excluído com sucesso! ID: '||v_loc_id);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro no DELETE: '||SQLCODE||' - '||SQLERRM);
END;
/



--------------------------------------------------------------------------------
-- 3) CONTATOS DE USUÁRIO
--------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE oracle_challenge_create_contact_user (
  p_email_user        IN  CONTACT_USER.EMAIL_USER%TYPE,
  p_phone_number_user IN  CONTACT_USER.PHONE_NUMBER_USER%TYPE,
  p_contact_user_id   OUT CONTACT_USER.CONTACT_USER_ID%TYPE
) IS
BEGIN

  IF valida_email(p_email_user) != 'E-mail válido' THEN
    RAISE_APPLICATION_ERROR(-20500, 'E-mail inválido.');
  END IF;

  INSERT INTO CONTACT_USER (EMAIL_USER, PHONE_NUMBER_USER)
  VALUES (p_email_user, p_phone_number_user)
  RETURNING CONTACT_USER_ID INTO p_contact_user_id;

EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20501, 'E-mail ou telefone já cadastrado.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20502, 'Erro ao criar contato: '||SQLERRM);
END oracle_challenge_create_contact_user;
/
SHOW ERRORS;

-----------------------------------------------------
-- TESTE CREATE
-----------------------------------------------------

DECLARE
  v_contact_id CONTACT_USER.CONTACT_USER_ID%TYPE;
BEGIN
  oracle_challenge_create_contact_user(
    p_email_user        => 'usuario.testemedsave@gmail.com',
    p_phone_number_user => 11944654321,
    p_contact_user_id   => v_contact_id
  );

  DBMS_OUTPUT.PUT_LINE('Contato criado com sucesso! ID: '||v_contact_id);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro ao criar contato: '||SQLCODE||' - '||SQLERRM);
END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_update_contact_user (
  p_contact_user_id   IN CONTACT_USER.CONTACT_USER_ID%TYPE,
  p_email_user        IN CONTACT_USER.EMAIL_USER%TYPE,
  p_phone_number_user IN CONTACT_USER.PHONE_NUMBER_USER%TYPE
) IS
BEGIN

  IF valida_email(p_email_user) != 'E-mail válido' THEN
    RAISE_APPLICATION_ERROR(-20500, 'E-mail inválido.');
  END IF;

  UPDATE CONTACT_USER
     SET EMAIL_USER        = p_email_user,
         PHONE_NUMBER_USER = p_phone_number_user
   WHERE CONTACT_USER_ID   = p_contact_user_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20504, 'Contato não encontrado.');
  END IF;

EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20501, 'E-mail ou telefone já cadastrado.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20503, 'Erro ao atualizar contato: '||SQLERRM);
END oracle_challenge_update_contact_user;
/
SHOW ERRORS;

-----------------------------------------------------
-- TESTE UPDATE       
-----------------------------------------------------


DECLARE
  v_id CONTACT_USER.CONTACT_USER_ID%TYPE := 30;
BEGIN

  oracle_challenge_update_contact_user(
    p_contact_user_id   => v_id,
    p_email_user        => 'cli.update.medsave@mail.com',
    p_phone_number_user => 11955551111
  );

  DBMS_OUTPUT.PUT_LINE('Contato atualizado! ID: '||v_id);
END;
/



CREATE OR REPLACE PROCEDURE oracle_challenge_delete_contact_user (
  p_contact_user_id IN CONTACT_USER.CONTACT_USER_ID%TYPE
) IS
BEGIN
  DELETE FROM CONTACT_USER
   WHERE CONTACT_USER_ID = p_contact_user_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20504, 'Contato não encontrado.');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    
    RAISE_APPLICATION_ERROR(-20505, 'Não é possível excluir contato. Ele pode estar em uso: '||SQLERRM);
END oracle_challenge_delete_contact_user;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE DELETE
-----------------------------------------------------
DECLARE
  v_id CONTACT_USER.CONTACT_USER_ID%TYPE := 30;
BEGIN


  oracle_challenge_delete_contact_user(p_contact_user_id => v_id);
  DBMS_OUTPUT.PUT_LINE('Contato excluído! ID: '||v_id);
END;
/




--------------------------------------------------------------------------------
-- 4) USUÁRIOS / PERFIL / PAPEL
-- ROLE_USER / PROFILE_USER / USERS_SYS
--------------------------------------------------------------------------------

/* ROLE_USER */
CREATE OR REPLACE PROCEDURE oracle_challenge_create_role_user (
  p_user_role    IN ROLE_USER.USER_ROLE%TYPE,
  p_role_user_id OUT ROLE_USER.ROLE_USER_ID%TYPE
) IS
BEGIN
  INSERT INTO ROLE_USER (USER_ROLE)
  VALUES (p_user_role)
  RETURNING ROLE_USER_ID INTO p_role_user_id;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20001, 'Erro ao criar role: '||SQLERRM);
END oracle_challenge_create_role_user;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE CREATE      
-----------------------------------------------------
DECLARE
  v_role_id NUMBER;
BEGIN

  oracle_challenge_create_role_user(
    p_user_role    => 'ROLE_TESTE_PRINTS',
    p_role_user_id => v_role_id
  );
  DBMS_OUTPUT.PUT_LINE('ROLE criada com ID: ' || v_role_id);

END;
/

CREATE OR REPLACE PROCEDURE oracle_challenge_update_role_user (
  p_role_user_id IN ROLE_USER.ROLE_USER_ID%TYPE,
  p_user_role    IN ROLE_USER.USER_ROLE%TYPE
) IS
BEGIN
  UPDATE ROLE_USER
     SET USER_ROLE = p_user_role
   WHERE ROLE_USER_ID = p_role_user_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Role não encontrada.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao atualizar role: '||SQLERRM);
END oracle_challenge_update_role_user;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE UPDATE      
-----------------------------------------------------
DECLARE
  v_role_id NUMBER := 21;
BEGIN

  oracle_challenge_update_role_user(
    p_role_user_id => v_role_id,
    p_user_role    => 'ROLE_TESTE_PRINTS_ATUALIZADA'
  );
  DBMS_OUTPUT.PUT_LINE('ROLE atualizada (ID: ' || v_role_id || ').');
END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_role_user (
  p_role_user_id IN ROLE_USER.ROLE_USER_ID%TYPE
) IS
BEGIN
  DELETE FROM ROLE_USER
   WHERE ROLE_USER_ID = p_role_user_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Role não encontrada.');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20002, 'Não é possível excluir role. Ela pode estar em uso.');
END oracle_challenge_delete_role_user;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE DELETE     
-----------------------------------------------------
DECLARE
  v_role_id NUMBER;
BEGIN

  SELECT MAX(ROLE_USER_ID)
    INTO v_role_id
    FROM ROLE_USER
   WHERE USER_ROLE = 'ROLE_TESTE_PRINTS_ATUALIZADA';

  oracle_challenge_delete_role_user(v_role_id);
  DBMS_OUTPUT.PUT_LINE('ROLE excluída com sucesso: ' || v_role_id);
END;
/

/* PROFILE_USER */
CREATE OR REPLACE PROCEDURE oracle_challenge_create_profile_user (
  p_user_profile IN PROFILE_USER.USER_PROFILE%TYPE,
  p_prof_user_id OUT PROFILE_USER.PROF_USER_ID%TYPE
) IS
BEGIN
  INSERT INTO PROFILE_USER (USER_PROFILE)
  VALUES (p_user_profile)
  RETURNING PROF_USER_ID INTO p_prof_user_id;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100, 'Erro ao criar perfil: '||SQLERRM);
END oracle_challenge_create_profile_user;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE CREATE
-----------------------------------------------------
DECLARE
  v_prof_id NUMBER;
BEGIN
  oracle_challenge_create_profile_user(
    p_user_profile => 'PERFIL_TESTE_PRINTS',
    p_prof_user_id => v_prof_id
  );
  DBMS_OUTPUT.PUT_LINE('Perfil criado com ID: ' || v_prof_id || ' (PERFIL_TESTE_PRINTS)');
END;
/

CREATE OR REPLACE PROCEDURE oracle_challenge_update_profile_user (
  p_prof_user_id IN PROFILE_USER.PROF_USER_ID%TYPE,
  p_user_profile IN PROFILE_USER.USER_PROFILE%TYPE
) IS
BEGIN
  UPDATE PROFILE_USER
     SET USER_PROFILE = p_user_profile
   WHERE PROF_USER_ID = p_prof_user_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20101, 'Perfil não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100, 'Erro ao atualizar perfil: '||SQLERRM);
END oracle_challenge_update_profile_user;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE UPDATE
-----------------------------------------------------
DECLARE
  v_prof_id NUMBER;
BEGIN
  SELECT PROF_USER_ID
    INTO v_prof_id
    FROM PROFILE_USER
   WHERE USER_PROFILE = 'PERFIL_TESTE_PRINTS'
   FETCH FIRST 1 ROWS ONLY;

  oracle_challenge_update_profile_user(
    p_prof_user_id => v_prof_id,
    p_user_profile => 'PERFIL_TESTE_PRINTS_ATUALIZADO'
  );

  DBMS_OUTPUT.PUT_LINE('Perfil atualizado. ID: '||v_prof_id||' -> PERFIL_TESTE_PRINTS_ATUALIZADO');
END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_profile_user (
  p_prof_user_id IN PROFILE_USER.PROF_USER_ID%TYPE
) IS
BEGIN
  DELETE FROM PROFILE_USER
   WHERE PROF_USER_ID = p_prof_user_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20101, 'Perfil não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20102, 'Não é possível excluir perfil. Ele pode estar em uso.');
END oracle_challenge_delete_profile_user;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE DELETE
-----------------------------------------------------
DECLARE
  v_prof_id NUMBER;
BEGIN
  SELECT PROF_USER_ID
    INTO v_prof_id
    FROM PROFILE_USER
   WHERE USER_PROFILE = 'PERFIL_TESTE_PRINTS_ATUALIZADO'
   FETCH FIRST 1 ROWS ONLY;

  oracle_challenge_delete_profile_user(
    p_prof_user_id => v_prof_id
  );

  DBMS_OUTPUT.PUT_LINE('Perfil excluído. ID: '||v_prof_id);
END;
/

/* USERS_SYS */
CREATE OR REPLACE PROCEDURE oracle_challenge_create_user_sys (
  p_name_user        IN USERS_SYS.NAME_USER%TYPE,
  p_login            IN USERS_SYS.LOGIN%TYPE,
  p_password_user    IN USERS_SYS.PASSWORD_USER%TYPE,
  p_role_user_id     IN USERS_SYS.ROLE_USER_ID%TYPE,
  p_prof_user_id     IN USERS_SYS.PROF_USER_ID%TYPE,
  p_contact_user_id  IN USERS_SYS.CONTACT_USER_ID%TYPE,
  p_user_id          OUT USERS_SYS.USER_ID%TYPE
) IS
BEGIN
  INSERT INTO USERS_SYS (
    NAME_USER, LOGIN, PASSWORD_USER,
    ROLE_USER_ID, PROF_USER_ID, CONTACT_USER_ID
  ) VALUES (
    p_name_user, p_login, p_password_user,
    p_role_user_id, p_prof_user_id, p_contact_user_id
  )
  RETURNING USER_ID INTO p_user_id;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20200, 'Login já utilizado.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20201, 'Erro ao criar usuário. Verifique role/perfil/contato: '||SQLERRM);
END oracle_challenge_create_user_sys;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE CREATE
-----------------------------------------------------
DECLARE
  v_role_id    ROLE_USER.ROLE_USER_ID%TYPE := 1; 
  v_prof_id    PROFILE_USER.PROF_USER_ID%TYPE := 1;
  v_contact_id CONTACT_USER.CONTACT_USER_ID%TYPE := 1;
  v_user_id    USERS_SYS.USER_ID%TYPE;
BEGIN
  oracle_challenge_create_user_sys(
    p_name_user        => 'Usuário Teste Prints',
    p_login            => 'login_teste_prints_' || TO_CHAR(SYSDATE, 'DDMMHH24MISS'),
    p_password_user    => 'senha@123',
    p_role_user_id     => v_role_id,
    p_prof_user_id     => v_prof_id,
    p_contact_user_id  => v_contact_id,
    p_user_id          => v_user_id
  );

  DBMS_OUTPUT.PUT_LINE('Usuário criado com sucesso! ID: ' || v_user_id);
END;
/

CREATE OR REPLACE PROCEDURE oracle_challenge_update_user_sys (
  p_user_id          IN USERS_SYS.USER_ID%TYPE,
  p_name_user        IN USERS_SYS.NAME_USER%TYPE,
  p_login            IN USERS_SYS.LOGIN%TYPE,
  p_password_user    IN USERS_SYS.PASSWORD_USER%TYPE,
  p_role_user_id     IN USERS_SYS.ROLE_USER_ID%TYPE,
  p_prof_user_id     IN USERS_SYS.PROF_USER_ID%TYPE,
  p_contact_user_id  IN USERS_SYS.CONTACT_USER_ID%TYPE
) IS
BEGIN
  UPDATE USERS_SYS
     SET NAME_USER        = p_name_user,
         LOGIN            = p_login,
         PASSWORD_USER    = p_password_user,
         ROLE_USER_ID     = p_role_user_id,
         PROF_USER_ID     = p_prof_user_id,
         CONTACT_USER_ID  = p_contact_user_id
   WHERE USER_ID          = p_user_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20202, 'Usuário não encontrado.');
  END IF;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20200, 'Login já utilizado por outro usuário.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20203, 'Erro ao atualizar usuário: '||SQLERRM);
END oracle_challenge_update_user_sys;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE UPDATE
-----------------------------------------------------
DECLARE
  v_user_id    USERS_SYS.USER_ID%TYPE := 1;  
  v_role_id    ROLE_USER.ROLE_USER_ID%TYPE := 1;  
  v_prof_id    PROFILE_USER.PROF_USER_ID%TYPE := 1; 
  v_contact_id CONTACT_USER.CONTACT_USER_ID%TYPE := 1;  
BEGIN
  oracle_challenge_update_user_sys(
    p_user_id          => v_user_id,
    p_name_user        => 'Usuário Atualizado Prints',
    p_login            => 'login_atualizado_' || TO_CHAR(SYSDATE, 'DDMMHH24MISS'),
    p_password_user    => 'novaSenha@123',
    p_role_user_id     => v_role_id,
    p_prof_user_id     => v_prof_id,
    p_contact_user_id  => v_contact_id
  );

  DBMS_OUTPUT.PUT_LINE('Usuário atualizado com sucesso! ID: ' || v_user_id);
END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_user_sys (
  p_user_id IN USERS_SYS.USER_ID%TYPE
) IS
BEGIN
  DELETE FROM USERS_SYS
   WHERE USER_ID = p_user_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20202, 'Usuário não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(
      -20999,
      'Não é possível excluir usuário. Ele pode estar vinculado a movimentações.'
    );
END oracle_challenge_delete_user_sys;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE DELETE
-----------------------------------------------------
DECLARE
  v_user_id USERS_SYS.USER_ID%TYPE := 61; 
BEGIN
  oracle_challenge_delete_user_sys(
    p_user_id => v_user_id
  );

  DBMS_OUTPUT.PUT_LINE('Usuário excluído com sucesso! ID: ' || v_user_id);
END;
/

--------------------------------------------------------------------------------
-- 5) FABRICANTES
-- CONTACT_MANUFACTURER / MANUFACTURER
--------------------------------------------------------------------------------

/* CONTACT_MANUFACTURER */
CREATE OR REPLACE PROCEDURE oracle_challenge_create_contact_manufacturer (
  p_email_manu        IN CONTACT_MANUFACTURER.EMAIL_MANU%TYPE,
  p_phone_number_manu IN CONTACT_MANUFACTURER.PHONE_NUMBER_MANU%TYPE,
  p_contact_manu_id   OUT CONTACT_MANUFACTURER.CONTACT_MANU_ID%TYPE
) IS
BEGIN
  
  IF valida_email(p_email_manu) != 'E-mail válido' THEN
    RAISE_APPLICATION_ERROR(-20520, 'E-mail inválido para fabricante.');
  END IF;

  INSERT INTO CONTACT_MANUFACTURER (
    EMAIL_MANU, PHONE_NUMBER_MANU
  ) VALUES (
    p_email_manu, p_phone_number_manu
  )
  RETURNING CONTACT_MANU_ID INTO p_contact_manu_id;

EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20521, 'E-mail ou telefone já cadastrado.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20522, 'Erro ao criar contato de fabricante: '||SQLERRM);
END oracle_challenge_create_contact_manufacturer;
/
SHOW ERRORS;

-----------------------------------------------------
-- TESTE CREATE
-----------------------------------------------------
DECLARE
  v_contact_manu_id CONTACT_MANUFACTURER.CONTACT_MANU_ID%TYPE;
BEGIN
  oracle_challenge_create_contact_manufacturer(
    p_email_manu        => 'fabricante_MEDSAVE@exemplo.com',
    p_phone_number_manu => '11993445453',
    p_contact_manu_id   => v_contact_manu_id
  );
  DBMS_OUTPUT.PUT_LINE('Contato criado! ID: ' || v_contact_manu_id);
END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_update_contact_manufacturer (
  p_contact_manu_id   IN CONTACT_MANUFACTURER.CONTACT_MANU_ID%TYPE,
  p_email_manu        IN CONTACT_MANUFACTURER.EMAIL_MANU%TYPE,
  p_phone_number_manu IN CONTACT_MANUFACTURER.PHONE_NUMBER_MANU%TYPE
) IS
BEGIN

  IF valida_email(p_email_manu) != 'E-mail válido' THEN
    RAISE_APPLICATION_ERROR(-20520, 'E-mail inválido para fabricante.');
  END IF;

  UPDATE CONTACT_MANUFACTURER
     SET EMAIL_MANU        = p_email_manu,
         PHONE_NUMBER_MANU = p_phone_number_manu
   WHERE CONTACT_MANU_ID   = p_contact_manu_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20523, 'Contato de fabricante não encontrado.');
  END IF;

EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20521, 'E-mail ou telefone já cadastrado.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20524, 'Erro ao atualizar contato de fabricante: '||SQLERRM);
END oracle_challenge_update_contact_manufacturer;
/
SHOW ERRORS;

-----------------------------------------------------
-- TESTE UPDATE
-----------------------------------------------------
DECLARE
  v_id CONTACT_MANUFACTURER.CONTACT_MANU_ID%TYPE := 21;
BEGIN
  oracle_challenge_update_contact_manufacturer(
    p_contact_manu_id   => v_id,
    p_email_manu        => 'fabricante_update_@exemplo.com',
    p_phone_number_manu => '1198542333'
  );

  DBMS_OUTPUT.PUT_LINE('Contato de fabricante atualizado! ID: ' || v_id);
END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_contact_manufacturer (
  p_contact_manu_id IN CONTACT_MANUFACTURER.CONTACT_MANU_ID%TYPE
) IS
BEGIN
  DELETE FROM CONTACT_MANUFACTURER
   WHERE CONTACT_MANU_ID = p_contact_manu_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20523, 'Contato de fabricante não encontrado.');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(
      -20526,
      'Não é possível excluir contato de fabricante. Ele pode estar em uso: '||SQLERRM
    );
END oracle_challenge_delete_contact_manufacturer;
/
-----------------------------------------------------
-- TESTE DELETE
-----------------------------------------------------
DECLARE
  v_id CONTACT_MANUFACTURER.CONTACT_MANU_ID%TYPE := 21;
BEGIN
  oracle_challenge_delete_contact_manufacturer(
    p_contact_manu_id => v_id
  );

  DBMS_OUTPUT.PUT_LINE('Contato de fabricante excluído! ID: ' || v_id);
END;
/

/* MANUFACTURER */
CREATE OR REPLACE PROCEDURE oracle_challenge_create_manufacturer (
  p_name_manu               IN MANUFACTURER.NAME_MANU%TYPE,
  p_cnpj                    IN MANUFACTURER.CNPJ%TYPE,
  p_address_id_manufacturer IN MANUFACTURER.ADDRESS_ID_MANUFACTURER%TYPE,
  p_contact_manu_id         IN MANUFACTURER.CONTACT_MANU_ID%TYPE,
  p_manufac_id              OUT MANUFACTURER.MANUFAC_ID%TYPE
) IS
BEGIN
  INSERT INTO MANUFACTURER (
    NAME_MANU, CNPJ, ADDRESS_ID_MANUFACTURER, CONTACT_MANU_ID
  ) VALUES (
    p_name_manu, p_cnpj, p_address_id_manufacturer, p_contact_manu_id
  )
  RETURNING MANUFAC_ID INTO p_manufac_id;

EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20530, 'CNPJ já cadastrado.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20531, 'Erro ao criar fabricante. Verifique endereço/contato: '||SQLERRM);
END oracle_challenge_create_manufacturer;
/
SHOW ERRORS;

DECLARE
  v_manu_id      MANUFACTURER.MANUFAC_ID%TYPE;
  v_addr_id      MANUFACTURER.ADDRESS_ID_MANUFACTURER%TYPE := 1; 
  v_contact_id   MANUFACTURER.CONTACT_MANU_ID%TYPE := 1;         
BEGIN
  oracle_challenge_create_manufacturer(
    p_name_manu               => 'Fabricante Prints ',
    p_cnpj                    => 12345678000100,
    p_address_id_manufacturer => v_addr_id,
    p_contact_manu_id         => v_contact_id,
    p_manufac_id              => v_manu_id
  );

  DBMS_OUTPUT.PUT_LINE('Fabricante criado! ID: ' || v_manu_id);
END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_update_manufacturer (
  p_manufac_id            IN MANUFACTURER.MANUFAC_ID%TYPE,
  p_name_manu             IN MANUFACTURER.NAME_MANU%TYPE,
  p_cnpj                  IN MANUFACTURER.CNPJ%TYPE,
  p_address_id_manufacturer IN MANUFACTURER.ADDRESS_ID_MANUFACTURER%TYPE,
  p_contact_manu_id       IN MANUFACTURER.CONTACT_MANU_ID%TYPE
) IS
BEGIN
  UPDATE MANUFACTURER
     SET NAME_MANU               = p_name_manu,
         CNPJ                    = p_cnpj,
         ADDRESS_ID_MANUFACTURER = p_address_id_manufacturer,
         CONTACT_MANU_ID         = p_contact_manu_id
   WHERE MANUFAC_ID              = p_manufac_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20533, 'Fabricante não encontrado.');
  END IF;

EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20530, 'CNPJ já cadastrado.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20534, 'Erro ao atualizar fabricante: '||SQLERRM);
END oracle_challenge_update_manufacturer;
/
SHOW ERRORS;

SELECT * FROM MANUFACTURER;
-----------------------------------------------------
-- TESTE UPDATE 
-----------------------------------------------------
DECLARE
  v_id        MANUFACTURER.MANUFAC_ID%TYPE := 21;   
  v_addr_id   MANUFACTURER.ADDRESS_ID_MANUFACTURER%TYPE := 1; 
  v_contact   MANUFACTURER.CONTACT_MANU_ID%TYPE := 1;
BEGIN
  oracle_challenge_update_manufacturer(
    p_manufac_id            => v_id,
    p_name_manu             => 'Fabricante Atualizado',
    p_cnpj                  => 33333333000455,
    p_address_id_manufacturer => v_addr_id,
    p_contact_manu_id       => v_contact
  );
  DBMS_OUTPUT.PUT_LINE('Fabricante atualizado! ID: ' || v_id);
END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_manufacturer (
  p_manufac_id IN MANUFACTURER.MANUFAC_ID%TYPE
) IS
BEGIN
  DELETE FROM MANUFACTURER
   WHERE MANUFAC_ID = p_manufac_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20102, 'Fabricante não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20104, 'Não é possível excluir fabricante. Ele pode ter lote vinculado.');
END oracle_challenge_delete_manufacturer;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE DELETE 
-----------------------------------------------------
DECLARE
  v_id MANUFACTURER.MANUFAC_ID%TYPE := 21;
BEGIN
  oracle_challenge_delete_manufacturer(p_manufac_id => v_id);
  DBMS_OUTPUT.PUT_LINE('Fabricante excluído! ID: ' || v_id);
END;
/


--------------------------------------------------------------------------------
-- 6) CATÁLOGO DE MEDICAMENTOS
-- ACTIVE_INGREDIENT / PHARMACEUTICAL_FORM /
-- UNIT_MEASURE / CATEGORY_MEDICINE / MEDICINES /
-- MEDICINE_ACTIVE_INGR / MEDICINE_PHARM_FORM /
-- MOVEMENT_TYPE
--------------------------------------------------------------------------------

/* ACTIVE_INGREDIENT */
CREATE OR REPLACE PROCEDURE oracle_challenge_create_active_ingredient (
  p_act_ingredient IN ACTIVE_INGREDIENT.ACT_INGREDIENT%TYPE,
  p_act_ingre_id   OUT ACTIVE_INGREDIENT.ACT_INGRE_ID%TYPE
) IS
BEGIN
  INSERT INTO ACTIVE_INGREDIENT (ACT_INGREDIENT)
  VALUES (p_act_ingredient)
  RETURNING ACT_INGRE_ID INTO p_act_ingre_id;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20001, 'Erro ao criar princípio ativo: '||SQLERRM);
END oracle_challenge_create_active_ingredient;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE CREATE 
-----------------------------------------------------
DECLARE
  v_act_ingre_id ACTIVE_INGREDIENT.ACT_INGRE_ID%TYPE;
BEGIN
  oracle_challenge_create_active_ingredient(
    p_act_ingredient => 'Ingrediente Ativo',
    p_act_ingre_id   => v_act_ingre_id
  );

  DBMS_OUTPUT.PUT_LINE('Princípio ativo criado com sucesso! ID: ' || v_act_ingre_id);
END;
/

CREATE OR REPLACE PROCEDURE oracle_challenge_update_active_ingredient (
  p_act_ingre_id   IN ACTIVE_INGREDIENT.ACT_INGRE_ID%TYPE,
  p_act_ingredient IN ACTIVE_INGREDIENT.ACT_INGREDIENT%TYPE
) IS
BEGIN
  UPDATE ACTIVE_INGREDIENT
     SET ACT_INGREDIENT = p_act_ingredient
   WHERE ACT_INGRE_ID   = p_act_ingre_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Princípio ativo não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20002, 'Erro ao atualizar princípio ativo: '||SQLERRM);
END oracle_challenge_update_active_ingredient;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE UPDATE
-----------------------------------------------------
DECLARE
  v_id ACTIVE_INGREDIENT.ACT_INGRE_ID%TYPE := 27;
BEGIN
  oracle_challenge_update_active_ingredient(
    p_act_ingre_id   => v_id,
    p_act_ingredient => 'Ativo_Atualizado'
  );

  DBMS_OUTPUT.PUT_LINE('Princípio ativo atualizado! ID: ' || v_id);
END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_active_ingredient (
  p_act_ingre_id IN ACTIVE_INGREDIENT.ACT_INGRE_ID%TYPE
) IS
BEGIN
  DELETE FROM ACTIVE_INGREDIENT
   WHERE ACT_INGRE_ID = p_act_ingre_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Princípio ativo não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20003, 'Não é possível excluir princípio ativo (está vinculado a medicamento?).');
END oracle_challenge_delete_active_ingredient;
/
SHOW ERRORS;

-----------------------------------------------------
-- TESTE DELETE 
-----------------------------------------------------
DECLARE
  v_id ACTIVE_INGREDIENT.ACT_INGRE_ID%TYPE := 27;
BEGIN
  oracle_challenge_delete_active_ingredient(p_act_ingre_id => v_id);
  DBMS_OUTPUT.PUT_LINE('Princípio ativo excluído! ID: ' || v_id);
END;
/


/* PHARMACEUTICAL_FORM */
CREATE OR REPLACE PROCEDURE oracle_challenge_create_pharm_form (
  p_pharma_form   IN PHARMACEUTICAL_FORM.PHARMA_FORM%TYPE,
  p_pharm_form_id OUT PHARMACEUTICAL_FORM.PHARM_FORM_ID%TYPE
) IS
BEGIN
  INSERT INTO PHARMACEUTICAL_FORM (PHARMA_FORM)
  VALUES (p_pharma_form)
  RETURNING PHARM_FORM_ID INTO p_pharm_form_id;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100, 'Erro ao criar forma farmacêutica: '||SQLERRM);
END oracle_challenge_create_pharm_form;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE CREATE 
-----------------------------------------------------
DECLARE
  v_pharm_form_id PHARMACEUTICAL_FORM.PHARM_FORM_ID%TYPE;
BEGIN
  oracle_challenge_create_pharm_form(
    p_pharma_form   => 'Forma_PHARMACEUTICAL_FORM',
    p_pharm_form_id => v_pharm_form_id
  );

  DBMS_OUTPUT.PUT_LINE('Forma farmacêutica criada com sucesso! ID: ' || v_pharm_form_id);
END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_update_pharm_form (
  p_pharm_form_id IN PHARMACEUTICAL_FORM.PHARM_FORM_ID%TYPE,
  p_pharma_form   IN PHARMACEUTICAL_FORM.PHARMA_FORM%TYPE
) IS
BEGIN
  UPDATE PHARMACEUTICAL_FORM
     SET PHARMA_FORM = p_pharma_form
   WHERE PHARM_FORM_ID = p_pharm_form_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20101, 'Forma farmacêutica não encontrada.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20102, 'Erro ao atualizar forma farmacêutica: '||SQLERRM);
END oracle_challenge_update_pharm_form;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE UPDATE 
-----------------------------------------------------
DECLARE
  v_id PHARMACEUTICAL_FORM.PHARM_FORM_ID%TYPE := 21; 
BEGIN
  oracle_challenge_update_pharm_form(
    p_pharm_form_id => v_id,
    p_pharma_form   => 'FormaAtualizada NOVA'
  );

  DBMS_OUTPUT.PUT_LINE('Forma farmacêutica atualizada! ID: ' || v_id);
END;
/



CREATE OR REPLACE PROCEDURE oracle_challenge_delete_pharm_form (
  p_pharm_form_id IN PHARMACEUTICAL_FORM.PHARM_FORM_ID%TYPE
) IS
BEGIN
  DELETE FROM PHARMACEUTICAL_FORM
   WHERE PHARM_FORM_ID = p_pharm_form_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20101, 'Forma farmacêutica não encontrada.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20103, 'Não é possível excluir forma farmacêutica (pode estar vinculada).');
END oracle_challenge_delete_pharm_form;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE DELETE SIMPLES
-----------------------------------------------------
DECLARE
  v_id PHARMACEUTICAL_FORM.PHARM_FORM_ID%TYPE := 21; 
BEGIN
  oracle_challenge_delete_pharm_form(p_pharm_form_id => v_id);
  DBMS_OUTPUT.PUT_LINE('Forma farmacêutica excluída! ID: ' || v_id);
END;
/


/* UNIT_MEASURE */
CREATE OR REPLACE PROCEDURE oracle_challenge_create_unit_measure (
  p_unit_measure_medicine IN UNIT_MEASURE.UNIT_MEASURE_MEDICINE%TYPE,
  p_unit_mea_id           OUT UNIT_MEASURE.UNIT_MEA_ID%TYPE
) IS
BEGIN
  INSERT INTO UNIT_MEASURE (UNIT_MEASURE_MEDICINE)
  VALUES (p_unit_measure_medicine)
  RETURNING UNIT_MEA_ID INTO p_unit_mea_id;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20200, 'Erro ao criar unidade de medida: '||SQLERRM);
END oracle_challenge_create_unit_measure;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE CREATE 
-----------------------------------------------------
DECLARE
  v_unit_id UNIT_MEASURE.UNIT_MEA_ID%TYPE;
BEGIN
  oracle_challenge_create_unit_measure(
    p_unit_measure_medicine => 'UN_teste',
    p_unit_mea_id           => v_unit_id
  );
  DBMS_OUTPUT.PUT_LINE('Unidade de medida criada! ID: ' || v_unit_id);
END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_update_unit_measure (
  p_unit_mea_id           IN UNIT_MEASURE.UNIT_MEA_ID%TYPE,
  p_unit_measure_medicine IN UNIT_MEASURE.UNIT_MEASURE_MEDICINE%TYPE
) IS
BEGIN
  UPDATE UNIT_MEASURE
     SET UNIT_MEASURE_MEDICINE = p_unit_measure_medicine
   WHERE UNIT_MEA_ID           = p_unit_mea_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20201, 'Unidade de medida não encontrada.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20202, 'Erro ao atualizar unidade de medida: '||SQLERRM);
END oracle_challenge_update_unit_measure;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE UPDATE 
-----------------------------------------------------
DECLARE
  v_id UNIT_MEASURE.UNIT_MEA_ID%TYPE := 24; 
BEGIN
  oracle_challenge_update_unit_measure(
    p_unit_mea_id           => v_id,
    p_unit_measure_medicine => 'UN_ATUALIZADA'
  );
  DBMS_OUTPUT.PUT_LINE('Unidade de medida atualizada! ID: ' || v_id);
END;
/



CREATE OR REPLACE PROCEDURE oracle_challenge_delete_unit_measure (
  p_unit_mea_id IN UNIT_MEASURE.UNIT_MEA_ID%TYPE
) IS
BEGIN
  DELETE FROM UNIT_MEASURE
   WHERE UNIT_MEA_ID = p_unit_mea_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20201, 'Unidade de medida não encontrada.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20203, 'Não é possível excluir unidade de medida (pode estar em uso).');
END oracle_challenge_delete_unit_measure;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE DELETE SIMPLES
-----------------------------------------------------
DECLARE
  v_id UNIT_MEASURE.UNIT_MEA_ID%TYPE := 24;
BEGIN
  oracle_challenge_delete_unit_measure(p_unit_mea_id => v_id);
  DBMS_OUTPUT.PUT_LINE('Unidade de medida excluída! ID: ' || v_id);
END;
/



/* CATEGORY_MEDICINE */
CREATE OR REPLACE PROCEDURE oracle_challenge_create_category_medicine (
  p_category        IN CATEGORY_MEDICINE.CATEGORY%TYPE,
  p_category_med_id OUT CATEGORY_MEDICINE.CATEGORY_MED_ID%TYPE
) IS
BEGIN
  INSERT INTO CATEGORY_MEDICINE (CATEGORY)
  VALUES (p_category)
  RETURNING CATEGORY_MED_ID INTO p_category_med_id;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20300, 'Erro ao criar categoria: '||SQLERRM);
END oracle_challenge_create_category_medicine;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE CREATE 
-----------------------------------------------------
DECLARE
  v_category_med_id CATEGORY_MEDICINE.CATEGORY_MED_ID%TYPE;
BEGIN
  oracle_challenge_create_category_medicine(
    p_category        => 'Categoria_NOVA',
    p_category_med_id => v_category_med_id
  );

  DBMS_OUTPUT.PUT_LINE('Categoria criada com sucesso! ID: ' || v_category_med_id);
END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_update_category_medicine (
  p_category_med_id IN CATEGORY_MEDICINE.CATEGORY_MED_ID%TYPE,
  p_category        IN CATEGORY_MEDICINE.CATEGORY%TYPE
) IS
BEGIN
  UPDATE CATEGORY_MEDICINE
     SET CATEGORY = p_category
   WHERE CATEGORY_MED_ID = p_category_med_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20301, 'Categoria não encontrada.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20302, 'Erro ao atualizar categoria: '||SQLERRM);
END oracle_challenge_update_category_medicine;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE UPDATE 
-----------------------------------------------------
DECLARE
  v_id CATEGORY_MEDICINE.CATEGORY_MED_ID%TYPE := 28; 
BEGIN
  oracle_challenge_update_category_medicine(
    p_category_med_id => v_id,
    p_category        => 'Categoria_Atualizada'
  );

  DBMS_OUTPUT.PUT_LINE('Categoria atualizada! ID: ' || v_id);
END;
/



CREATE OR REPLACE PROCEDURE oracle_challenge_delete_category_medicine (
  p_category_med_id IN CATEGORY_MEDICINE.CATEGORY_MED_ID%TYPE
) IS
BEGIN
  DELETE FROM CATEGORY_MEDICINE
   WHERE CATEGORY_MED_ID = p_category_med_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20301, 'Categoria não encontrada.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20303, 'Não é possível excluir categoria (pode estar em uso por medicamento).');
END oracle_challenge_delete_category_medicine;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE DELETE 
-----------------------------------------------------
DECLARE
  v_id CATEGORY_MEDICINE.CATEGORY_MED_ID%TYPE := 27; 
BEGIN
  oracle_challenge_delete_category_medicine(p_category_med_id => v_id);
  DBMS_OUTPUT.PUT_LINE('Categoria excluída! ID: ' || v_id);
END;
/




/* MEDICINES */
CREATE OR REPLACE PROCEDURE oracle_challenge_create_medicine (
  p_name_medication IN MEDICINES.NAME_MEDICATION%TYPE,
  p_status_med      IN MEDICINES.STATUS_MED%TYPE,
  p_category_med_id IN MEDICINES.CATEGORY_MED_ID%TYPE,
  p_unit_mea_id     IN MEDICINES.UNIT_MEA_ID%TYPE,
  p_medicine_id     OUT MEDICINES.MEDICINE_ID%TYPE
) IS
BEGIN
  INSERT INTO MEDICINES (
    NAME_MEDICATION, STATUS_MED, CATEGORY_MED_ID, UNIT_MEA_ID
  ) VALUES (
    p_name_medication, p_status_med, p_category_med_id, p_unit_mea_id
  )
  RETURNING MEDICINE_ID INTO p_medicine_id;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20400, 'Erro ao criar medicamento. Verifique categoria/unidade/status: '||SQLERRM);
END oracle_challenge_create_medicine;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE CREATE 
-----------------------------------------------------
DECLARE
  v_medicine_id MEDICINES.MEDICINE_ID%TYPE;
  v_cat_id      MEDICINES.CATEGORY_MED_ID%TYPE := 1; 
  v_unit_id     MEDICINES.UNIT_MEA_ID%TYPE     := 1; 
BEGIN
  oracle_challenge_create_medicine(
    p_name_medication => 'Medicamento NOVO',
    p_status_med      => 'ATIVO',      
    p_category_med_id => v_cat_id,
    p_unit_mea_id     => v_unit_id,
    p_medicine_id     => v_medicine_id
  );

  DBMS_OUTPUT.PUT_LINE('Medicamento criado! ID: '||v_medicine_id);
END;
/

CREATE OR REPLACE PROCEDURE oracle_challenge_update_medicine (
  p_medicine_id     IN MEDICINES.MEDICINE_ID%TYPE,
  p_name_medication IN MEDICINES.NAME_MEDICATION%TYPE,
  p_status_med      IN MEDICINES.STATUS_MED%TYPE,
  p_category_med_id IN MEDICINES.CATEGORY_MED_ID%TYPE,
  p_unit_mea_id     IN MEDICINES.UNIT_MEA_ID%TYPE
) IS
BEGIN
  UPDATE MEDICINES
     SET NAME_MEDICATION = p_name_medication,
         STATUS_MED      = p_status_med,
         CATEGORY_MED_ID = p_category_med_id,
         UNIT_MEA_ID     = p_unit_mea_id
   WHERE MEDICINE_ID     = p_medicine_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20401, 'Medicamento não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20402, 'Erro ao atualizar medicamento: '||SQLERRM);
END oracle_challenge_update_medicine;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE UPDATE 
-----------------------------------------------------
DECLARE
  v_id   MEDICINES.MEDICINE_ID%TYPE := 42;
  v_cat  MEDICINES.CATEGORY_MED_ID%TYPE := 1;
  v_unit MEDICINES.UNIT_MEA_ID%TYPE     := 1;
BEGIN
  oracle_challenge_update_medicine(
    p_medicine_id     => v_id,
    p_name_medication => 'Medicamento ATUALIZADO',
    p_status_med      => 'ATIVO',
    p_category_med_id => v_cat,
    p_unit_mea_id     => v_unit
  );

  DBMS_OUTPUT.PUT_LINE('Medicamento atualizado! ID: '||v_id);
END;
/

SELECT * FROM MEDICINES;


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_medicine (
  p_medicine_id IN MEDICINES.MEDICINE_ID%TYPE
) IS
BEGIN
  DELETE FROM MEDICINES
   WHERE MEDICINE_ID = p_medicine_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20401, 'Medicamento não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20403, 'Não é possível excluir medicamento (pode estar em estoque).');
END oracle_challenge_delete_medicine;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE DELETE 
-----------------------------------------------------
DECLARE
  v_id MEDICINES.MEDICINE_ID%TYPE := 42;
BEGIN
  oracle_challenge_delete_medicine(p_medicine_id => v_id);
  DBMS_OUTPUT.PUT_LINE('Medicamento excluído! ID: ' || v_id);
END;
/


/* MEDICINE_ACTIVE_INGR */
CREATE OR REPLACE PROCEDURE oracle_challenge_create_med_active_ingr (
  p_medicine_id        IN MEDICINE_ACTIVE_INGR.MEDICINE_ID%TYPE,
  p_act_ingre_id       IN MEDICINE_ACTIVE_INGR.ACT_INGRE_ID%TYPE,
  p_med_active_ingr_id OUT MEDICINE_ACTIVE_INGR.MED_ACTIVE_INGR_ID%TYPE
) IS
BEGIN
  INSERT INTO MEDICINE_ACTIVE_INGR (
    MEDICINE_ID, ACT_INGRE_ID
  ) VALUES (
    p_medicine_id, p_act_ingre_id
  )
  RETURNING MED_ACTIVE_INGR_ID INTO p_med_active_ingr_id;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20500, 'Erro ao vincular princípio ativo ao medicamento: '||SQLERRM);
END oracle_challenge_create_med_active_ingr;
/
SHOW ERRORS;

-----------------------------------------------------
-- TESTE CREATE 
-----------------------------------------------------
DECLARE
  v_link_id MEDICINE_ACTIVE_INGR.MED_ACTIVE_INGR_ID%TYPE;
  v_med_id  MEDICINE_ACTIVE_INGR.MEDICINE_ID%TYPE := 1;
  v_act_id  MEDICINE_ACTIVE_INGR.ACT_INGRE_ID%TYPE := 1;
BEGIN
  oracle_challenge_create_med_active_ingr(
    p_medicine_id        => v_med_id,
    p_act_ingre_id       => v_act_id,
    p_med_active_ingr_id => v_link_id
  );
  DBMS_OUTPUT.PUT_LINE('Vínculo criado! ID: '||v_link_id||' (MED='||v_med_id||', ACT='||v_act_id||')');
END;
/



CREATE OR REPLACE PROCEDURE oracle_challenge_update_med_active_ingr (
  p_med_active_ingr_id IN MEDICINE_ACTIVE_INGR.MED_ACTIVE_INGR_ID%TYPE,
  p_medicine_id        IN MEDICINE_ACTIVE_INGR.MEDICINE_ID%TYPE,
  p_act_ingre_id       IN MEDICINE_ACTIVE_INGR.ACT_INGRE_ID%TYPE
) IS
BEGIN
  UPDATE MEDICINE_ACTIVE_INGR
     SET MEDICINE_ID  = p_medicine_id,
         ACT_INGRE_ID = p_act_ingre_id
   WHERE MED_ACTIVE_INGR_ID = p_med_active_ingr_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20501, 'Vínculo medicamento x princípio ativo não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20502, 'Erro ao atualizar vínculo medicamento x princípio ativo: '||SQLERRM);
END oracle_challenge_update_med_active_ingr;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE UPDATE 
-----------------------------------------------------
DECLARE
  v_link_id MEDICINE_ACTIVE_INGR.MED_ACTIVE_INGR_ID%TYPE := 41; 
  v_med_id  MEDICINE_ACTIVE_INGR.MEDICINE_ID%TYPE        := 1;
  v_act_id  MEDICINE_ACTIVE_INGR.ACT_INGRE_ID%TYPE       := 2; 
BEGIN
  oracle_challenge_update_med_active_ingr(
    p_med_active_ingr_id => v_link_id,
    p_medicine_id        => v_med_id,
    p_act_ingre_id       => v_act_id
  );
  DBMS_OUTPUT.PUT_LINE('Vínculo atualizado! ID: '||v_link_id||
                       ' (MED='||v_med_id||', ACT='||v_act_id||')');
END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_med_active_ingr (
  p_med_active_ingr_id IN MEDICINE_ACTIVE_INGR.MED_ACTIVE_INGR_ID%TYPE
) IS
BEGIN
  DELETE FROM MEDICINE_ACTIVE_INGR
   WHERE MED_ACTIVE_INGR_ID = p_med_active_ingr_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20501, 'Vínculo medicamento x princípio ativo não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20503, 'Erro ao excluir vínculo medicamento x princípio ativo: '||SQLERRM);
END oracle_challenge_delete_med_active_ingr;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE DELETE 
-----------------------------------------------------
DECLARE
  v_link_id MEDICINE_ACTIVE_INGR.MED_ACTIVE_INGR_ID%TYPE := 1; 
BEGIN
  oracle_challenge_delete_med_active_ingr(p_med_active_ingr_id => v_link_id);
  DBMS_OUTPUT.PUT_LINE('Vínculo excluído! ID: '||v_link_id);
END;
/


/* MEDICINE_PHARM_FORM (N:N) */
CREATE OR REPLACE PROCEDURE oracle_challenge_create_med_pharm_form (
  p_medicine_id        IN MEDICINE_PHARM_FORM.MEDICINE_ID%TYPE,
  p_pharm_form_id      IN MEDICINE_PHARM_FORM.PHARM_FORM_ID%TYPE,
  p_med_pharm_form_id  OUT MEDICINE_PHARM_FORM.MED_PHARM_FORM_ID%TYPE
) IS
BEGIN
  INSERT INTO MEDICINE_PHARM_FORM (
    MEDICINE_ID, PHARM_FORM_ID
  ) VALUES (
    p_medicine_id, p_pharm_form_id
  )
  RETURNING MED_PHARM_FORM_ID INTO p_med_pharm_form_id;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20600, 'Erro ao vincular forma farmacêutica ao medicamento: '||SQLERRM);
END oracle_challenge_create_med_pharm_form;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE CREATE
-----------------------------------------------------
DECLARE
  v_link_id MEDICINE_PHARM_FORM.MED_PHARM_FORM_ID%TYPE;
  v_med_id  MEDICINE_PHARM_FORM.MEDICINE_ID%TYPE   := 1;
  v_form_id MEDICINE_PHARM_FORM.PHARM_FORM_ID%TYPE := 1;
BEGIN
  oracle_challenge_create_med_pharm_form(
    p_medicine_id        => v_med_id,
    p_pharm_form_id      => v_form_id,
    p_med_pharm_form_id  => v_link_id
  );
  DBMS_OUTPUT.PUT_LINE('Vínculo criado! ID='||v_link_id||' (MED='||v_med_id||', FORM='||v_form_id||')');
END;
/



CREATE OR REPLACE PROCEDURE oracle_challenge_update_med_pharm_form (
  p_med_pharm_form_id IN MEDICINE_PHARM_FORM.MED_PHARM_FORM_ID%TYPE,
  p_medicine_id       IN MEDICINE_PHARM_FORM.MEDICINE_ID%TYPE,
  p_pharm_form_id     IN MEDICINE_PHARM_FORM.PHARM_FORM_ID%TYPE
) IS
BEGIN
  UPDATE MEDICINE_PHARM_FORM
     SET MEDICINE_ID   = p_medicine_id,
         PHARM_FORM_ID = p_pharm_form_id
   WHERE MED_PHARM_FORM_ID = p_med_pharm_form_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20601, 'Vínculo medicamento x forma farmacêutica não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20602, 'Erro ao atualizar vínculo medicamento x forma farmacêutica: '||SQLERRM);
END oracle_challenge_update_med_pharm_form;
/
SHOW ERRORS;

-----------------------------------------------------
-- TESTE UPDATE 
-----------------------------------------------------
DECLARE
  v_link_id MEDICINE_PHARM_FORM.MED_PHARM_FORM_ID%TYPE := 41; 
  v_med_id  MEDICINE_PHARM_FORM.MEDICINE_ID%TYPE        := 1; 
  v_form_id MEDICINE_PHARM_FORM.PHARM_FORM_ID%TYPE      := 2; 
BEGIN
  oracle_challenge_update_med_pharm_form(
    p_med_pharm_form_id => v_link_id,
    p_medicine_id       => v_med_id,
    p_pharm_form_id     => v_form_id
  );
  DBMS_OUTPUT.PUT_LINE('Vínculo atualizado! ID='||v_link_id||' (MED='||v_med_id||', FORM='||v_form_id||')');
END;
/




CREATE OR REPLACE PROCEDURE oracle_challenge_delete_med_pharm_form (
  p_med_pharm_form_id IN MEDICINE_PHARM_FORM.MED_PHARM_FORM_ID%TYPE
) IS
BEGIN
  DELETE FROM MEDICINE_PHARM_FORM
   WHERE MED_PHARM_FORM_ID = p_med_pharm_form_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20601, 'Vínculo medicamento x forma farmacêutica não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20603, 'Erro ao excluir vínculo medicamento x forma farmacêutica: '||SQLERRM);
END oracle_challenge_delete_med_pharm_form;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE DELETE 
-----------------------------------------------------
DECLARE
  v_id MEDICINE_PHARM_FORM.MED_PHARM_FORM_ID%TYPE := 41;
BEGIN
  oracle_challenge_delete_med_pharm_form(p_med_pharm_form_id => v_id);
  DBMS_OUTPUT.PUT_LINE('Vínculo excluído! ID='||v_id);
END;
/

/* MOVEMENT_TYPE */
CREATE OR REPLACE PROCEDURE oracle_challenge_create_movement_type (
  p_type_name        IN MOVEMENT_TYPE.TYPE_NAME%TYPE,
  p_movement_type_id OUT MOVEMENT_TYPE.MOVEMENT_TYPE_ID%TYPE
) IS
BEGIN
  INSERT INTO MOVEMENT_TYPE (TYPE_NAME)
  VALUES (p_type_name)
  RETURNING MOVEMENT_TYPE_ID INTO p_movement_type_id;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20700, 'Erro ao criar tipo de movimento: '||SQLERRM);
END oracle_challenge_create_movement_type;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE CREATE 
-----------------------------------------------------
DECLARE
  v_id MOVEMENT_TYPE.MOVEMENT_TYPE_ID%TYPE;
BEGIN
  oracle_challenge_create_movement_type(
    p_type_name        => 'MOVIMENTO_06-11-25',
    p_movement_type_id => v_id
  );
  DBMS_OUTPUT.PUT_LINE('Tipo de movimento criado! ID: ' || v_id);
END;
/



CREATE OR REPLACE PROCEDURE oracle_challenge_update_movement_type (
  p_movement_type_id IN MOVEMENT_TYPE.MOVEMENT_TYPE_ID%TYPE,
  p_type_name        IN MOVEMENT_TYPE.TYPE_NAME%TYPE
) IS
BEGIN
  UPDATE MOVEMENT_TYPE
     SET TYPE_NAME = p_type_name
   WHERE MOVEMENT_TYPE_ID = p_movement_type_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20701, 'Tipo de movimento não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20702, 'Erro ao atualizar tipo de movimento: '||SQLERRM);
END oracle_challenge_update_movement_type;
/
SHOW ERRORS;

-----------------------------------------------------
-- TESTE UPDATE 
-----------------------------------------------------
DECLARE
  v_id MOVEMENT_TYPE.MOVEMENT_TYPE_ID%TYPE := 21; 
BEGIN
  oracle_challenge_update_movement_type(
    p_movement_type_id => v_id,
    p_type_name        => 'MOV ATUALIZADO'
  );
  DBMS_OUTPUT.PUT_LINE('Tipo de movimento atualizado! ID: ' || v_id);
END;
/

CREATE OR REPLACE PROCEDURE oracle_challenge_delete_movement_type (
  p_movement_type_id IN MOVEMENT_TYPE.MOVEMENT_TYPE_ID%TYPE
) IS
BEGIN
  DELETE FROM MOVEMENT_TYPE
   WHERE MOVEMENT_TYPE_ID = p_movement_type_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20701, 'Tipo de movimento não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20703, 'Não é possível excluir tipo de movimento (já usado em movimentações).');
END oracle_challenge_delete_movement_type;
/
SHOW ERRORS;

-----------------------------------------------------
-- TESTE DELETE 
-----------------------------------------------------
DECLARE
  v_id MOVEMENT_TYPE.MOVEMENT_TYPE_ID%TYPE := 21;
BEGIN
  oracle_challenge_delete_movement_type(p_movement_type_id => v_id);
  DBMS_OUTPUT.PUT_LINE('Tipo de movimento excluído! ID: ' || v_id);
END;
/

--------------------------------------------------------------------------------
-- 7) LOTES
-- BATCH_MEDICINE  (usa valida_qtd_positiva)
--------------------------------------------------------------------------------

/* BATCH_MEDICINE*/
CREATE OR REPLACE PROCEDURE oracle_challenge_create_batch_medicine (
  p_batch_number       IN BATCH_MEDICINE.BATCH_NUMBER%TYPE,
  p_current_quantity   IN BATCH_MEDICINE.CURRENT_QUANTITY%TYPE,
  p_manufacturing_date IN BATCH_MEDICINE.MANUFACTURING_DATE%TYPE,
  p_expiration_date    IN BATCH_MEDICINE.EXPIRATION_DATE%TYPE,
  p_manufac_id         IN BATCH_MEDICINE.MANUFAC_ID%TYPE,
  p_batch_id           OUT BATCH_MEDICINE.BATCH_ID%TYPE
) IS
  v_validacao VARCHAR2(30);
BEGIN

  v_validacao := valida_qtd_positiva(p_current_quantity);
  IF v_validacao != 'Quantidade válida' THEN
    RAISE_APPLICATION_ERROR(-20620, 'Quantidade inicial inválida (precisa ser > 0).');
  END IF;


  IF p_manufacturing_date > p_expiration_date THEN
    RAISE_APPLICATION_ERROR(-20621, 'Data de fabricação não pode ser posterior à data de validade.');
  END IF;

  INSERT INTO BATCH_MEDICINE (
    BATCH_NUMBER, CURRENT_QUANTITY, MANUFACTURING_DATE, EXPIRATION_DATE, MANUFAC_ID
  ) VALUES (
    p_batch_number, p_current_quantity, p_manufacturing_date, p_expiration_date, p_manufac_id
  )
  RETURNING BATCH_ID INTO p_batch_id;

EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20622, 'Lote já cadastrado para este fabricante.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20623, 'Erro ao criar lote. Verifique fabricante/datas: '||SQLERRM);
END oracle_challenge_create_batch_medicine;
/
SHOW ERRORS;

-----------------------------------------------------
-- TESTE CREATE 
-----------------------------------------------------

DECLARE
  v_batch_id  BATCH_MEDICINE.BATCH_ID%TYPE;
  v_manufac   BATCH_MEDICINE.MANUFAC_ID%TYPE := 1;
BEGIN
  oracle_challenge_create_batch_medicine(
    p_batch_number       => 'L' || TO_CHAR(SYSDATE,'DDMMHH24MISS'),
    p_current_quantity   => 100,
    p_manufacturing_date => TRUNC(SYSDATE) - 10,
    p_expiration_date    => ADD_MONTHS(TRUNC(SYSDATE), 12),
    p_manufac_id         => v_manufac,
    p_batch_id           => v_batch_id
  );

  DBMS_OUTPUT.PUT_LINE('Lote criado com sucesso! ID: ' || v_batch_id);
END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_update_batch_medicine (
  p_batch_id           IN BATCH_MEDICINE.BATCH_ID%TYPE,
  p_batch_number       IN BATCH_MEDICINE.BATCH_NUMBER%TYPE,
  p_current_quantity   IN BATCH_MEDICINE.CURRENT_QUANTITY%TYPE,
  p_manufacturing_date IN BATCH_MEDICINE.MANUFACTURING_DATE%TYPE,
  p_expiration_date    IN BATCH_MEDICINE.EXPIRATION_DATE%TYPE,
  p_manufac_id         IN BATCH_MEDICINE.MANUFAC_ID%TYPE
) IS
  v_validacao VARCHAR2(30);
BEGIN
  
  v_validacao := valida_qtd_positiva(p_current_quantity);
  IF v_validacao != 'Quantidade válida' THEN
    RAISE_APPLICATION_ERROR(-20620, 'Quantidade inválida (precisa ser > 0).');
  END IF;

 
  IF p_manufacturing_date > p_expiration_date THEN
    RAISE_APPLICATION_ERROR(-20621, 'Fabricação não pode ser posterior à validade.');
  END IF;

  UPDATE BATCH_MEDICINE
     SET BATCH_NUMBER       = p_batch_number,
         CURRENT_QUANTITY   = p_current_quantity,
         MANUFACTURING_DATE = p_manufacturing_date,
         EXPIRATION_DATE    = p_expiration_date,
         MANUFAC_ID         = p_manufac_id
   WHERE BATCH_ID           = p_batch_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20626, 'Lote não encontrado.');
  END IF;

EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20622, 'Lote já cadastrado para este fabricante.');
  WHEN OTHERS THEN

    RAISE_APPLICATION_ERROR(-20625, 'Erro ao atualizar lote: '||SQLERRM);
END oracle_challenge_update_batch_medicine;
/
SHOW ERRORS;

-----------------------------------------------------
-- TESTE UPDATE 
-----------------------------------------------------
DECLARE
  v_id      BATCH_MEDICINE.BATCH_ID%TYPE := 22; 
  v_manufac BATCH_MEDICINE.MANUFAC_ID%TYPE := 1;
BEGIN
  oracle_challenge_update_batch_medicine(
    p_batch_id           => v_id,
    p_batch_number       => 'Lote ATUA',
    p_current_quantity   => 250,
    p_manufacturing_date => TRUNC(SYSDATE) - 20,
    p_expiration_date    => ADD_MONTHS(TRUNC(SYSDATE), 18),
    p_manufac_id         => v_manufac
  );
  DBMS_OUTPUT.PUT_LINE('Lote atualizado! ID: '||v_id);
END;
/


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_batch_medicine (
  p_batch_id IN BATCH_MEDICINE.BATCH_ID%TYPE
) IS
BEGIN
  DELETE FROM BATCH_MEDICINE
   WHERE BATCH_ID = p_batch_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20626, 'Lote não encontrado.');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  
    RAISE_APPLICATION_ERROR(-20627, 'Não é possível excluir lote. Ele pode estar em uso: '||SQLERRM);
END oracle_challenge_delete_batch_medicine;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE DELETE
-----------------------------------------------------

DECLARE
  v_id BATCH_MEDICINE.BATCH_ID%TYPE := 22;
BEGIN
  oracle_challenge_delete_batch_medicine(p_batch_id => v_id);
  DBMS_OUTPUT.PUT_LINE('Lote excluído! ID: '||v_id);
END;
/



--------------------------------------------------------------------------------
-- 8) ESTOQUE / MOVIMENTAÇÃO
-- STOCK / MEDICINE_DISPENSE / STOCK_MOVEMENT
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION is_saida (p_movement_type_id IN NUMBER)
  RETURN CHAR
IS
BEGIN
  IF p_movement_type_id IN (5,6,9,10) THEN
    RETURN 'S';
  ELSE
    RETURN 'N';
  END IF;
END is_saida;
/
SHOW ERRORS;

CREATE OR REPLACE PROCEDURE oracle_challenge_apply_movement (
  p_stock_id           IN STOCK.STOCK_ID%TYPE,
  p_movement_type_id   IN STOCK_MOVEMENT.MOVEMENT_TYPE_ID%TYPE,
  p_qty                IN STOCK_MOVEMENT.QUANTITY_DISPENSED%TYPE,
  p_user_id            IN STOCK_MOVEMENT.USER_ID%TYPE,
  p_destination        IN MEDICINE_DISPENSE.DESTINATION%TYPE    DEFAULT NULL,
  p_observation        IN MEDICINE_DISPENSE.OBSERVATION%TYPE    DEFAULT NULL,
  p_dispensation_id    OUT MEDICINE_DISPENSE.DISPENSATION_ID%TYPE,
  p_stock_movement_id  OUT STOCK_MOVEMENT.STOCK_MOVEMENT_ID%TYPE
) IS
  v_current_qty   STOCK.QUANTITY%TYPE;
  v_new_qty       STOCK.QUANTITY%TYPE;
  v_saida         CHAR(1);
BEGIN

  IF valida_qtd_positiva(p_qty) != 'Quantidade válida' THEN
    RAISE_APPLICATION_ERROR(-20000, 'Quantidade inválida (precisa ser > 0).');
  END IF;

  SELECT QUANTITY
    INTO v_current_qty
    FROM STOCK
   WHERE STOCK_ID = p_stock_id
     FOR UPDATE;

  v_saida := is_saida(p_movement_type_id);

  IF v_saida = 'S' THEN
    v_new_qty := v_current_qty - p_qty;
    IF v_new_qty < 0 THEN
      RAISE_APPLICATION_ERROR(-20001,
        'Saldo insuficiente. Atual='||v_current_qty||', Solicitado='||p_qty);
    END IF;
  ELSE
    v_new_qty := v_current_qty + p_qty;
  END IF;


  UPDATE STOCK
     SET QUANTITY = v_new_qty
   WHERE STOCK_ID = p_stock_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Estoque não encontrado.');
  END IF;

  p_dispensation_id := NULL;
  IF v_saida = 'S' THEN
    INSERT INTO MEDICINE_DISPENSE (
      DATE_DISPENSATION, QUANTITY_DISPENSED, DESTINATION, OBSERVATION, USER_ID
    ) VALUES (
      SYSDATE, p_qty, p_destination, p_observation, p_user_id
    )
    RETURNING DISPENSATION_ID INTO p_dispensation_id;
  END IF;

  
  INSERT INTO STOCK_MOVEMENT (
    QUANTITY_DISPENSED, DATE_MOVIMENT, MOVEMENT_TYPE_ID, STOCK_ID, DISPENSATION_ID, USER_ID
  ) VALUES (
    p_qty, SYSDATE, p_movement_type_id, p_stock_id, p_dispensation_id, p_user_id
  )
  RETURNING STOCK_MOVEMENT_ID INTO p_stock_movement_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20002, 'Estoque não encontrado.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20003, 'Erro ao aplicar movimento de estoque: '||SQLERRM);
END oracle_challenge_apply_movement;
/
SHOW ERRORS;


 /* STOCK */
CREATE OR REPLACE PROCEDURE oracle_challenge_set_stock_quantity (
  p_stock_id IN STOCK.STOCK_ID%TYPE,
  p_new_qty  IN STOCK.QUANTITY%TYPE
) IS
BEGIN
  IF p_new_qty < 0 THEN
    RAISE_APPLICATION_ERROR(-20100, 'Quantidade não pode ser negativa.');
  END IF;

  UPDATE STOCK
     SET QUANTITY = p_new_qty
   WHERE STOCK_ID = p_stock_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20101, 'Estoque não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20102, 'Erro ao ajustar quantidade de estoque: '||SQLERRM);
END oracle_challenge_set_stock_quantity;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE CREATE
-----------------------------------------------------
DECLARE
  v_stock_id STOCK.STOCK_ID%TYPE := 1;  
BEGIN
  oracle_challenge_set_stock_quantity(
    p_stock_id => v_stock_id,
    p_new_qty  => 500
  );
  DBMS_OUTPUT.PUT_LINE('Quantidade ajustada! STOCK_ID='||v_stock_id||' -> 500');
END;
/


/* STOCK */
CREATE OR REPLACE PROCEDURE oracle_challenge_create_stock (
  p_batch_id          IN STOCK.BATCH_ID%TYPE,
  p_medicine_id       IN STOCK.MEDICINE_ID%TYPE,
  p_location_id_stock IN STOCK.LOCATION_ID_STOCK%TYPE,
  p_quantity          IN STOCK.QUANTITY%TYPE,
  p_stock_id          OUT STOCK.STOCK_ID%TYPE
) IS
BEGIN
  IF valida_qtd_positiva(p_quantity) <> 'Quantidade válida' THEN
    RAISE_APPLICATION_ERROR(-20640, 'Quantidade inicial inválida (precisa ser > 0).');
  END IF;

  INSERT INTO STOCK (
    QUANTITY, BATCH_ID, MEDICINE_ID, LOCATION_ID_STOCK
  ) VALUES (
    p_quantity, p_batch_id, p_medicine_id, p_location_id_stock
  )
  RETURNING STOCK_ID INTO p_stock_id;

EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20641, 'Já existe estoque deste lote/medicamento nesse local.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20642, 'Erro ao criar estoque: '||SQLERRM);
END oracle_challenge_create_stock;
/
SHOW ERRORS;

-----------------------------------------------------
-- TESTE CREATE
-----------------------------------------------------

DECLARE
  v_stock_id STOCK.STOCK_ID%TYPE;
BEGIN
  oracle_challenge_create_stock(
    p_batch_id          => 1, 
    p_medicine_id       => 1,
    p_location_id_stock => 1,
    p_quantity          => 50,
    p_stock_id          => v_stock_id
  );
  DBMS_OUTPUT.PUT_LINE('Estoque criado! ID: ' || v_stock_id);
END;
/
SELECT * FROM STOCK;


CREATE OR REPLACE PROCEDURE oracle_challenge_update_stock (
  p_stock_id          IN STOCK.STOCK_ID%TYPE,
  p_batch_id          IN STOCK.BATCH_ID%TYPE,
  p_medicine_id       IN STOCK.MEDICINE_ID%TYPE,
  p_location_id_stock IN STOCK.LOCATION_ID_STOCK%TYPE,
  p_quantity          IN STOCK.QUANTITY%TYPE
) IS
BEGIN
  IF valida_qtd_positiva(p_quantity) <> 'Quantidade válida' THEN
    RAISE_APPLICATION_ERROR(-20640, 'Quantidade inválida (precisa ser > 0).');
  END IF;

  UPDATE STOCK
     SET QUANTITY          = p_quantity,
         BATCH_ID          = p_batch_id,
         MEDICINE_ID       = p_medicine_id,
         LOCATION_ID_STOCK = p_location_id_stock
   WHERE STOCK_ID          = p_stock_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20631, 'Estoque não encontrado.');
  END IF;

EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN

    RAISE_APPLICATION_ERROR(-20641, 'Já existe estoque deste lote/medicamento nesse local.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20644, 'Erro ao atualizar estoque: '||SQLERRM);
END oracle_challenge_update_stock;
/
SHOW ERRORS;

-----------------------------------------------------
-- TESTE UPDATE
-----------------------------------------------------
DECLARE
  v_id STOCK.STOCK_ID%TYPE := 21; 
BEGIN
  oracle_challenge_update_stock(
    p_stock_id          => v_id,
    p_batch_id          => 1,  
    p_medicine_id       => 1,
    p_location_id_stock => 1,
    p_quantity          => 75
  );
  DBMS_OUTPUT.PUT_LINE('Estoque atualizado! ID: '||v_id);
END;
/



CREATE OR REPLACE PROCEDURE oracle_challenge_delete_stock (
  p_stock_id IN STOCK.STOCK_ID%TYPE
) IS
BEGIN
  DELETE FROM STOCK
   WHERE STOCK_ID = p_stock_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20631, 'Estoque não encontrado.');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    
    RAISE_APPLICATION_ERROR(-20646, 'Não é possível excluir estoque. Ele pode estar em uso: '||SQLERRM);
END oracle_challenge_delete_stock;
/
SHOW ERRORS;


-----------------------------------------------------
-- TESTE DELETE 
-----------------------------------------------------
DECLARE
  v_stock_id STOCK.STOCK_ID%TYPE;
BEGIN
  oracle_challenge_create_stock(
    p_batch_id          =>  1,
    p_medicine_id       =>  1,
    p_location_id_stock =>  1,
    p_quantity          => 75,
    p_stock_id          => v_stock_id
  );
  DBMS_OUTPUT.PUT_LINE('STOCK criado: '||v_stock_id);

  oracle_challenge_delete_stock(p_stock_id => v_stock_id);
  DBMS_OUTPUT.PUT_LINE('STOCK deletado: '||v_stock_id);
END;
/


/* MEDICINE_DISPENSE - UPDATE BLOQUEADO (stub) */
CREATE OR REPLACE PROCEDURE oracle_challenge_update_medicine_dispense_stub (
  p_dispensation_id IN MEDICINE_DISPENSE.DISPENSATION_ID%TYPE
) IS
BEGIN
  RAISE_APPLICATION_ERROR(
    -20650,
    'Alterar MEDICINE_DISPENSE não é permitido (histórico de dispensação).'
  );
END oracle_challenge_update_medicine_dispense_stub;
/
SHOW ERRORS;
-----------------------------------------------------
-- TESTE UPDATE 
-----------------------------------------------------

BEGIN
  oracle_challenge_update_medicine_dispense_stub(p_dispensation_id => 1);
  DBMS_OUTPUT.PUT_LINE('ERRO: não era para executar UPDATE em MEDICINE_DISPENSE!');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('OK (bloqueado): '||SQLCODE||' - '||SQLERRM);
END;
/



CREATE OR REPLACE PROCEDURE oracle_challenge_delete_medicine_dispense_stub (
  p_dispensation_id IN MEDICINE_DISPENSE.DISPENSATION_ID%TYPE
) IS
BEGIN
  RAISE_APPLICATION_ERROR(-20401,
    'Excluir MEDICINE_DISPENSE não é permitido (histórico de dispensação).');
END oracle_challenge_delete_medicine_dispense_stub;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_update_stock_movement_stub (
  p_stock_movement_id IN STOCK_MOVEMENT.STOCK_MOVEMENT_ID%TYPE
) IS
BEGIN
  RAISE_APPLICATION_ERROR(-20402,
    'Alterar STOCK_MOVEMENT não é permitido (auditoria de estoque).');
END oracle_challenge_update_stock_movement_stub;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_stock_movement_stub (
  p_stock_movement_id IN STOCK_MOVEMENT.STOCK_MOVEMENT_ID%TYPE
) IS
BEGIN
  RAISE_APPLICATION_ERROR(-20403,
    'Excluir STOCK_MOVEMENT não é permitido (auditoria de estoque).');
END oracle_challenge_delete_stock_movement_stub;
/
SHOW ERRORS;


-----------------------
-- Item 5
-----------------------
----------------------------------------------
-- 1. Relatório de estoque formatado
----------------------------------------------

CREATE OR REPLACE TYPE t_rel_estoque_fmt_row AS OBJECT (
  stock_id               NUMBER,
  medicine_id            NUMBER,
  medicine_name          VARCHAR2(255),
  category_name          VARCHAR2(255),
  unit_measure           VARCHAR2(20),
  batch_id               NUMBER,
  batch_number           VARCHAR2(255),
  manufacturer_id        NUMBER,
  manufacturer_name      VARCHAR2(255),
  expiration_date        DATE,
  dias_para_vencer       NUMBER,
  validade_status        VARCHAR2(15), 
  location_id_stock      NUMBER,
  location_name          VARCHAR2(100),
  quantity_in_stock      NUMBER
);
/
SHOW ERRORS;


---------------------------------------------------------------------------
-- 2. Coleção de linhas do relatório
---------------------------------------------------------------------------

CREATE OR REPLACE TYPE t_rel_estoque_fmt_tab AS TABLE OF t_rel_estoque_fmt_row;
/
SHOW ERRORS;


---------------------------------------------------------------------------
-- 3. Função de relatório de estoque
---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION rel_estoque_formatado_fn (
  p_medicine_id         IN NUMBER DEFAULT NULL,
  p_location_id_stock   IN NUMBER DEFAULT NULL,
  p_somente_validos     IN CHAR   DEFAULT 'N',
  p_ate_dias_validade   IN NUMBER DEFAULT NULL
) RETURN t_rel_estoque_fmt_tab PIPELINED
IS
  CURSOR c_rel IS
    SELECT
      s.STOCK_ID,
      m.MEDICINE_ID,
      m.NAME_MEDICATION                            AS MEDICINE_NAME,
      c.CATEGORY                                   AS CATEGORY_NAME,
      u.UNIT_MEASURE_MEDICINE                      AS UNIT_MEASURE,
      b.BATCH_ID,
      b.BATCH_NUMBER,
      f.MANUFAC_ID                                 AS MANUFACTURER_ID,
      f.NAME_MANU                                  AS MANUFACTURER_NAME,
      b.EXPIRATION_DATE,
      s.LOCATION_ID_STOCK,
      l.LOCATION_STOCK_NAME                         AS LOCATION_NAME,
      s.QUANTITY                                    AS QUANTITY_IN_STOCK
    FROM STOCK s
    JOIN MEDICINES            m ON m.MEDICINE_ID            = s.MEDICINE_ID
    JOIN CATEGORY_MEDICINE    c ON c.CATEGORY_MED_ID        = m.CATEGORY_MED_ID
    JOIN UNIT_MEASURE         u ON u.UNIT_MEA_ID            = m.UNIT_MEA_ID
    JOIN BATCH_MEDICINE       b ON b.BATCH_ID               = s.BATCH_ID
    JOIN MANUFACTURER         f ON f.MANUFAC_ID             = b.MANUFAC_ID
    JOIN LOCATION_STOCK       l ON l.LOCATION_ID_STOCK      = s.LOCATION_ID_STOCK
    WHERE (p_medicine_id       IS NULL OR m.MEDICINE_ID       = p_medicine_id)
      AND (p_location_id_stock IS NULL OR s.LOCATION_ID_STOCK = p_location_id_stock)
      AND ( NVL(UPPER(p_somente_validos),'N') != 'S'
            OR b.EXPIRATION_DATE >= TRUNC(SYSDATE) )
    ORDER BY
      m.NAME_MEDICATION,
      b.EXPIRATION_DATE,
      s.STOCK_ID;

  v_rec           c_rel%ROWTYPE;
  v_dias          NUMBER;
  v_status        VARCHAR2(15);
BEGIN
  OPEN c_rel;
  LOOP
    FETCH c_rel INTO v_rec;
    EXIT WHEN c_rel%NOTFOUND;


    v_dias   := TRUNC(v_rec.EXPIRATION_DATE) - TRUNC(SYSDATE);
    v_status := CASE WHEN v_rec.EXPIRATION_DATE >= TRUNC(SYSDATE)
                     THEN 'VÁLIDO' ELSE 'VENCIDO' END;

  
    IF p_ate_dias_validade IS NOT NULL THEN
      IF v_status != 'VÁLIDO' OR v_dias > p_ate_dias_validade THEN
        CONTINUE;
      END IF;
    END IF;

    PIPE ROW (
      t_rel_estoque_fmt_row(
        v_rec.STOCK_ID,
        v_rec.MEDICINE_ID,
        v_rec.MEDICINE_NAME,
        v_rec.CATEGORY_NAME,
        v_rec.UNIT_MEASURE,
        v_rec.BATCH_ID,
        v_rec.BATCH_NUMBER,
        v_rec.MANUFACTURER_ID,
        v_rec.MANUFACTURER_NAME,
        v_rec.EXPIRATION_DATE,
        v_dias,
        v_status,
        v_rec.LOCATION_ID_STOCK,
        v_rec.LOCATION_NAME,
        v_rec.QUANTITY_IN_STOCK
      )
    );
  END LOOP;
  CLOSE c_rel;

  RETURN;
END rel_estoque_formatado_fn;
/
SHOW ERRORS;



---------------------------------------------------------------------------
-- TESTE RELATÓRIO
---------------------------------------------------------------------------
-- 1) Relatório completo
SELECT * FROM TABLE(rel_estoque_formatado_fn);

-- 2) Apenas lotes NÃO vencidos
SELECT * FROM TABLE(rel_estoque_formatado_fn(p_somente_validos => 'S'));

-- 3) Filtra por medicamento
SELECT * FROM TABLE(rel_estoque_formatado_fn(p_medicine_id => 12));

-- 4) Filtra por local
SELECT * FROM TABLE(rel_estoque_formatado_fn(p_location_id_stock => 7));

-- 5) Lotes que vencem em até 15 dias (e não vencidos)
SELECT * FROM TABLE(rel_estoque_formatado_fn(p_somente_validos => 'S', p_ate_dias_validade => 15));



------------------------
-- Item 6
------------------------

---------------------------------------------------------------------------
-- 1. TYPE de uma linha do relatório 
---------------------------------------------------------------------------

CREATE OR REPLACE TYPE t_rel_consumo_row AS OBJECT (
  medicine_id         NUMBER,
  medicine_name       VARCHAR2(255),
  category_name       VARCHAR2(255),
  unit_measure        VARCHAR2(20),
  location_id_stock   NUMBER,
  location_name       VARCHAR2(100),
  total_dispensado    NUMBER,
  qtd_movimentos      NUMBER,
  primeira_saida      DATE,
  ultima_saida        DATE,
  estoque_atual       NUMBER
);
/
SHOW ERRORS;

---------------------------------------------------------------------------
-- 2. TYPE tabela (coleção de linhas)
---------------------------------------------------------------------------
CREATE OR REPLACE TYPE t_rel_consumo_tab AS TABLE OF t_rel_consumo_row;
/
SHOW ERRORS;


---------------------------------------------------------------------------
-- 3. Função de relatório 
---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION rel_consumo_saidas_fn (
  p_dt_ini        IN DATE   DEFAULT TRUNC(SYSDATE) - 30,
  p_dt_fim        IN DATE   DEFAULT TRUNC(SYSDATE),
  p_medicine_id   IN NUMBER DEFAULT NULL,
  p_location_id   IN NUMBER DEFAULT NULL
) RETURN t_rel_consumo_tab PIPELINED
IS
  CURSOR c_rel IS
    SELECT
      s.MEDICINE_ID,
      m.NAME_MEDICATION                       AS MEDICINE_NAME,
      c.CATEGORY                              AS CATEGORY_NAME,
      u.UNIT_MEASURE_MEDICINE                 AS UNIT_MEASURE,
      s.LOCATION_ID_STOCK,
      l.LOCATION_STOCK_NAME                   AS LOCATION_NAME,
      SUM(sm.QUANTITY_DISPENSED)              AS TOTAL_DISPENSADO,
      COUNT(*)                                AS QTD_MOVIMENTOS,
      MIN(sm.DATE_MOVIMENT)                   AS PRIMEIRA_SAIDA,
      MAX(sm.DATE_MOVIMENT)                   AS ULTIMA_SAIDA,
     
      (SELECT SUM(s2.QUANTITY)
         FROM STOCK s2
        WHERE s2.MEDICINE_ID       = s.MEDICINE_ID
          AND s2.LOCATION_ID_STOCK = s.LOCATION_ID_STOCK) AS ESTOQUE_ATUAL
    FROM STOCK_MOVEMENT sm
    JOIN MOVEMENT_TYPE   mt ON mt.MOVEMENT_TYPE_ID = sm.MOVEMENT_TYPE_ID
    JOIN STOCK           s  ON s.STOCK_ID          = sm.STOCK_ID
    JOIN MEDICINES       m  ON m.MEDICINE_ID       = s.MEDICINE_ID
    JOIN CATEGORY_MEDICINE c ON c.CATEGORY_MED_ID  = m.CATEGORY_MED_ID
    JOIN UNIT_MEASURE    u  ON u.UNIT_MEA_ID       = m.UNIT_MEA_ID
    JOIN LOCATION_STOCK  l  ON l.LOCATION_ID_STOCK = s.LOCATION_ID_STOCK
    WHERE is_saida(sm.MOVEMENT_TYPE_ID) = 'S'                       
      AND sm.DATE_MOVIMENT >= TRUNC(p_dt_ini)
      AND sm.DATE_MOVIMENT <  TRUNC(p_dt_fim) + 1                    
      AND (p_medicine_id IS NULL OR s.MEDICINE_ID       = p_medicine_id)
      AND (p_location_id IS NULL OR s.LOCATION_ID_STOCK = p_location_id)
    GROUP BY
      s.MEDICINE_ID, m.NAME_MEDICATION, c.CATEGORY, u.UNIT_MEASURE_MEDICINE,
      s.LOCATION_ID_STOCK, l.LOCATION_STOCK_NAME
    ORDER BY
      TOTAL_DISPENSADO DESC, ULTIMA_SAIDA DESC;

  v_rec c_rel%ROWTYPE;
BEGIN
  OPEN c_rel;
  LOOP
    FETCH c_rel INTO v_rec;
    EXIT WHEN c_rel%NOTFOUND;

    PIPE ROW (
      t_rel_consumo_row(
        v_rec.MEDICINE_ID,
        v_rec.MEDICINE_NAME,
        v_rec.CATEGORY_NAME,
        v_rec.UNIT_MEASURE,
        v_rec.LOCATION_ID_STOCK,
        v_rec.LOCATION_NAME,
        v_rec.TOTAL_DISPENSADO,
        v_rec.QTD_MOVIMENTOS,
        v_rec.PRIMEIRA_SAIDA,
        v_rec.ULTIMA_SAIDA,
        NVL(v_rec.ESTOQUE_ATUAL, 0)
      )
    );
  END LOOP;
  CLOSE c_rel;

  RETURN;
END rel_consumo_saidas_fn;
/
SHOW ERRORS;





