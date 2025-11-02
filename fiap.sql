SET SERVEROUTPUT ON;

--------------------------------------------------------------------------------
-- 1) FUNÇÕES DE VALIDAÇÃO DE ENTRADA
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION valida_email(p_email IN VARCHAR2)
  RETURN NUMBER
IS
BEGIN
  IF p_email IS NULL THEN
    RETURN 0;
  END IF;

  IF REGEXP_LIKE(
       p_email,
       '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$'
     ) THEN
    RETURN 1;
  ELSE
    RETURN 0;
  END IF;
END valida_email;
/
SHOW ERRORS;


CREATE OR REPLACE FUNCTION valida_qtd_positiva(p_qtd IN NUMBER)
  RETURN NUMBER
IS
BEGIN
  IF p_qtd IS NULL OR p_qtd <= 0 THEN
    RETURN 0;
  ELSE
    RETURN 1;
  END IF;
END valida_qtd_positiva;
/
SHOW ERRORS;


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
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20050, 'Erro ao criar local de estoque (endereço pode não existir ou já usado): '||SQLERRM);
END oracle_challenge_create_location_stock;
/
SHOW ERRORS;


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
    RAISE_APPLICATION_ERROR(-20051, 'Local de estoque não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20050, 'Erro ao atualizar local de estoque: '||SQLERRM);
END oracle_challenge_update_location_stock;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_location_stock (
  p_location_id_stock IN LOCATION_STOCK.LOCATION_ID_STOCK%TYPE
) IS
BEGIN
  DELETE FROM LOCATION_STOCK
   WHERE LOCATION_ID_STOCK = p_location_id_stock;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20051, 'Local de estoque não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20052, 'Não é possível excluir: local tem estoque vinculado.');
END oracle_challenge_delete_location_stock;
/
SHOW ERRORS;


--------------------------------------------------------------------------------
-- 3) CONTATOS DE USUÁRIO
--------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE oracle_challenge_create_contact_user (
  p_email_user        IN  CONTACT_USER.EMAIL_USER%TYPE,
  p_phone_number_user IN  CONTACT_USER.PHONE_NUMBER_USER%TYPE,
  p_contact_user_id   OUT CONTACT_USER.CONTACT_USER_ID%TYPE
) IS
BEGIN
  IF valida_email(p_email_user) = 0 THEN
    RAISE_APPLICATION_ERROR(-21000, 'E-mail inválido.');
  END IF;

  INSERT INTO CONTACT_USER (EMAIL_USER, PHONE_NUMBER_USER)
  VALUES (p_email_user, p_phone_number_user)
  RETURNING CONTACT_USER_ID INTO p_contact_user_id;

EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-21001, 'E-mail ou telefone já cadastrado.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-21002, 'Erro ao criar contato: '||SQLERRM);
END oracle_challenge_create_contact_user;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_update_contact_user (
  p_contact_user_id   IN CONTACT_USER.CONTACT_USER_ID%TYPE,
  p_email_user        IN CONTACT_USER.EMAIL_USER%TYPE,
  p_phone_number_user IN CONTACT_USER.PHONE_NUMBER_USER%TYPE
) IS
BEGIN
  IF valida_email(p_email_user) = 0 THEN
    RAISE_APPLICATION_ERROR(-21000, 'E-mail inválido.');
  END IF;

  UPDATE CONTACT_USER
     SET EMAIL_USER        = p_email_user,
         PHONE_NUMBER_USER = p_phone_number_user
   WHERE CONTACT_USER_ID   = p_contact_user_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-21003, 'Contato não encontrado.');
  END IF;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-21001, 'E-mail ou telefone já cadastrado.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-21002, 'Erro ao atualizar contato: '||SQLERRM);
END oracle_challenge_update_contact_user;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_contact_user (
  p_contact_user_id IN CONTACT_USER.CONTACT_USER_ID%TYPE
) IS
BEGIN
  DELETE FROM CONTACT_USER
   WHERE CONTACT_USER_ID = p_contact_user_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-21003, 'Contato não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-21004, 'Não é possível excluir contato (pode estar vinculado a usuário).');
END oracle_challenge_delete_contact_user;
/
SHOW ERRORS;


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
    RAISE_APPLICATION_ERROR(-22000, 'Erro ao criar role: '||SQLERRM);
END oracle_challenge_create_role_user;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_update_role_user (
  p_role_user_id IN ROLE_USER.ROLE_USER_ID%TYPE,
  p_user_role    IN ROLE_USER.USER_ROLE%TYPE
) IS
BEGIN
  UPDATE ROLE_USER
     SET USER_ROLE = p_user_role
   WHERE ROLE_USER_ID = p_role_user_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-22001, 'Role não encontrada.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-22000, 'Erro ao atualizar role: '||SQLERRM);
END oracle_challenge_update_role_user;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_role_user (
  p_role_user_id IN ROLE_USER.ROLE_USER_ID%TYPE
) IS
BEGIN
  DELETE FROM ROLE_USER
   WHERE ROLE_USER_ID = p_role_user_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-22001, 'Role não encontrada.');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-22002, 'Não é possível excluir role. Ela pode estar em uso.');
END oracle_challenge_delete_role_user;
/
SHOW ERRORS;


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
    RAISE_APPLICATION_ERROR(-22100, 'Erro ao criar perfil: '||SQLERRM);
END oracle_challenge_create_profile_user;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_update_profile_user (
  p_prof_user_id IN PROFILE_USER.PROF_USER_ID%TYPE,
  p_user_profile IN PROFILE_USER.USER_PROFILE%TYPE
) IS
BEGIN
  UPDATE PROFILE_USER
     SET USER_PROFILE = p_user_profile
   WHERE PROF_USER_ID = p_prof_user_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-22101, 'Perfil não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-22100, 'Erro ao atualizar perfil: '||SQLERRM);
END oracle_challenge_update_profile_user;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_profile_user (
  p_prof_user_id IN PROFILE_USER.PROF_USER_ID%TYPE
) IS
BEGIN
  DELETE FROM PROFILE_USER
   WHERE PROF_USER_ID = p_prof_user_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-22101, 'Perfil não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-22102, 'Não é possível excluir perfil. Ele pode estar em uso.');
END oracle_challenge_delete_profile_user;
/
SHOW ERRORS;


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
    RAISE_APPLICATION_ERROR(-22200, 'Login já utilizado.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-22201, 'Erro ao criar usuário. Verifique role/perfil/contato: '||SQLERRM);
END oracle_challenge_create_user_sys;
/
SHOW ERRORS;


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
    RAISE_APPLICATION_ERROR(-22202, 'Usuário não encontrado.');
  END IF;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-22200, 'Login já utilizado por outro usuário.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-22203, 'Erro ao atualizar usuário: '||SQLERRM);
END oracle_challenge_update_user_sys;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_user_sys (
  p_user_id IN USERS_SYS.USER_ID%TYPE
) IS
BEGIN
  DELETE FROM USERS_SYS
   WHERE USER_ID = p_user_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-22202, 'Usuário não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(
      -22204,
      'Não é possível excluir usuário. Ele pode estar vinculado a movimentações.'
    );
END oracle_challenge_delete_user_sys;
/
SHOW ERRORS;


--------------------------------------------------------------------------------
-- 5) FABRICANTES
-- CONTACT_MANUFACTURER / MANUFACTURER
--------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE oracle_challenge_create_contact_manufacturer (
  p_email_manu        IN CONTACT_MANUFACTURER.EMAIL_MANU%TYPE,
  p_phone_number_manu IN CONTACT_MANUFACTURER.PHONE_NUMBER_MANU%TYPE,
  p_contact_manu_id   OUT CONTACT_MANUFACTURER.CONTACT_MANU_ID%TYPE
) IS
BEGIN
  IF valida_email(p_email_manu) = 0 THEN
    RAISE_APPLICATION_ERROR(-23000, 'E-mail inválido para fabricante.');
  END IF;

  INSERT INTO CONTACT_MANUFACTURER (
    EMAIL_MANU, PHONE_NUMBER_MANU
  ) VALUES (
    p_email_manu, p_phone_number_manu
  )
  RETURNING CONTACT_MANU_ID INTO p_contact_manu_id;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-23001, 'E-mail ou telefone já cadastrado.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-23002, 'Erro ao criar contato de fabricante: '||SQLERRM);
END oracle_challenge_create_contact_manufacturer;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_update_contact_manufacturer (
  p_contact_manu_id   IN CONTACT_MANUFACTURER.CONTACT_MANU_ID%TYPE,
  p_email_manu        IN CONTACT_MANUFACTURER.EMAIL_MANU%TYPE,
  p_phone_number_manu IN CONTACT_MANUFACTURER.PHONE_NUMBER_MANU%TYPE
) IS
BEGIN
  IF valida_email(p_email_manu) = 0 THEN
    RAISE_APPLICATION_ERROR(-23000, 'E-mail inválido para fabricante.');
  END IF;

  UPDATE CONTACT_MANUFACTURER
     SET EMAIL_MANU        = p_email_manu,
         PHONE_NUMBER_MANU = p_phone_number_manu
   WHERE CONTACT_MANU_ID   = p_contact_manu_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-23003, 'Contato de fabricante não encontrado.');
  END IF;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-23001, 'E-mail ou telefone já cadastrado.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-23002, 'Erro ao atualizar contato de fabricante: '||SQLERRM);
END oracle_challenge_update_contact_manufacturer;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_contact_manufacturer (
  p_contact_manu_id   IN CONTACT_MANUFACTURER.CONTACT_MANU_ID%TYPE
) IS
BEGIN
  DELETE FROM CONTACT_MANUFACTURER
   WHERE CONTACT_MANU_ID = p_contact_manu_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-23003, 'Contato de fabricante não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-23004, 'Não é possível excluir contato. Ele pode estar vinculado a fabricante.');
END oracle_challenge_delete_contact_manufacturer;
/
SHOW ERRORS;


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
    RAISE_APPLICATION_ERROR(-23100, 'CNPJ já cadastrado.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-23101, 'Erro ao criar fabricante. Verifique endereço/contato: '||SQLERRM);
END oracle_challenge_create_manufacturer;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_update_manufacturer (
  p_manufac_id              IN MANUFACTURER.MANUFAC_ID%TYPE,
  p_name_manu               IN MANUFACTURER.NAME_MANU%TYPE,
  p_cnpj                    IN MANUFACTURER.CNPJ%TYPE,
  p_address_id_manufacturer IN MANUFACTURER.ADDRESS_ID_MANUFACTURER%TYPE,
  p_contact_manu_id         IN MANUFACTURER.CONTACT_MANU_ID%TYPE
) IS
BEGIN
  UPDATE MANUFACTURER
     SET NAME_MANU               = p_name_manu,
         CNPJ                    = p_cnpj,
         ADDRESS_ID_MANUFACTURER = p_address_id_manufacturer,
         CONTACT_MANU_ID         = p_contact_manu_id
   WHERE MANUFAC_ID              = p_manufac_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-23102, 'Fabricante não encontrado.');
  END IF;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-23100, 'CNPJ já cadastrado.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-23103, 'Erro ao atualizar fabricante: '||SQLERRM);
END oracle_challenge_update_manufacturer;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_manufacturer (
  p_manufac_id IN MANUFACTURER.MANUFAC_ID%TYPE
) IS
BEGIN
  DELETE FROM MANUFACTURER
   WHERE MANUFAC_ID = p_manufac_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-23102, 'Fabricante não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-23104, 'Não é possível excluir fabricante. Ele pode ter lote vinculado.');
END oracle_challenge_delete_manufacturer;
/
SHOW ERRORS;


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
    RAISE_APPLICATION_ERROR(-24000, 'Erro ao criar princípio ativo: '||SQLERRM);
END oracle_challenge_create_active_ingredient;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_update_active_ingredient (
  p_act_ingre_id   IN ACTIVE_INGREDIENT.ACT_INGRE_ID%TYPE,
  p_act_ingredient IN ACTIVE_INGREDIENT.ACT_INGREDIENT%TYPE
) IS
BEGIN
  UPDATE ACTIVE_INGREDIENT
     SET ACT_INGREDIENT = p_act_ingredient
   WHERE ACT_INGRE_ID   = p_act_ingre_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-24001, 'Princípio ativo não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-24002, 'Erro ao atualizar princípio ativo: '||SQLERRM);
END oracle_challenge_update_active_ingredient;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_active_ingredient (
  p_act_ingre_id IN ACTIVE_INGREDIENT.ACT_INGRE_ID%TYPE
) IS
BEGIN
  DELETE FROM ACTIVE_INGREDIENT
   WHERE ACT_INGRE_ID = p_act_ingre_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-24001, 'Princípio ativo não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-24003, 'Não é possível excluir princípio ativo (está vinculado a medicamento?).');
END oracle_challenge_delete_active_ingredient;
/
SHOW ERRORS;


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
    RAISE_APPLICATION_ERROR(-24100, 'Erro ao criar forma farmacêutica: '||SQLERRM);
END oracle_challenge_create_pharm_form;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_update_pharm_form (
  p_pharm_form_id IN PHARMACEUTICAL_FORM.PHARM_FORM_ID%TYPE,
  p_pharma_form   IN PHARMACEUTICAL_FORM.PHARMA_FORM%TYPE
) IS
BEGIN
  UPDATE PHARMACEUTICAL_FORM
     SET PHARMA_FORM = p_pharma_form
   WHERE PHARM_FORM_ID = p_pharm_form_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-24101, 'Forma farmacêutica não encontrada.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-24102, 'Erro ao atualizar forma farmacêutica: '||SQLERRM);
END oracle_challenge_update_pharm_form;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_pharm_form (
  p_pharm_form_id IN PHARMACEUTICAL_FORM.PHARM_FORM_ID%TYPE
) IS
BEGIN
  DELETE FROM PHARMACEUTICAL_FORM
   WHERE PHARM_FORM_ID = p_pharm_form_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-24101, 'Forma farmacêutica não encontrada.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-24103, 'Não é possível excluir forma farmacêutica (pode estar vinculada).');
END oracle_challenge_delete_pharm_form;
/
SHOW ERRORS;


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
    RAISE_APPLICATION_ERROR(-24200, 'Erro ao criar unidade de medida: '||SQLERRM);
END oracle_challenge_create_unit_measure;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_update_unit_measure (
  p_unit_mea_id           IN UNIT_MEASURE.UNIT_MEA_ID%TYPE,
  p_unit_measure_medicine IN UNIT_MEASURE.UNIT_MEASURE_MEDICINE%TYPE
) IS
BEGIN
  UPDATE UNIT_MEASURE
     SET UNIT_MEASURE_MEDICINE = p_unit_measure_medicine
   WHERE UNIT_MEA_ID           = p_unit_mea_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-24201, 'Unidade de medida não encontrada.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-24202, 'Erro ao atualizar unidade de medida: '||SQLERRM);
END oracle_challenge_update_unit_measure;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_unit_measure (
  p_unit_mea_id IN UNIT_MEASURE.UNIT_MEA_ID%TYPE
) IS
BEGIN
  DELETE FROM UNIT_MEASURE
   WHERE UNIT_MEA_ID = p_unit_mea_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-24201, 'Unidade de medida não encontrada.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-24203, 'Não é possível excluir unidade de medida (pode estar em uso).');
END oracle_challenge_delete_unit_measure;
/
SHOW ERRORS;


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
    RAISE_APPLICATION_ERROR(-24300, 'Erro ao criar categoria: '||SQLERRM);
END oracle_challenge_create_category_medicine;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_update_category_medicine (
  p_category_med_id IN CATEGORY_MEDICINE.CATEGORY_MED_ID%TYPE,
  p_category        IN CATEGORY_MEDICINE.CATEGORY%TYPE
) IS
BEGIN
  UPDATE CATEGORY_MEDICINE
     SET CATEGORY = p_category
   WHERE CATEGORY_MED_ID = p_category_med_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-24301, 'Categoria não encontrada.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-24302, 'Erro ao atualizar categoria: '||SQLERRM);
END oracle_challenge_update_category_medicine;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_category_medicine (
  p_category_med_id IN CATEGORY_MEDICINE.CATEGORY_MED_ID%TYPE
) IS
BEGIN
  DELETE FROM CATEGORY_MEDICINE
   WHERE CATEGORY_MED_ID = p_category_med_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-24301, 'Categoria não encontrada.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-24303, 'Não é possível excluir categoria (pode estar em uso por medicamento).');
END oracle_challenge_delete_category_medicine;
/
SHOW ERRORS;


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
    RAISE_APPLICATION_ERROR(-24400, 'Erro ao criar medicamento. Verifique categoria/unidade/status: '||SQLERRM);
END oracle_challenge_create_medicine;
/
SHOW ERRORS;


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
    RAISE_APPLICATION_ERROR(-24401, 'Medicamento não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-24402, 'Erro ao atualizar medicamento: '||SQLERRM);
END oracle_challenge_update_medicine;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_medicine (
  p_medicine_id IN MEDICINES.MEDICINE_ID%TYPE
) IS
BEGIN
  DELETE FROM MEDICINES
   WHERE MEDICINE_ID = p_medicine_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-24401, 'Medicamento não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-24403, 'Não é possível excluir medicamento (pode estar em estoque).');
END oracle_challenge_delete_medicine;
/
SHOW ERRORS;


/* MEDICINE_ACTIVE_INGR (N:N) */
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
    RAISE_APPLICATION_ERROR(-24500, 'Erro ao vincular princípio ativo ao medicamento: '||SQLERRM);
END oracle_challenge_create_med_active_ingr;
/
SHOW ERRORS;


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
    RAISE_APPLICATION_ERROR(-24501, 'Vínculo medicamento x princípio ativo não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-24502, 'Erro ao atualizar vínculo medicamento x princípio ativo: '||SQLERRM);
END oracle_challenge_update_med_active_ingr;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_med_active_ingr (
  p_med_active_ingr_id IN MEDICINE_ACTIVE_INGR.MED_ACTIVE_INGR_ID%TYPE
) IS
BEGIN
  DELETE FROM MEDICINE_ACTIVE_INGR
   WHERE MED_ACTIVE_INGR_ID = p_med_active_ingr_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-24501, 'Vínculo medicamento x princípio ativo não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-24503, 'Erro ao excluir vínculo medicamento x princípio ativo: '||SQLERRM);
END oracle_challenge_delete_med_active_ingr;
/
SHOW ERRORS;


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
    RAISE_APPLICATION_ERROR(-24600, 'Erro ao vincular forma farmacêutica ao medicamento: '||SQLERRM);
END oracle_challenge_create_med_pharm_form;
/
SHOW ERRORS;


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
    RAISE_APPLICATION_ERROR(-24601, 'Vínculo medicamento x forma farmacêutica não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-24602, 'Erro ao atualizar vínculo medicamento x forma farmacêutica: '||SQLERRM);
END oracle_challenge_update_med_pharm_form;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_med_pharm_form (
  p_med_pharm_form_id IN MEDICINE_PHARM_FORM.MED_PHARM_FORM_ID%TYPE
) IS
BEGIN
  DELETE FROM MEDICINE_PHARM_FORM
   WHERE MED_PHARM_FORM_ID = p_med_pharm_form_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-24601, 'Vínculo medicamento x forma farmacêutica não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-24603, 'Erro ao excluir vínculo medicamento x forma farmacêutica: '||SQLERRM);
END oracle_challenge_delete_med_pharm_form;
/
SHOW ERRORS;


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
    RAISE_APPLICATION_ERROR(-24700, 'Erro ao criar tipo de movimento: '||SQLERRM);
END oracle_challenge_create_movement_type;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_update_movement_type (
  p_movement_type_id IN MOVEMENT_TYPE.MOVEMENT_TYPE_ID%TYPE,
  p_type_name        IN MOVEMENT_TYPE.TYPE_NAME%TYPE
) IS
BEGIN
  UPDATE MOVEMENT_TYPE
     SET TYPE_NAME = p_type_name
   WHERE MOVEMENT_TYPE_ID = p_movement_type_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-24701, 'Tipo de movimento não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-24702, 'Erro ao atualizar tipo de movimento: '||SQLERRM);
END oracle_challenge_update_movement_type;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_movement_type (
  p_movement_type_id IN MOVEMENT_TYPE.MOVEMENT_TYPE_ID%TYPE
) IS
BEGIN
  DELETE FROM MOVEMENT_TYPE
   WHERE MOVEMENT_TYPE_ID = p_movement_type_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-24701, 'Tipo de movimento não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-24703, 'Não é possível excluir tipo de movimento (já usado em movimentações).');
END oracle_challenge_delete_movement_type;
/
SHOW ERRORS;


--------------------------------------------------------------------------------
-- 7) LOTES
-- BATCH_MEDICINE  (usa valida_qtd_positiva)
--------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE oracle_challenge_create_batch_medicine (
  p_batch_number       IN BATCH_MEDICINE.BATCH_NUMBER%TYPE,
  p_current_quantity   IN BATCH_MEDICINE.CURRENT_QUANTITY%TYPE,
  p_manufacturing_date IN BATCH_MEDICINE.MANUFACTURING_DATE%TYPE,
  p_expiration_date    IN BATCH_MEDICINE.EXPIRATION_DATE%TYPE,
  p_manufac_id         IN BATCH_MEDICINE.MANUFAC_ID%TYPE,
  p_batch_id           OUT BATCH_MEDICINE.BATCH_ID%TYPE
) IS
BEGIN
  IF valida_qtd_positiva(p_current_quantity) = 0 THEN
    RAISE_APPLICATION_ERROR(-25000, 'Quantidade inicial inválida (precisa ser > 0).');
  END IF;

  INSERT INTO BATCH_MEDICINE (
    BATCH_NUMBER, CURRENT_QUANTITY,
    MANUFACTURING_DATE, EXPIRATION_DATE,
    MANUFAC_ID
  ) VALUES (
    p_batch_number, p_current_quantity,
    p_manufacturing_date, p_expiration_date,
    p_manufac_id
  )
  RETURNING BATCH_ID INTO p_batch_id;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-25001, 'Erro ao criar lote. Verifique fabricante / datas: '||SQLERRM);
END oracle_challenge_create_batch_medicine;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_update_batch_medicine (
  p_batch_id           IN BATCH_MEDICINE.BATCH_ID%TYPE,
  p_batch_number       IN BATCH_MEDICINE.BATCH_NUMBER%TYPE,
  p_current_quantity   IN BATCH_MEDICINE.CURRENT_QUANTITY%TYPE,
  p_manufacturing_date IN BATCH_MEDICINE.MANUFACTURING_DATE%TYPE,
  p_expiration_date    IN BATCH_MEDICINE.EXPIRATION_DATE%TYPE,
  p_manufac_id         IN BATCH_MEDICINE.MANUFAC_ID%TYPE
) IS
BEGIN
  IF valida_qtd_positiva(p_current_quantity) = 0 THEN
    RAISE_APPLICATION_ERROR(-25000, 'Quantidade inválida (precisa ser > 0).');
  END IF;

  UPDATE BATCH_MEDICINE
     SET BATCH_NUMBER       = p_batch_number,
         CURRENT_QUANTITY   = p_current_quantity,
         MANUFACTURING_DATE = p_manufacturing_date,
         EXPIRATION_DATE    = p_expiration_date,
         MANUFAC_ID         = p_manufac_id
   WHERE BATCH_ID           = p_batch_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-25002, 'Lote não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-25003, 'Erro ao atualizar lote: '||SQLERRM);
END oracle_challenge_update_batch_medicine;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_batch_medicine (
  p_batch_id IN BATCH_MEDICINE.BATCH_ID%TYPE
) IS
BEGIN
  DELETE FROM BATCH_MEDICINE
   WHERE BATCH_ID = p_batch_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-25002, 'Lote não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-25004, 'Não é possível excluir o lote. Ele pode estar em estoque.');
END oracle_challenge_delete_batch_medicine;
/
SHOW ERRORS;


--------------------------------------------------------------------------------
-- 8) ESTOQUE / MOVIMENTAÇÃO
-- STOCK / MEDICINE_DISPENSE / STOCK_MOVEMENT
--------------------------------------------------------------------------------

-- Função auxiliar usada em oracle_challenge_apply_movement
CREATE OR REPLACE FUNCTION is_saida (p_movement_type_id IN NUMBER)
  RETURN CHAR
IS
BEGIN
  -- Exemplo de tipos considerados saída:
  -- 5=Transferência Saída, 6=Dispensação,
  -- 9=Perda, 10=Vencimento
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

  IF valida_qtd_positiva(p_qty) = 0 THEN
    RAISE_APPLICATION_ERROR(-26000, 'Quantidade inválida (precisa ser > 0).');
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
      RAISE_APPLICATION_ERROR(-26001,
        'Saldo insuficiente. Atual='||v_current_qty||', Solicitado='||p_qty);
    END IF;
  ELSE
    v_new_qty := v_current_qty + p_qty;
  END IF;


  UPDATE STOCK
     SET QUANTITY = v_new_qty
   WHERE STOCK_ID = p_stock_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-26002, 'Estoque não encontrado.');
  END IF;

 
  p_dispensation_id := NULL;
  IF v_saida = 'S' THEN
    INSERT INTO MEDICINE_DISPENSE (
      DATE_DISPENSATION,
      QUANTITY_DISPENSED,
      DESTINATION,
      OBSERVATION,
      USER_ID
    ) VALUES (
      SYSDATE,
      p_qty,
      p_destination,
      p_observation,
      p_user_id
    )
    RETURNING DISPENSATION_ID INTO p_dispensation_id;
  END IF;

  -- registra STOCK_MOVEMENT
  INSERT INTO STOCK_MOVEMENT (
    QUANTITY_DISPENSED,
    DATE_MOVIMENT,
    MOVEMENT_TYPE_ID,
    STOCK_ID,
    DISPENSATION_ID,
    USER_ID
  ) VALUES (
    p_qty,
    SYSDATE,
    p_movement_type_id,
    p_stock_id,
    p_dispensation_id,
    p_user_id
  )
  RETURNING STOCK_MOVEMENT_ID INTO p_stock_movement_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-26002, 'Estoque não encontrado.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-26003, 'Erro ao aplicar movimento de estoque: '||SQLERRM);
END oracle_challenge_apply_movement;
/
SHOW ERRORS;


-- ajusta o inventário
CREATE OR REPLACE PROCEDURE oracle_challenge_set_stock_quantity (
  p_stock_id IN STOCK.STOCK_ID%TYPE,
  p_new_qty  IN STOCK.QUANTITY%TYPE
) IS
BEGIN
  IF p_new_qty < 0 THEN
    RAISE_APPLICATION_ERROR(-26100, 'Quantidade não pode ser negativa.');
  END IF;

  UPDATE STOCK
     SET QUANTITY = p_new_qty
   WHERE STOCK_ID = p_stock_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-26101, 'Estoque não encontrado.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-26102, 'Erro ao ajustar quantidade de estoque: '||SQLERRM);
END oracle_challenge_set_stock_quantity;
/
SHOW ERRORS;


-- cria um registro novo de estoque
CREATE OR REPLACE PROCEDURE oracle_challenge_create_stock (
  p_batch_id          IN STOCK.BATCH_ID%TYPE,
  p_medicine_id       IN STOCK.MEDICINE_ID%TYPE,
  p_location_id_stock IN STOCK.LOCATION_ID_STOCK%TYPE,
  p_quantity          IN STOCK.QUANTITY%TYPE,
  p_stock_id          OUT STOCK.STOCK_ID%TYPE
) IS
BEGIN
  IF valida_qtd_positiva(p_quantity) = 0 THEN
    RAISE_APPLICATION_ERROR(-26200, 'Quantidade inicial inválida (precisa ser > 0).');
  END IF;

  INSERT INTO STOCK (
    QUANTITY,
    BATCH_ID,
    MEDICINE_ID,
    LOCATION_ID_STOCK
  ) VALUES (
    p_quantity,
    p_batch_id,
    p_medicine_id,
    p_location_id_stock
  )
  RETURNING STOCK_ID INTO p_stock_id;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-26201, 'Já existe estoque deste lote/medicamento nesse local.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-26202, 'Erro ao criar estoque: '||SQLERRM);
END oracle_challenge_create_stock;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_update_stock (
  p_stock_id          IN STOCK.STOCK_ID%TYPE,
  p_batch_id          IN STOCK.BATCH_ID%TYPE,
  p_medicine_id       IN STOCK.MEDICINE_ID%TYPE,
  p_location_id_stock IN STOCK.LOCATION_ID_STOCK%TYPE,
  p_quantity          IN STOCK.QUANTITY%TYPE
) IS
BEGIN

  IF valida_qtd_positiva(p_quantity) = 0 THEN
    RAISE_APPLICATION_ERROR(-26210, 'Quantidade inválida (precisa ser > 0).');
  END IF;

  UPDATE STOCK
     SET BATCH_ID          = p_batch_id,
         MEDICINE_ID       = p_medicine_id,
         LOCATION_ID_STOCK = p_location_id_stock,
         QUANTITY          = p_quantity
   WHERE STOCK_ID          = p_stock_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-26211, 'Estoque não encontrado.');
  END IF;
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    
    RAISE_APPLICATION_ERROR(-26213, 'Já existe estoque deste lote/medicamento nesse local.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-26212, 'Erro ao atualizar estoque: '||SQLERRM);
END oracle_challenge_update_stock;
/


-- exclui estoque zerado
CREATE OR REPLACE PROCEDURE oracle_challenge_delete_stock (
  p_stock_id IN STOCK.STOCK_ID%TYPE
) IS
  v_qty NUMBER;
BEGIN

  SELECT QUANTITY
    INTO v_qty
    FROM STOCK
   WHERE STOCK_ID = p_stock_id;

  IF v_qty != 0 THEN
    RAISE_APPLICATION_ERROR(-26300, 'Não é possível excluir estoque com quantidade diferente de zero.');
  END IF;

  DELETE FROM STOCK
   WHERE STOCK_ID = p_stock_id;

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-26301, 'Estoque não encontrado.');
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-26301, 'Estoque não encontrado.');
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-26302, 'Não é possível excluir estoque. Pode haver movimentações vinculadas.');
END oracle_challenge_delete_stock;
/
SHOW ERRORS;




CREATE OR REPLACE PROCEDURE oracle_challenge_update_medicine_dispense_stub (
  p_dispensation_id IN MEDICINE_DISPENSE.DISPENSATION_ID%TYPE
) IS
BEGIN
  RAISE_APPLICATION_ERROR(-26400,
    'Alterar MEDICINE_DISPENSE não é permitido (histórico de dispensação).');
END oracle_challenge_update_medicine_dispense_stub;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_medicine_dispense_stub (
  p_dispensation_id IN MEDICINE_DISPENSE.DISPENSATION_ID%TYPE
) IS
BEGIN
  RAISE_APPLICATION_ERROR(-26401,
    'Excluir MEDICINE_DISPENSE não é permitido (histórico de dispensação).');
END oracle_challenge_delete_medicine_dispense_stub;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_update_stock_movement_stub (
  p_stock_movement_id IN STOCK_MOVEMENT.STOCK_MOVEMENT_ID%TYPE
) IS
BEGIN
  RAISE_APPLICATION_ERROR(-26402,
    'Alterar STOCK_MOVEMENT não é permitido (auditoria de estoque).');
END oracle_challenge_update_stock_movement_stub;
/
SHOW ERRORS;


CREATE OR REPLACE PROCEDURE oracle_challenge_delete_stock_movement_stub (
  p_stock_movement_id IN STOCK_MOVEMENT.STOCK_MOVEMENT_ID%TYPE
) IS
BEGIN
  RAISE_APPLICATION_ERROR(-26403,
    'Excluir STOCK_MOVEMENT não é permitido (auditoria de estoque).');
END oracle_challenge_delete_stock_movement_stub;
/
SHOW ERRORS;


-----------------------
-- Item 5
-----------------------
---------------------------------------------------------------------------
-- 1. TYPE do registro de relatório (1 linha do resultado)
--    Ajuste os tamanhos dos VARCHAR2 se quiser, mas assim já funciona bem.
---------------------------------------------------------------------------

CREATE OR REPLACE TYPE t_rel_estoque_row AS OBJECT (
  stock_id              NUMBER,
  medicine_id           NUMBER,
  medicine_name         VARCHAR2(200),
  lote_numero           VARCHAR2(100),
  validade              DATE,
  quantidade_em_estoque NUMBER,
  local_estoque_id      NUMBER,
  nome_local            VARCHAR2(200)
);
/
SHOW ERRORS;


---------------------------------------------------------------------------
-- 2. TYPE tabela (coleção de linhas do relatório)
--    Isso é o tipo que a função vai retornar.
---------------------------------------------------------------------------

CREATE OR REPLACE TYPE t_rel_estoque_tab AS TABLE OF t_rel_estoque_row;
/
SHOW ERRORS;


---------------------------------------------------------------------------
-- 3. Função de relatório
---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_relatorio_estoque
  RETURN t_rel_estoque_tab
IS

  v_result t_rel_estoque_tab := t_rel_estoque_tab();
  v_idx PLS_INTEGER := 0;


  CURSOR c_relatorio IS
    SELECT
      s.STOCK_ID                         AS stock_id,
      m.MEDICINE_ID                      AS medicine_id,
      m.NAME_MEDICATION                  AS medicine_name,
      b.BATCH_NUMBER                     AS lote_numero,
      b.EXPIRATION_DATE                  AS validade,
      s.QUANTITY                         AS quantidade_em_estoque,
      l.LOCATION_ID_STOCK                AS local_estoque_id,
     
      l.NAME_LOCATION || ' - ' || l.LOCATION_STOCK_NAME AS nome_local
    FROM STOCK s
    JOIN MEDICINES m
      ON m.MEDICINE_ID = s.MEDICINE_ID
    JOIN BATCH_MEDICINE b
      ON b.BATCH_ID = s.BATCH_ID
    JOIN LOCATION_STOCK l
      ON l.LOCATION_ID_STOCK = s.LOCATION_ID_STOCK
    ORDER BY
      m.NAME_MEDICATION,
      b.EXPIRATION_DATE;

BEGIN

  FOR rec IN c_relatorio LOOP

    v_idx := v_idx + 1;
    v_result.EXTEND;


    v_result(v_idx) :=
      t_rel_estoque_row(
        rec.stock_id,
        rec.medicine_id,
        rec.medicine_name,
        rec.lote_numero,
        rec.validade,
        rec.quantidade_em_estoque,
        rec.local_estoque_id,
        rec.nome_local
      );
  END LOOP;


  RETURN v_result;
END fn_relatorio_estoque;
/
SHOW ERRORS;


---------------------------------------------------------------------------
-- SELECT * FROM TABLE(fn_relatorio_estoque);
---------------------------------------------------------------------------


------------------------
-- Item 6
------------------------

---------------------------------------------------------------------------
-- 1. TYPE de uma linha do relatório (objeto)
---------------------------------------------------------------------------

CREATE OR REPLACE TYPE t_relatorio_med_local_row AS OBJECT (
  medicine_id       NUMBER,
  nome_medicamento  VARCHAR2(200),
  local_estoque     VARCHAR2(200),
  total_quantidade  NUMBER
);
/
SHOW ERRORS;


---------------------------------------------------------------------------
-- 2. TYPE tabela (coleção de linhas)
---------------------------------------------------------------------------

CREATE OR REPLACE TYPE t_relatorio_med_local_tab AS TABLE OF t_relatorio_med_local_row;
/
SHOW ERRORS;


---------------------------------------------------------------------------
-- 3. Função de relatório com regra de negócio e agregação
---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_relatorio_total_estoque
  RETURN t_relatorio_med_local_tab
IS
  v_result t_relatorio_med_local_tab := t_relatorio_med_local_tab();
  v_idx    PLS_INTEGER := 0;

  CURSOR c_relatorio IS
    SELECT
      m.MEDICINE_ID,
      m.NAME_MEDICATION       AS nome_medicamento,
      l.NAME_LOCATION || ' - ' || l.LOCATION_STOCK_NAME AS local_estoque,
      SUM(s.QUANTITY)         AS total_quantidade
    FROM STOCK s
    INNER JOIN MEDICINES m
      ON m.MEDICINE_ID = s.MEDICINE_ID
    INNER JOIN LOCATION_STOCK l
      ON l.LOCATION_ID_STOCK = s.LOCATION_ID_STOCK
    WHERE UPPER(m.STATUS_MED) = 'ATIVO'       
    GROUP BY
      m.MEDICINE_ID,
      m.NAME_MEDICATION,
      l.NAME_LOCATION,
      l.LOCATION_STOCK_NAME
    ORDER BY
      m.NAME_MEDICATION,
      l.NAME_LOCATION;

BEGIN
  FOR rec IN c_relatorio LOOP
    v_idx := v_idx + 1;
    v_result.EXTEND;
    v_result(v_idx) :=
      t_relatorio_med_local_row(
        rec.MEDICINE_ID,
        rec.nome_medicamento,
        rec.local_estoque,
        rec.total_quantidade
      );
  END LOOP;

  RETURN v_result;
END fn_relatorio_total_estoque;
/
SHOW ERRORS;


-- SELECT * FROM TABLE(fn_relatorio_total_estoque);




