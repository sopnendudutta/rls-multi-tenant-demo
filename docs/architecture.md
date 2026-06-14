# Architecture Notes

## Goal

This project demonstrates database-enforced security for healthcare knowledge infrastructure.

The main goal is to prove that PostgreSQL Row-Level Security can prevent unauthorized data access even when the application layer does not perform filtering.

## Protected Resource

The protected table is:

```sql
knowledge_nodes
```

Each row represents one piece of clinical or organizational knowledge.

Examples include:

* Drug safety constraints
* Department protocols
* Hospital-wide policies
* Budget or vendor decisions
* Patient-related restrictions
* Compliance-sensitive records

## Security Model

Each simulated user has claims similar to JWT app metadata:

```txt
org_id
role
department
ceiling_level
compliance_clearance
```

The database reads these simulated claims using PostgreSQL session settings:

```sql
current_setting('app.current_org_id', true)
current_setting('app.current_role', true)
current_setting('app.current_department', true)
current_setting('app.current_ceiling', true)
current_setting('app.current_clearance', true)
```

In production, these values could be replaced with real JWT claim extraction, such as Supabase Auth or Clerk app metadata.

## Four Isolation Boundaries

### 1. Organization Isolation

A user can only see rows where:

```sql
org_id = current_user_org_id
```

This is the absolute tenant boundary.

Admin users do not bypass organization isolation.

Example:

A City Clinic doctor must never see Supra Hospital rows.

### 2. Department Scoping

A user can see:

```txt
their own department
hospital-wide rows where department IS NULL
Zone 2 global rows
```

Admin users can see all departments inside their organization.

Zone 2 only bypasses department scoping. It does not bypass organization isolation, hierarchy ceiling, or compliance filtering.

### 3. Permission Ceiling

The hierarchy model uses lower numbers for higher privilege.

Example:

```txt
Level 1  = admin / board level
Level 4  = HOD level
Level 10 = ward / viewer level
Level 12 = patient or ward-level access
```

Normal users can see rows where:

```sql
hierarchy_level >= user_ceiling_level
```

HOD and ADMIN roles bypass this ceiling.

### 4. Compliance Filtering

Rows with no compliance tags are visible after the other boundaries pass.

Rows with compliance tags require the user's clearance to include all row tags.

Example:

```txt
row tags: MNPI, CONFIDENTIAL
user clearance: MNPI
result: hidden
```

The row is hidden because the user does not have CONFIDENTIAL clearance.

## Silent Exclusion

Unauthorized rows are silently excluded.

The system does not return:

```txt
access denied messages
hidden row counts
restricted row placeholders
partial metadata leaks
```

The user only receives the rows PostgreSQL allows them to see.

## Why One Combined RLS Policy?

PostgreSQL permissive RLS policies are OR-combined by default.

This assessment requires AND-style enforcement:

```txt
organization isolation
AND department scoping
AND permission ceiling
AND compliance filtering
```

To avoid accidental policy widening, this project uses one combined `SELECT` policy:

```sql
CREATE POLICY knowledge_nodes_select_policy
ON knowledge_nodes
FOR SELECT
USING (
  status = 'ACTIVE'
  AND org condition
  AND department condition
  AND ceiling condition
  AND compliance condition
);
```

This makes the policy easier to audit and safer for the demo.

## Application Role

The Express server does not filter restricted rows.

The server only:

1. Receives a user id.
2. Sets simulated user claims for the database transaction.
3. Switches to the `authenticated` role.
4. Runs the same SQL query.
5. Returns whatever PostgreSQL returns.

The frontend only displays returned data.

## Same Query Proof

Every simulated user runs:

```sql
SELECT * FROM knowledge_nodes ORDER BY id;
```

The different results come from PostgreSQL RLS, not from application branching.

## Direct Database Proof

The SQL test file can run similar checks directly in Supabase SQL Editor.

This proves the security model is database-enforced rather than application-enforced.

## Zone 2 Edge Case

Zone 2 global rows are designed to be visible across departments within the same organization.

However, Zone 2 rows still pass through:

```txt
organization isolation
permission ceiling
compliance filtering
```

This prevents global confidential or HOD-level records from leaking to junior users.

## Admin Behavior

Admin users can bypass:

```txt
department scoping
permission ceiling
```

Admin users cannot bypass:

```txt
organization isolation
compliance filtering unless they have matching clearance
```

This means a Supra admin cannot see City Clinic records.

## Performance Notes

RLS policies act like automatic `WHERE` clauses.

Indexes are added for RLS-filtered columns:

```sql
org_id
department
hierarchy_level
zone
status
compliance_tags
```

Composite indexes are also included for common filtering paths:

```sql
(org_id, department)
(org_id, hierarchy_level)
(org_id, department, hierarchy_level)
```

A GIN index is used for array-based compliance tag checks.

## Multi-Department Node Strategy

The current assessment schema uses one `department` column.

For production, multi-department records could be handled using one of these designs:

1. `departments TEXT[]` with array overlap checks.
2. A `node_departments` junction table.
3. Zone 2 for truly organization-wide knowledge.

Recommended production approach:

Use a `node_departments` junction table for precise many-to-many modeling. Use Zone 2 only for genuinely global organization-wide knowledge.

## RLS and Grants

RLS controls which rows are visible.

GRANT controls whether a database role can access the table at all.

Both are required.

This project grants SELECT to the `authenticated` role and lets RLS decide which rows are visible.

## Security Summary

The application never receives unauthorized rows.

The database is the security boundary.

Same SQL, different claims, different rows.
