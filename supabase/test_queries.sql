-- Test Queries
--
-- Goal:
-- Prove that the SAME SQL query returns DIFFERENT results
-- for different simulated users.


RESET ROLE;

SELECT
    COUNT(*) AS total_seeded_nodes,
    COUNT(*) FILTER (WHERE org_id = 'supra') AS supra_nodes,
    COUNT(*) FILTER (WHERE org_id = 'city_clinic') AS city_clinic_nodes
FROM knowledge_nodes;


SET ROLE authenticated;


SELECT set_config('app.current_org_id', 'supra', false);
SELECT set_config('app.current_role', 'VIEWER', false);
SELECT set_config('app.current_department', 'ortho', false);
SELECT set_config('app.current_ceiling', '10', false);
SELECT set_config('app.current_clearance', '', false);


SELECT
    'Priya' AS simulated_user,
    COUNT(*) AS visible_count,
    ARRAY_AGG(id ORDER BY id) AS visible_node_ids
FROM knowledge_nodes;


SELECT
    'Priya leak checks' AS check_name,
    COUNT(*) FILTER (WHERE org_id <> 'supra') AS other_org_rows,
    COUNT(*) FILTER (
        WHERE department NOT IN ('ortho') AND department IS NOT NULL AND zone <> 2
    ) AS other_department_rows,
    COUNT(*) FILTER (WHERE hierarchy_level < 10) AS above_ceiling_rows,
    COUNT(*) FILTER (WHERE compliance_tags && ARRAY['MNPI', 'CONFIDENTIAL']) AS restricted_compliance_rows
FROM knowledge_nodes;


SELECT set_config('app.current_org_id', 'supra', false);
SELECT set_config('app.current_role', 'HOD', false);
SELECT set_config('app.current_department', 'ortho', false);
SELECT set_config('app.current_ceiling', '4', false);
SELECT set_config('app.current_clearance', '', false);


SELECT
    'Vikram' AS simulated_user,
    COUNT(*) AS visible_count,
    ARRAY_AGG(id ORDER BY id) AS visible_node_ids
FROM knowledge_nodes;


SELECT
    'Vikram leak checks' AS check_name,
    COUNT(*) FILTER (WHERE org_id <> 'supra') AS other_org_rows,
    COUNT(*) FILTER (
        WHERE department NOT IN ('ortho') AND department IS NOT NULL AND zone <> 2
    ) AS other_department_rows,
    COUNT(*) FILTER (WHERE compliance_tags && ARRAY['MNPI', 'CONFIDENTIAL']) AS restricted_compliance_rows
FROM knowledge_nodes;

SELECT set_config('app.current_org_id', 'supra', false);
SELECT set_config('app.current_role', 'ADMIN', false);
SELECT set_config('app.current_department', 'admin', false);
SELECT set_config('app.current_ceiling', '1', false);
SELECT set_config('app.current_clearance', 'MNPI,CONFIDENTIAL,CONTROLLED_SUBSTANCE', false);

SELECT
    'Suresh' AS simulated_user,
    COUNT(*) AS visible_count,
    ARRAY_AGG(id ORDER BY id) AS visible_node_ids
FROM knowledge_nodes;

SELECT
    'Suresh org isolation check' AS check_name,
    COUNT(*) FILTER (WHERE org_id = 'city_clinic') AS city_clinic_rows_visible_to_supra_admin
FROM knowledge_nodes;


SELECT set_config('app.current_org_id', 'supra', false);
SELECT set_config('app.current_role', 'EDITOR', false);
SELECT set_config('app.current_department', 'medicine', false);
SELECT set_config('app.current_ceiling', '8', false);
SELECT set_config('app.current_clearance', '', false);

SELECT
    'Ananya' AS simulated_user,
    COUNT(*) AS visible_count,
    ARRAY_AGG(id ORDER BY id) AS visible_node_ids
FROM knowledge_nodes;

SELECT
    'Ananya leak checks' AS check_name,
    COUNT(*) FILTER (WHERE org_id <> 'supra') AS other_org_rows,
    COUNT(*) FILTER (
        WHERE department NOT IN ('medicine') AND department IS NOT NULL AND zone <> 2
    ) AS other_department_rows,
    COUNT(*) FILTER (WHERE hierarchy_level < 8) AS above_ceiling_rows,
    COUNT(*) FILTER (WHERE compliance_tags && ARRAY['MNPI', 'CONFIDENTIAL']) AS restricted_compliance_rows
FROM knowledge_nodes;


SELECT set_config('app.current_org_id', 'city_clinic', false);
SELECT set_config('app.current_role', 'EDITOR', false);
SELECT set_config('app.current_department', 'medicine', false);
SELECT set_config('app.current_ceiling', '8', false);
SELECT set_config('app.current_clearance', '', false);

SELECT
    'City Clinic Doctor' AS simulated_user,
    COUNT(*) AS visible_count,
    ARRAY_AGG(id ORDER BY id) AS visible_node_ids
FROM knowledge_nodes;

SELECT
    'City Clinic org isolation check' AS check_name,
    COUNT(*) FILTER (WHERE org_id = 'supra') AS supra_rows_visible_to_city_clinic
FROM knowledge_nodes;


SELECT set_config('app.current_org_id', 'supra', false);
SELECT set_config('app.current_role', 'VIEWER', false);
SELECT set_config('app.current_department', 'pharmacy', false);
SELECT set_config('app.current_ceiling', '12', false);
SELECT set_config('app.current_clearance', 'CONTROLLED_SUBSTANCE', false);

SELECT
    'Ravi' AS simulated_user,
    COUNT(*) AS visible_count,
    ARRAY_AGG(id ORDER BY id) AS visible_node_ids
FROM knowledge_nodes;

SELECT
    'Ravi controlled substance check' AS check_name,
    COUNT(*) FILTER (WHERE compliance_tags && ARRAY['CONTROLLED_SUBSTANCE']) AS controlled_substance_rows_visible,
    COUNT(*) FILTER (WHERE compliance_tags && ARRAY['MNPI', 'CONFIDENTIAL']) AS mnpi_or_confidential_rows_visible
FROM knowledge_nodes;



-- Reset back to owner role after tests 

RESET ROLE;