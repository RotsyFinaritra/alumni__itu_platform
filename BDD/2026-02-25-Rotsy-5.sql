DROP VIEW IF EXISTS v_post_activite_cpl;

CREATE OR REPLACE VIEW listecolonnetable AS
 SELECT table_catalog,
    upper((table_name)::text) AS table_name,
    column_name,
        CASE
            WHEN ((data_type)::text = 'character varying'::text) THEN 'character varying'::name
            WHEN ((data_type)::text = 'character'::text) THEN 'char'::name
            WHEN ((data_type)::text = 'text'::text) THEN 'character varying'::name
            WHEN ((data_type)::text = 'integer'::text) THEN 'NUMBER'::name
            WHEN ((data_type)::text = 'smallint'::text) THEN 'NUMBER'::name
            WHEN ((data_type)::text = 'bigint'::text) THEN 'NUMBER'::name
            WHEN ((data_type)::text = 'numeric'::text) THEN 'NUMBER'::name
            WHEN ((data_type)::text = 'double precision'::text) THEN 'NUMBER'::name
            WHEN ((data_type)::text = 'real'::text) THEN 'NUMBER'::name
            WHEN ((data_type)::text = 'date'::text) THEN 'Date'::name
            WHEN ((data_type)::text ~~ 'timestamp%'::text) THEN 'timestamp'::name
            WHEN ((data_type)::text = 'boolean'::text) THEN 'NUMBER'::name
            WHEN ((data_type)::text = 'bytea'::text) THEN 'blob'::name
            WHEN ((data_type)::text = 'USER-DEFINED'::text) THEN (udt_name)::name
            ELSE (data_type)::name
        END AS data_type,
    is_nullable,
    column_default,
    ordinal_position AS column_id,
    COALESCE((character_maximum_length)::integer, (numeric_precision)::integer,
        CASE
            WHEN ((data_type)::text = 'integer'::text) THEN 9
            WHEN ((data_type)::text = 'smallint'::text) THEN 4
            WHEN ((data_type)::text = 'bigint'::text) THEN 18
            WHEN ((data_type)::text = 'boolean'::text) THEN 1
            WHEN ((data_type)::text = 'date'::text) THEN 10
            WHEN ((data_type)::text ~~ 'timestamp%'::text) THEN 26
            WHEN ((data_type)::text = 'text'::text) THEN 4000
            ELSE 0
        END) AS data_precision,
    COALESCE((numeric_scale)::integer, 0) AS data_scale
   FROM information_schema.columns c
  WHERE ((table_schema)::name = 'public'::name)
  ORDER BY c.table_name, ordinal_position;