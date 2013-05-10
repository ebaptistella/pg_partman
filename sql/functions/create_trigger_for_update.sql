CREATE FUNCTION create_trigger_for_update(p_parent_table text, p_partition_table text, p_control text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  v_tablename text;
  v_trig      text;
  v_tmp       integer;
BEGIN
  v_tablename := p_partition_table;
  IF position('.' in p_partition_table) > 0 THEN 
    v_tablename := substring(p_partition_table from position('.' in p_partition_table)+1);
  END IF;

  SELECT 1
    INTO v_tmp
    FROM information_schema.triggers
   WHERE trigger_name = 'trg_0000_'||v_tablename||'_'||p_control||'_befupd';
  IF NOT FOUND THEN
    v_trig := 'CREATE TRIGGER trg_0000_'||v_tablename||'_'||p_control||'_befupd BEFORE UPDATE OF '||p_control||' ON '||v_tablename||
			  ' FOR EACH ROW EXECUTE PROCEDURE pct_'||substring(p_parent_table from position('.' in p_parent_table)+1)||'_'||p_control||'_befupd()';
    EXECUTE v_trig;
  END IF;

END
$$;
