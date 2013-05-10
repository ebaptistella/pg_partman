/*
 * Create the trigger function for the partition table on update
 */
CREATE FUNCTION create_function_for_update(p_parent_table text, p_control text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE

c_loop_primary_keys CURSOR (p_parent_table text) FOR
	SELECT c.column_name, c.data_type
	  FROM information_schema.table_constraints tc
	  JOIN information_schema.constraint_column_usage AS ccu USING (constraint_schema, constraint_name)
	  JOIN information_schema.columns AS c ON (c.table_schema = tc.constraint_schema AND tc.table_name = c.table_name AND ccu.column_name = c.column_name)
	 WHERE constraint_type = cast('PRIMARY KEY' as text)
	   AND tc.table_schema||'.'||tc.table_name = p_parent_table
	ORDER BY dtd_identifier;


v_tmp             integer;
v_trig_func       text;
v_job_id          bigint;
v_jobmon_schema   text;
v_old_search_path text;
v_step_id         bigint;

BEGIN

  SELECT nspname INTO v_jobmon_schema FROM pg_namespace n, pg_extension e WHERE e.extname = 'pg_jobmon' AND e.extnamespace = n.oid;
  IF v_jobmon_schema IS NOT NULL THEN
      SELECT current_setting('search_path') INTO v_old_search_path;
      EXECUTE 'SELECT set_config(''search_path'',''@extschema@,'||v_jobmon_schema||''',''false'')';
  END IF;

  IF v_jobmon_schema IS NOT NULL THEN
      v_job_id := add_job('PARTMAN CREATE FUNCTION: '||p_parent_table);
      v_step_id := add_step(v_job_id, 'Creating partition function for table '||p_parent_table);
  END IF;

  SELECT 1
    INTO v_tmp
    FROM pg_catalog.pg_proc p
   WHERE p.proname='pct_'||substring(p_parent_table from position('.' in p_parent_table)+1)||'_'||p_control||'_befupd';
  IF NOT FOUND THEN
    v_trig_func := 'CREATE OR REPLACE FUNCTION '||substring(p_parent_table from 1 for position('.' in p_parent_table))||'pct_'||substring(p_parent_table from position('.' in p_parent_table)+1)||'_'||p_control||'_befupd()' || chr(10)
                   || 'RETURNS TRIGGER AS $t$' || chr(10)
                   || 'BEGIN' || chr(10) || chr(10);
    v_trig_func := v_trig_func 
	               || '  IF ( NEW.' || p_control || ' != OLD.' || p_control || ') THEN ' || chr(10)
                   || '    EXECUTE ' || chr(10)
                   || '        ''DELETE FROM '|| p_parent_table || ' WHERE '' || ' || chr(10);
    FOR c_part IN  c_loop_primary_keys (p_parent_table) LOOP
      v_trig_func := v_trig_func 
	               || '        ''' || c_part.column_name || ' = '''''' || OLD.' || c_part.column_name || '::' || c_part.data_type || ' || '''''' AND '' || ' || chr(10);
    END LOOP;
    v_trig_func := substr(v_trig_func, 1, length(v_trig_func)-10) || ''';';
    v_trig_func := v_trig_func 
	               || chr(10) || '    INSERT INTO ' || p_parent_table || ' VALUES (NEW.*);' || chr(10);

    v_trig_func := v_trig_func 
	               || '  END IF;'  || chr(10)  || chr(10)
                   || '  RETURN NULL;' || chr(10)
                   || 'END;' || chr(10)
                   || '$t$' || chr(10)
                   || 'LANGUAGE plpgsql;';
    EXECUTE v_trig_func;
  END IF;
	
  IF v_jobmon_schema IS NOT NULL THEN
      PERFORM close_job(v_job_id);
      EXECUTE 'SELECT set_config(''search_path'','''||v_old_search_path||''',''false'')';
  END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF v_jobmon_schema IS NOT NULL THEN
            EXECUTE 'SELECT set_config(''search_path'',''@extschema@,'||v_jobmon_schema||''',''false'')';
            IF v_job_id IS NULL THEN
                v_job_id := add_job('PARTMAN CREATE FUNCTION: '||p_parent_table);
                v_step_id := add_step(v_job_id, 'Partition function maintenance for table '||p_parent_table||' failed');
            ELSIF v_step_id IS NULL THEN
                v_step_id := add_step(v_job_id, 'EXCEPTION before first step logged');
            END IF;
            PERFORM update_step(v_step_id, 'CRITICAL', 'ERROR: '||coalesce(SQLERRM,'unknown'));
            PERFORM fail_job(v_job_id);
            EXECUTE 'SELECT set_config(''search_path'','''||v_old_search_path||''',''false'')';
        END IF;
        RAISE EXCEPTION '%', SQLERRM;
END
$$;