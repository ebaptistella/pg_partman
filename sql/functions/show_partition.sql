/*
 * Function to list partition tables
 */
CREATE OR REPLACE FUNCTION show_partition (p_parent_table text) 
RETURNS SETOF text AS 
$body$
begin
	RETURN QUERY EXECUTE '
        SELECT cast(c.relname as text)
          FROM pg_namespace n, pg_class p, pg_inherits i, pg_class c
         WHERE n.nspname||'||quote_literal('.')||'||p.relname='||quote_literal(p_parent_table)||'
           AND n.oid=p.relnamespace
           AND p.oid=i.inhparent
           AND i.inhrelid=c.oid
         ORDER BY c.relname';
end
$body$
LANGUAGE 'plpgsql' STABLE SECURITY DEFINER;