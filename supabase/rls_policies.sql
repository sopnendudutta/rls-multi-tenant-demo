-- RLS Policies

DROP POLICY IF EXISTS knowledge_nodes_select_policy ON knowledge_nodes;

-- Enable RLS on the protected table.
ALTER TABLE knowledge_nodes ENABLE ROW LEVEL SECURITY;

ALTER TABLE knowledge_nodes FORCE ROW LEVEL SECURITY;



CREATE POLICY knowledge_nodes_select_policy
ON knowledge_nodes
FOR SELECT
USING (
    status = 'ACTIVE'

    AND org_id = current_setting('app.current_org_id', true)

    -- ADMIN can see all departments inside their own org.

    AND (
        current_setting('app.current_role', true) = 'ADMIN'
        OR department = current_setting('app.current_department', true)
        OR department IS NULL
        OR zone = 2
    )

    
    AND (
        current_setting('app.current_role', true) IN ('ADMIN', 'HOD')
        OR hierarchy_level >= NULLIF(
            current_setting('app.current_ceiling', true),
            ''
        )::INTEGER
    )

    
    AND (
        compliance_tags IS NULL
        OR cardinality(compliance_tags) = 0
        OR compliance_tags <@ (
            CASE
                WHEN NULLIF(
                    current_setting('app.current_clearance', true),
                    ''
                ) IS NULL
                THEN ARRAY[]::TEXT[]
                ELSE string_to_array(
                    current_setting('app.current_clearance', true),
                    ','
                )::TEXT[]
            END
        )
    )
);

-- grants , this will control if the user role can select

GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT ON knowledge_nodes TO authenticated;