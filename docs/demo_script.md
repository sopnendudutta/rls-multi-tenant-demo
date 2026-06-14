# Loom / Live Demo Script

## 1. Opening

This project demonstrates database-enforced multi-tenant security using PostgreSQL Row-Level Security.

The goal is to prove that the application is not responsible for filtering restricted healthcare knowledge records. PostgreSQL filters unauthorized rows before they leave the database.

The same SQL query is used for every user:

```sql
SELECT * FROM knowledge_nodes ORDER BY id;
```

Different users receive different rows because PostgreSQL reads their simulated JWT claims and applies RLS policies.

---

## 2. Architecture Summary

The protected table is:

```sql
knowledge_nodes
```

Each knowledge node contains:

* organization id
* department
* hierarchy level
* zone
* compliance tags

Each simulated user has claims:

* organization
* role
* department
* permission ceiling
* compliance clearance

The Express server does not filter restricted rows. It only sets simulated user claims for the database transaction and runs the same SQL query.

The React client only displays what the database returns.

---

## 3. Four RLS Boundaries

There are four isolation boundaries.

### Boundary 1: Organization Isolation

A user can only see rows from their own organization.

For example, a City Clinic doctor must see zero Supra Hospital rows.

Even an admin cannot bypass organization isolation.

### Boundary 2: Department Scoping

A user can see:

* their own department
* hospital-wide rows where department is null
* Zone 2 global rows

Admin users can see all departments inside their own organization.

### Boundary 3: Permission Ceiling

The hierarchy level controls seniority.

Lower numbers are more sensitive.

For example:

* Level 1 is admin or board level
* Level 4 is HOD level
* Level 10 is ward or viewer level

A viewer with ceiling level 10 cannot see level 4 HOD decisions.

HOD and ADMIN roles bypass this ceiling.

### Boundary 4: Compliance Filtering

Sensitive rows can have tags like:

* MNPI
* CONFIDENTIAL
* CONTROLLED_SUBSTANCE

A row with compliance tags is visible only if the user has all required clearances.

---

## 4. Same Query, Different Results

Now I will run the same query for multiple users.

The query is:

```sql
SELECT * FROM knowledge_nodes ORDER BY id;
```

When I click "Run All Users", each user receives a different result count.

This proves that the database is applying user-specific RLS policies.

The frontend is not filtering rows. It only displays the database response.

---

## 5. User Examples

### Nurse Priya

Priya is a Supra Hospital Ortho viewer with ceiling level 10 and no compliance clearance.

She should only see safe Ortho, hospital-wide, and Zone 2 rows that pass her hierarchy and compliance checks.

She should not see:

* City Clinic rows
* Medicine or Cardiology department rows
* HOD or admin-level decisions
* MNPI or confidential records

### Dr. Vikram

Vikram is a Supra Hospital Ortho HOD.

He can see more than Priya because HOD bypasses the permission ceiling.

But he still cannot see:

* City Clinic rows
* unrelated departments
* MNPI or confidential records without clearance

### Admin Suresh

Suresh is a Supra admin with compliance clearance.

He can see all Supra rows, including sensitive rows.

But he still cannot see City Clinic rows.

This proves that admin does not bypass organization isolation.

### City Clinic Doctor

The City Clinic doctor can only see City Clinic rows.

This proves multi-tenant isolation.

---

## 6. Silent Exclusion

The system does not return access denied errors.

It does not return hidden row counts.

It does not show placeholders for restricted records.

Unauthorized rows simply do not appear.

From the user’s perspective, the result set looks complete.

---

## 7. Active Policy Viewer

The app also displays the active PostgreSQL RLS policy from database metadata.

This shows that the rule is actually stored and enforced inside PostgreSQL.

The policy combines:

* organization isolation
* department scoping
* permission ceiling
* compliance filtering

using AND logic.

---

## 8. Why One Combined Policy

PostgreSQL permissive RLS policies are OR-combined by default.

Because this assessment requires all four boundaries to pass together, I used one combined SELECT policy with explicit AND conditions.

This avoids accidentally widening access.

---

## 9. Direct Database Proof

The SQL test file can also be run directly inside Supabase SQL Editor.

It switches to the authenticated role, sets simulated user claims, and runs the same SELECT query.

This proves that the security is enforced at the database layer, not only through the application.

---

## 10. Zone 2 Edge Case

Zone 2 rows are global organization-wide rows.

They bypass department scoping only.

They do not bypass:

* organization isolation
* permission ceiling
* compliance filtering

So a safe global policy can be visible across departments, but a confidential Zone 2 record remains hidden unless the user has clearance.

---

## 11. Performance Note

RLS policies behave like automatic WHERE clauses.

The table includes indexes on:

* org_id
* department
* hierarchy_level
* zone
* status
* compliance_tags

There are also composite indexes for common filtering paths.

At larger scale, the org_id index reduces the search space first, then department, hierarchy, and compliance indexes help narrow the result set further.

---

## 12. Closing

This project demonstrates that PostgreSQL is the security boundary.

The same query returns different rows for different users.

No unauthorized rows reach the application.

That is the core proof of database-enforced multi-tenant isolation.
