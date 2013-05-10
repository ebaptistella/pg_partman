-- ########## ID STATIC TESTS ##########

\set ON_ERROR_ROLLBACK 1
\set ON_ERROR_STOP true

BEGIN;
SELECT set_config('search_path','partman_test, public, partman, tap',false);

SELECT plan(104);
CREATE SCHEMA partman_test;
CREATE ROLE partman_basic;
CREATE ROLE partman_revoke;
CREATE ROLE partman_owner;

CREATE TABLE partman_test.id_static_table (col1 int primary key, col2 text, col3 timestamptz DEFAULT now());
INSERT INTO partman_test.id_static_table (col1) VALUES (generate_series(1,9));
GRANT SELECT,INSERT,UPDATE ON partman_test.id_static_table TO partman_basic;
GRANT ALL ON partman_test.id_static_table TO partman_revoke;

SELECT create_parent('partman_test.id_static_table', 'col1', 'id-static', '10');
SELECT has_table('partman_test', 'id_static_table_part0', 'Check id_static_table_part0 exists');
SELECT has_table('partman_test', 'id_static_table_part10', 'Check id_static_table_part10 exists');
SELECT has_table('partman_test', 'id_static_table_part20', 'Check id_static_table_part20 exists');
SELECT has_table('partman_test', 'id_static_table_part30', 'Check id_static_table_part30 exists');
SELECT has_table('partman_test', 'id_static_table_part40', 'Check id_static_table_part40 exists');
SELECT hasnt_table('partman_test', 'id_static_table_part50', 'Check id_static_table_part50 doesn''t exists yet');
SELECT col_is_pk('partman_test', 'id_static_table_part0', ARRAY['col1'], 'Check for primary key in id_static_table_part0');
SELECT col_is_pk('partman_test', 'id_static_table_part10', ARRAY['col1'], 'Check for primary key in id_static_table_part10');
SELECT col_is_pk('partman_test', 'id_static_table_part20', ARRAY['col1'], 'Check for primary key in id_static_table_part20');
SELECT col_is_pk('partman_test', 'id_static_table_part30', ARRAY['col1'], 'Check for primary key in id_static_table_part30');
SELECT col_is_pk('partman_test', 'id_static_table_part40', ARRAY['col1'], 'Check for primary key in id_static_table_part40');
SELECT table_privs_are('partman_test', 'id_static_table_part0', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part0');
SELECT table_privs_are('partman_test', 'id_static_table_part10', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part10');
SELECT table_privs_are('partman_test', 'id_static_table_part20', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part20');
SELECT table_privs_are('partman_test', 'id_static_table_part30', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part30');
SELECT table_privs_are('partman_test', 'id_static_table_part40', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part40');
SELECT table_privs_are('partman_test', 'id_static_table_part0', 'partman_revoke', ARRAY['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'TRUNCATE', 'REFERENCES', 'TRIGGER'], 'Check partman_revoke privileges of id_static_table_part0');
SELECT table_privs_are('partman_test', 'id_static_table_part10', 'partman_revoke', ARRAY['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'TRUNCATE', 'REFERENCES', 'TRIGGER'], 'Check partman_revoke privileges of id_static_table_part10');
SELECT table_privs_are('partman_test', 'id_static_table_part20', 'partman_revoke', ARRAY['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'TRUNCATE', 'REFERENCES', 'TRIGGER'], 'Check partman_revoke privileges of id_static_table_part20');
SELECT table_privs_are('partman_test', 'id_static_table_part30', 'partman_revoke', ARRAY['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'TRUNCATE', 'REFERENCES', 'TRIGGER'], 'Check partman_revoke privileges of id_static_table_part30');
SELECT table_privs_are('partman_test', 'id_static_table_part40', 'partman_revoke', ARRAY['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'TRUNCATE', 'REFERENCES', 'TRIGGER'], 'Check partman_revoke privileges of id_static_table_part40');

SELECT partition_data_id('partman_test.id_static_table');
SELECT is_empty('SELECT * FROM ONLY partman_test.id_static_table', 'Check that parent table has had data moved to partition');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table', ARRAY[9], 'Check count from parent table');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part0', ARRAY[9], 'Check count from id_static_table_part0');

REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON partman_test.id_static_table FROM partman_revoke;
INSERT INTO partman_test.id_static_table (col1) VALUES (generate_series(10,25));

SELECT is_empty('SELECT * FROM ONLY partman_test.id_static_table', 'Check that parent table has had no data inserted to it');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part10', ARRAY[10], 'Check count from id_static_table_part10');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part20', ARRAY[6], 'Check count from id_static_table_part20');

SELECT has_table('partman_test', 'id_static_table_part50', 'Check id_static_table_part50 exists');
SELECT hasnt_table('partman_test', 'id_static_table_part60', 'Check id_static_table_part60 doesn''t exists yet');
SELECT col_is_pk('partman_test', 'id_static_table_part50', ARRAY['col1'], 'Check for primary key in id_static_table_part50');
SELECT table_privs_are('partman_test', 'id_static_table_part0', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part0');
SELECT table_privs_are('partman_test', 'id_static_table_part10', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part10');
SELECT table_privs_are('partman_test', 'id_static_table_part20', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part20');
SELECT table_privs_are('partman_test', 'id_static_table_part30', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part30');
SELECT table_privs_are('partman_test', 'id_static_table_part40', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part40');
SELECT table_privs_are('partman_test', 'id_static_table_part50', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part50');
SELECT table_privs_are('partman_test', 'id_static_table_part50', 'partman_revoke', ARRAY['SELECT'], 'Check partman_revoke privileges of id_static_table_part50');

GRANT DELETE ON partman_test.id_static_table TO partman_basic;
REVOKE ALL ON partman_test.id_static_table FROM partman_revoke;
ALTER TABLE partman_test.id_static_table OWNER TO partman_owner;
INSERT INTO partman_test.id_static_table (col1) VALUES (generate_series(26,55));

SELECT is_empty('SELECT * FROM ONLY partman_test.id_static_table', 'Check that parent table has had no data inserted to it');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table', ARRAY[55], 'Check count from parent table');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part20', ARRAY[10], 'Check count from id_static_table_part20');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part30', ARRAY[10], 'Check count from id_static_table_part30');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part40', ARRAY[10], 'Check count from id_static_table_part40');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part50', ARRAY[6], 'Check count from id_static_table_part50');

SELECT has_table('partman_test', 'id_static_table_part60', 'Check id_static_table_part60 exists');
SELECT has_table('partman_test', 'id_static_table_part70', 'Check id_static_table_part70 exists');
SELECT has_table('partman_test', 'id_static_table_part80', 'Check id_static_table_part80 exists');
SELECT hasnt_table('partman_test', 'id_static_table_part90', 'Check id_static_table_part90 doesn''t exists yet');
SELECT col_is_pk('partman_test', 'id_static_table_part60', ARRAY['col1'], 'Check for primary key in id_static_table_part60');
SELECT col_is_pk('partman_test', 'id_static_table_part70', ARRAY['col1'], 'Check for primary key in id_static_table_part70');
SELECT col_is_pk('partman_test', 'id_static_table_part80', ARRAY['col1'], 'Check for primary key in id_static_table_part80');
SELECT table_privs_are('partman_test', 'id_static_table_part0', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part0');
SELECT table_privs_are('partman_test', 'id_static_table_part10', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part10');
SELECT table_privs_are('partman_test', 'id_static_table_part20', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part20');
SELECT table_privs_are('partman_test', 'id_static_table_part30', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part30');
SELECT table_privs_are('partman_test', 'id_static_table_part40', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part40');
SELECT table_privs_are('partman_test', 'id_static_table_part50', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part50');
SELECT table_privs_are('partman_test', 'id_static_table_part60', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE','DELETE'], 'Check partman_basic privileges of id_static_table_part60');
SELECT table_privs_are('partman_test', 'id_static_table_part70', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE','DELETE'], 'Check partman_basic privileges of id_static_table_part70');
SELECT table_privs_are('partman_test', 'id_static_table_part80', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE','DELETE'], 'Check partman_basic privileges of id_static_table_part80');
SELECT table_privs_are('partman_test', 'id_static_table_part50', 'partman_revoke', ARRAY['SELECT'], 'Check partman_revoke privileges of id_static_table_part50');
SELECT table_privs_are('partman_test', 'id_static_table_part60', 'partman_revoke', '{}'::text[], 'Check partman_revoke has no privileges on id_static_table_part60');
SELECT table_privs_are('partman_test', 'id_static_table_part70', 'partman_revoke', '{}'::text[], 'Check partman_revoke has no privileges on id_static_table_part70');
SELECT table_privs_are('partman_test', 'id_static_table_part80', 'partman_revoke', '{}'::text[], 'Check partman_revoke has no privileges on id_static_table_part80');
SELECT table_owner_is ('partman_test', 'id_static_table_part60', 'partman_owner', 'Check that ownership change worked for id_static_table_part60');
SELECT table_owner_is ('partman_test', 'id_static_table_part70', 'partman_owner', 'Check that ownership change worked for id_static_table_part70');
SELECT table_owner_is ('partman_test', 'id_static_table_part80', 'partman_owner', 'Check that ownership change worked for id_static_table_part80');

INSERT INTO partman_test.id_static_table (col1) VALUES (generate_series(200,210));
SELECT results_eq('SELECT count(*)::int FROM ONLY partman_test.id_static_table', ARRAY[11], 'Check that data outside trigger scope goes to parent');

SELECT reapply_privileges('partman_test.id_static_table');
SELECT table_privs_are('partman_test', 'id_static_table_part0', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE','DELETE'], 'Check partman_basic privileges of id_static_table_part0');
SELECT table_privs_are('partman_test', 'id_static_table_part10', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE','DELETE'], 'Check partman_basic privileges of id_static_table_part10');
SELECT table_privs_are('partman_test', 'id_static_table_part20', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE','DELETE'], 'Check partman_basic privileges of id_static_table_part20');
SELECT table_privs_are('partman_test', 'id_static_table_part30', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE','DELETE'], 'Check partman_basic privileges of id_static_table_part30');
SELECT table_privs_are('partman_test', 'id_static_table_part40', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE','DELETE'], 'Check partman_basic privileges of id_static_table_part40');
SELECT table_privs_are('partman_test', 'id_static_table_part50', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE','DELETE'], 'Check partman_basic privileges of id_static_table_part50');
SELECT table_privs_are('partman_test', 'id_static_table_part60', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE','DELETE'], 'Check partman_basic privileges of id_static_table_part60');
SELECT table_privs_are('partman_test', 'id_static_table_part70', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE','DELETE'], 'Check partman_basic privileges of id_static_table_part70');
SELECT table_privs_are('partman_test', 'id_static_table_part80', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE','DELETE'], 'Check partman_basic privileges of id_static_table_part80');
SELECT table_privs_are('partman_test', 'id_static_table_part0', 'partman_revoke', '{}'::text[], 'Check partman_revoke has no privileges on id_static_table_part0');
SELECT table_privs_are('partman_test', 'id_static_table_part10', 'partman_revoke', '{}'::text[], 'Check partman_revoke has no privileges on id_static_table_part10');
SELECT table_privs_are('partman_test', 'id_static_table_part20', 'partman_revoke', '{}'::text[], 'Check partman_revoke has no privileges on id_static_table_part20');
SELECT table_privs_are('partman_test', 'id_static_table_part30', 'partman_revoke', '{}'::text[], 'Check partman_revoke has no privileges on id_static_table_part30');
SELECT table_privs_are('partman_test', 'id_static_table_part40', 'partman_revoke', '{}'::text[], 'Check partman_revoke has no privileges on id_static_table_part40');
SELECT table_privs_are('partman_test', 'id_static_table_part50', 'partman_revoke', '{}'::text[], 'Check partman_revoke has no privileges on id_static_table_part50');
SELECT table_privs_are('partman_test', 'id_static_table_part60', 'partman_revoke', '{}'::text[], 'Check partman_revoke has no privileges on id_static_table_part60');
SELECT table_privs_are('partman_test', 'id_static_table_part70', 'partman_revoke', '{}'::text[], 'Check partman_revoke has no privileges on id_static_table_part70');
SELECT table_privs_are('partman_test', 'id_static_table_part80', 'partman_revoke', '{}'::text[], 'Check partman_revoke has no privileges on id_static_table_part80');
SELECT table_owner_is ('partman_test', 'id_static_table_part0', 'partman_owner', 'Check that ownership change worked for id_static_table_part0');
SELECT table_owner_is ('partman_test', 'id_static_table_part10', 'partman_owner', 'Check that ownership change worked for id_static_table_part10');
SELECT table_owner_is ('partman_test', 'id_static_table_part20', 'partman_owner', 'Check that ownership change worked for id_static_table_part20');
SELECT table_owner_is ('partman_test', 'id_static_table_part30', 'partman_owner', 'Check that ownership change worked for id_static_table_part30');
SELECT table_owner_is ('partman_test', 'id_static_table_part40', 'partman_owner', 'Check that ownership change worked for id_static_table_part40');
SELECT table_owner_is ('partman_test', 'id_static_table_part50', 'partman_owner', 'Check that ownership change worked for id_static_table_part50');
SELECT table_owner_is ('partman_test', 'id_static_table_part60', 'partman_owner', 'Check that ownership change worked for id_static_table_part60');
SELECT table_owner_is ('partman_test', 'id_static_table_part70', 'partman_owner', 'Check that ownership change worked for id_static_table_part70');
SELECT table_owner_is ('partman_test', 'id_static_table_part80', 'partman_owner', 'Check that ownership change worked for id_static_table_part80');

SELECT undo_partition_id('partman_test.id_static_table', 10, p_keep_table := false);
SELECT results_eq('SELECT count(*)::int FROM ONLY partman_test.id_static_table', ARRAY[66], 'Check count from parent table after undo');
SELECT hasnt_table('partman_test', 'id_static_table_part0', 'Check id_static_table_part0 doesn''t exists anymore');
SELECT hasnt_table('partman_test', 'id_static_table_part10', 'Check id_static_table_part10 doesn''t exists anymore');
SELECT hasnt_table('partman_test', 'id_static_table_part20', 'Check id_static_table_part20 doesn''t exists anymore');
SELECT hasnt_table('partman_test', 'id_static_table_part30', 'Check id_static_table_part30 doesn''t exists anymore');
SELECT hasnt_table('partman_test', 'id_static_table_part40', 'Check id_static_table_part40 doesn''t exists anymore');
SELECT hasnt_table('partman_test', 'id_static_table_part50', 'Check id_static_table_part50 doesn''t exists anymore');
SELECT hasnt_table('partman_test', 'id_static_table_part60', 'Check id_static_table_part60 doesn''t exists anymore');
SELECT hasnt_table('partman_test', 'id_static_table_part70', 'Check id_static_table_part70 doesn''t exists anymore');
SELECT hasnt_table('partman_test', 'id_static_table_part80', 'Check id_static_table_part80 doesn''t exists anymore');

SELECT * FROM finish();
ROLLBACK;
