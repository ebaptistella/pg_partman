-- ########## ID STATIC TESTS ##########

\set ON_ERROR_ROLLBACK 1
\set ON_ERROR_STOP true

BEGIN;
SELECT set_config('search_path','partman_test, public, partman, tap',false);

SELECT plan(76);
CREATE SCHEMA partman_test;
CREATE ROLE partman_basic;
CREATE ROLE partman_owner;

CREATE TABLE partman_test.id_static_table (col1 int primary key, col2 text, col3 timestamptz DEFAULT now());
INSERT INTO partman_test.id_static_table (col1) VALUES (generate_series(100,109));
GRANT SELECT,INSERT,UPDATE ON partman_test.id_static_table TO partman_basic;

SELECT create_parent('partman_test.id_static_table', 'col1', 'id-static', '10');
SELECT has_table('partman_test', 'id_static_table_part100', 'Check id_static_table_part100 exists');
SELECT has_table('partman_test', 'id_static_table_part110', 'Check id_static_table_part110 exists');
SELECT has_table('partman_test', 'id_static_table_part120', 'Check id_static_table_part120 exists');
SELECT has_table('partman_test', 'id_static_table_part130', 'Check id_static_table_part130 exists');
SELECT has_table('partman_test', 'id_static_table_part140', 'Check id_static_table_part140 exists');
SELECT has_table('partman_test', 'id_static_table_part90', 'Check id_static_table_part90 exists');
SELECT has_table('partman_test', 'id_static_table_part80', 'Check id_static_table_part80 exists');
SELECT has_table('partman_test', 'id_static_table_part70', 'Check id_static_table_part70 exists');
SELECT has_table('partman_test', 'id_static_table_part60', 'Check id_static_table_part60 exists');
SELECT hasnt_table('partman_test', 'id_static_table_part50', 'Check id_static_table_part50 doesn''t exists yet');
SELECT hasnt_table('partman_test', 'id_static_table_part150', 'Check id_static_table_part150 doesn''t exists yet');
SELECT col_is_pk('partman_test', 'id_static_table_part100', ARRAY['col1'], 'Check for primary key in id_static_table_part100');
SELECT col_is_pk('partman_test', 'id_static_table_part110', ARRAY['col1'], 'Check for primary key in id_static_table_part110');
SELECT col_is_pk('partman_test', 'id_static_table_part120', ARRAY['col1'], 'Check for primary key in id_static_table_part120');
SELECT col_is_pk('partman_test', 'id_static_table_part130', ARRAY['col1'], 'Check for primary key in id_static_table_part130');
SELECT col_is_pk('partman_test', 'id_static_table_part140', ARRAY['col1'], 'Check for primary key in id_static_table_part140');
SELECT col_is_pk('partman_test', 'id_static_table_part90', ARRAY['col1'], 'Check for primary key in id_static_table_part90');
SELECT col_is_pk('partman_test', 'id_static_table_part80', ARRAY['col1'], 'Check for primary key in id_static_table_part80');
SELECT col_is_pk('partman_test', 'id_static_table_part70', ARRAY['col1'], 'Check for primary key in id_static_table_part70');
SELECT col_is_pk('partman_test', 'id_static_table_part60', ARRAY['col1'], 'Check for primary key in id_static_table_part60');
SELECT table_privs_are('partman_test', 'id_static_table_part100', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part100');
SELECT table_privs_are('partman_test', 'id_static_table_part110', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part110');
SELECT table_privs_are('partman_test', 'id_static_table_part120', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part120');
SELECT table_privs_are('partman_test', 'id_static_table_part130', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part130');
SELECT table_privs_are('partman_test', 'id_static_table_part140', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part140');
SELECT table_privs_are('partman_test', 'id_static_table_part90', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part90');
SELECT table_privs_are('partman_test', 'id_static_table_part80', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part80');
SELECT table_privs_are('partman_test', 'id_static_table_part70', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part70');
SELECT table_privs_are('partman_test', 'id_static_table_part60', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part60');

SELECT partition_data_id('partman_test.id_static_table');
SELECT is_empty('SELECT * FROM ONLY partman_test.id_static_table', 'Check that parent table has had data moved to partition');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table', ARRAY[10], 'Check count from parent table');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part100', ARRAY[10], 'Check count from id_static_table_part100');

INSERT INTO partman_test.id_static_table (col1) VALUES (generate_series(60,99));
INSERT INTO partman_test.id_static_table (col1) VALUES (generate_series(110,145));

SELECT has_table('partman_test', 'id_static_table_part150', 'Check id_static_table_part150 exists');
SELECT has_table('partman_test', 'id_static_table_part160', 'Check id_static_table_part160 exists');
SELECT has_table('partman_test', 'id_static_table_part170', 'Check id_static_table_part170 exists');
SELECT hasnt_table('partman_test', 'id_static_table_part50', 'Check id_static_table_part180 doesn''t exists yet');
SELECT col_is_pk('partman_test', 'id_static_table_part150', ARRAY['col1'], 'Check for primary key in id_static_table_part150');
SELECT col_is_pk('partman_test', 'id_static_table_part160', ARRAY['col1'], 'Check for primary key in id_static_table_part160');
SELECT col_is_pk('partman_test', 'id_static_table_part170', ARRAY['col1'], 'Check for primary key in id_static_table_part170');
SELECT table_privs_are('partman_test', 'id_static_table_part150', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part150');
SELECT table_privs_are('partman_test', 'id_static_table_part160', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part160');
SELECT table_privs_are('partman_test', 'id_static_table_part170', 'partman_basic', ARRAY['SELECT','INSERT','UPDATE'], 'Check partman_basic privileges of id_static_table_part170');

SELECT is_empty('SELECT * FROM ONLY partman_test.id_static_table', 'Check that parent table has had no data inserted to it');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table', ARRAY[86], 'Check count from parent table');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part60', ARRAY[10], 'Check count from id_static_table_part60');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part70', ARRAY[10], 'Check count from id_static_table_part70');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part80', ARRAY[10], 'Check count from id_static_table_part80');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part90', ARRAY[10], 'Check count from id_static_table_part90');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part100', ARRAY[10], 'Check count from id_static_table_part100');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part110', ARRAY[10], 'Check count from id_static_table_part110');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part120', ARRAY[10], 'Check count from id_static_table_part120');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part130', ARRAY[10], 'Check count from id_static_table_part130');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part140', ARRAY[6], 'Check count from id_static_table_part140');
SELECT is_empty('SELECT * FROM partman_test.id_static_table_part150', 'Check that next is empty');

SELECT undo_partition('partman_test.id_static_table', 20);
SELECT results_eq('SELECT count(*)::int FROM ONLY partman_test.id_static_table', ARRAY[86], 'Check count from parent table after undo');
SELECT has_table('partman_test', 'id_static_table_part60', 'Check id_static_table_part60 still exists');
SELECT has_table('partman_test', 'id_static_table_part70', 'Check id_static_table_part70 still exists');
SELECT has_table('partman_test', 'id_static_table_part80', 'Check id_static_table_part80 still exists');
SELECT has_table('partman_test', 'id_static_table_part90', 'Check id_static_table_part90 still exists');
SELECT has_table('partman_test', 'id_static_table_part100', 'Check id_static_table_part100 still exists');
SELECT has_table('partman_test', 'id_static_table_part110', 'Check id_static_table_part110 still exists');
SELECT has_table('partman_test', 'id_static_table_part120', 'Check id_static_table_part120 still exists');
SELECT has_table('partman_test', 'id_static_table_part130', 'Check id_static_table_part130 still exists');
SELECT has_table('partman_test', 'id_static_table_part140', 'Check id_static_table_part140 still exists');
SELECT has_table('partman_test', 'id_static_table_part150', 'Check id_static_table_part140 still exists');
SELECT has_table('partman_test', 'id_static_table_part160', 'Check id_static_table_part140 still exists');
SELECT has_table('partman_test', 'id_static_table_part170', 'Check id_static_table_part140 still exists');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part60', ARRAY[10], 'Check count from id_static_table_part60');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part70', ARRAY[10], 'Check count from id_static_table_part70');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part80', ARRAY[10], 'Check count from id_static_table_part80');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part90', ARRAY[10], 'Check count from id_static_table_part90');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part100', ARRAY[10], 'Check count from id_static_table_part100');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part110', ARRAY[10], 'Check count from id_static_table_part110');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part120', ARRAY[10], 'Check count from id_static_table_part120');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part130', ARRAY[10], 'Check count from id_static_table_part130');
SELECT results_eq('SELECT count(*)::int FROM partman_test.id_static_table_part140', ARRAY[6], 'Check count from id_static_table_part140');

SELECT * FROM finish();
ROLLBACK;
