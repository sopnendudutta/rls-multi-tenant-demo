# Direct Database Proof

## Goal

This document explains how to prove that PostgreSQL Row-Level Security is enforcing access control even without application-level filtering.

The core proof is:

```sql
SELECT * FROM knowledge_nodes ORDER BY id;
```

The query stays the same.

Only the simulated user claims change.

---

## Important Note

In Supabase SQL Editor, the default SQL editor role can have elevated privileges.

To test RLS behavior, the test script switches to the `authenticated` role:

```sql
SET ROLE authenticated;
```

This ensures the query is evaluated through Row-Level Security policies.

---

## Step 1: Confirm Full Seed Dataset

Run as the default SQL editor role:

```sql
RESET ROLE;

SELECT
    COUNT(*) AS total_seeded_nodes,
    COUNT(*) FILTER (WHERE org_id = 'supra') AS supra_nodes,
    COUNT(*) FILTER (WHERE org_id = 'city_clinic') AS city_clinic_nodes
FROM knowledge_nodes;
```

Expected:

```txt
total_seeded_nodes: 30
supra_nodes: 25
city_clinic_nodes: 5
```

---

## Step 2: Switch to Authenticated Role

```sql
SET ROLE authenticated;
```

---

## Step 3: Simulate Nurse Priya

```sql
SELECT set_config('app.current_org_id', 'supra', false);
SELECT set_config('app.current_role', 'VIEWER', false);
SELECT set_config('app.current_department', 'ortho', false);
SELECT set_config('app.current_ceiling', '10', false);
SELECT set_config('app.current_clearance', '', false);

SELECT COUNT(*), ARRAY_AGG(id ORDER BY id)
FROM knowledge_nodes;
```

Priya should only see rows that pass:

* Supra organization
* Ortho / hospital-wide / Zone 2 department scope
* Level 10 or lower sensitivity
* no restricted compliance tags

---

## Step 4: Simulate Admin Suresh

```sql
SELECT set_config('app.current_org_id', 'supra', false);
SELECT set_config('app.current_role', 'ADMIN', false);
SELECT set_config('app.current_department', 'admin', false);
SELECT set_config('app.current_ceiling', '1', false);
SELECT set_config('app.current_clearance', 'MNPI,CONFIDENTIAL,CONTROLLED_SUBSTANCE', false);

SELECT COUNT(*), ARRAY_AGG(id ORDER BY id)
FROM knowledge_nodes;
```

Suresh should see all Supra rows but zero City Clinic rows.

---

## Step 5: Simulate City Clinic Doctor

```sql
SELECT set_config('app.current_org_id', 'city_clinic', false);
SELECT set_config('app.current_role', 'EDITOR', false);
SELECT set_config('app.current_department', 'medicine', false);
SELECT set_config('app.current_ceiling', '8', false);
SELECT set_config('app.current_clearance', '', false);

SELECT COUNT(*), ARRAY_AGG(id ORDER BY id)
FROM knowledge_nodes;
```

The City Clinic doctor should see only City Clinic rows.

This proves organization isolation.

---

## Step 6: Leak Checks

For any simulated user, run checks like:

```sql
SELECT
    COUNT(*) FILTER (WHERE org_id <> current_setting('app.current_org_id', true)) AS other_org_rows,
    COUNT(*) FILTER (WHERE compliance_tags && ARRAY['MNPI', 'CONFIDENTIAL']) AS restricted_compliance_rows
FROM knowledge_nodes;
```

For users without clearance, restricted compliance rows should be zero.

For cross-organization leakage, `other_org_rows` should always be zero.

---

## Step 7: RLS Disabled Comparison

Only for demonstration, and only in a safe demo database:

```sql
RESET ROLE;

ALTER TABLE knowledge_nodes DISABLE ROW LEVEL SECURITY;

SELECT COUNT(*)
FROM knowledge_nodes;

ALTER TABLE knowledge_nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE knowledge_nodes FORCE ROW LEVEL SECURITY;
```

When RLS is disabled, all seeded rows are visible to the table owner.

When RLS is enabled again and the role is switched to `authenticated`, user-specific filtering returns.

This proves RLS is the enforcement mechanism.

---

## Summary

The direct database proof shows:

* the same SQL query is used
* no application code filters data
* different simulated claims return different rows
* PostgreSQL silently excludes unauthorized rows
* organization isolation remains enforced
* compliance-sensitive records remain hidden without clearance
