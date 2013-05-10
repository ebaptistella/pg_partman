CREATE FUNCTION create_trigger(p_parent_table text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE

v_tablename            text;
v_trig                  text;

BEGIN

IF position('.' in p_parent_table) > 0 THEN 
    v_tablename := substring(p_parent_table from position('.' in p_parent_table)+1);
END IF;


v_trig := 'CREATE TRIGGER trg_0000_'||v_tablename||'_befins BEFORE INSERT ON '||p_parent_table||
    ' FOR EACH ROW EXECUTE PROCEDURE pct_'||substring(p_parent_table from position('.' in p_parent_table)+1)||'_befins()';

--RAISE NOTICE 'v_trig: %', v_trig;
EXECUTE v_trig;

END
$$;
