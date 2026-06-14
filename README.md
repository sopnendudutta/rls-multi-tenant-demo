# BRAHMO RLS Multi-Tenant Demo

A PostgreSQL Row-Level Security demo for enforcing multi-tenant healthcare knowledge isolation at the database layer.

## Core Idea

The same SQL query:

```sql
SELECT * FROM knowledge_nodes ORDER BY id;
```

returns different rows for different users based on simulated JWT claims.

The application does not filter restricted data. PostgreSQL Row-Level Security silently excludes unauthorized rows before they leave the database.

## What This Demonstrates

This project enforces four isolation boundaries:

1. **Organization Isolation**
   Users can only see rows from their own organization.

2. **Department Scoping**
   Users can see their own department, hospital-wide rows, and Zone 2 global rows.

3. **Permission Ceiling**
   Junior users cannot see higher-privilege knowledge nodes.

4. **Compliance Filtering**
   Sensitive rows tagged with values like `MNPI`, `CONFIDENTIAL`, or `CONTROLLED_SUBSTANCE` require matching clearance.

## Silent Exclusion

Unauthorized rows are not returned with errors, warnings, hidden counts, or placeholders.

From the user's perspective, the visible rows look like the complete dataset.

## Tech Stack

* Supabase PostgreSQL
* PostgreSQL Row-Level Security
* Node.js
* Express
* React
* Vite
* CSS

## Project Structure

```txt
rls-multi-tenant-demo/
├── README.md
├── data_sources.md
├── docs/
│   └── architecture.md
├── supabase/
│   ├── schema.sql
│   ├── seed.sql
│   ├── rls_policies.sql
│   └── test_queries.sql
├── server/
│   ├── index.js
│   ├── db.js
│   ├── users.js
│   └── .env.example
└── client/
    ├── src/
    │   ├── App.jsx
    │   └── App.css
    └── .env.example
```

## Supabase Setup

Create a Supabase project, then run the SQL files in this exact order:

```txt
1. supabase/schema.sql
2. supabase/seed.sql
3. supabase/rls_policies.sql
4. supabase/test_queries.sql
```

The seed data must be loaded before enabling RLS policies.

## Expected Seed Data

The demo uses 30 knowledge nodes:

```txt
Supra Hospital: 25 nodes
City Clinic: 5 nodes
```

These rows are enough to prove organization isolation, department scoping, permission ceiling, compliance filtering, Zone 2 behavior, and silent exclusion.

## Server Setup

Go to the server folder:

```bash
cd server
npm install
```

Create `server/.env`:

```env
PORT=5000
DATABASE_URL=your_supabase_postgres_connection_string
```

Run the server:

```bash
npm run dev
```

Health check:

```txt
http://localhost:5000/health
```

## Client Setup

Go to the client folder:

```bash
cd client
npm install
```

Create `client/.env`:

```env
VITE_API_URL=http://localhost:5000
```

Run the client:

```bash
npm run dev
```

Open:

```txt
http://localhost:5173
```

## Demo Flow

1. Start the server.
2. Start the client.
3. Click **Run All Users**.
4. Observe that the same SQL query returns different row counts.
5. Click any user result to inspect the exact rows returned by PostgreSQL.
6. Verify that restricted rows are silently excluded.

## Test Users

| User               | Organization | Role   | Department | Ceiling | Clearance                                |
| ------------------ | ------------ | ------ | ---------- | ------: | ---------------------------------------- |
| Nurse Priya        | supra        | VIEWER | ortho      |      10 | none                                     |
| Dr. Vikram         | supra        | HOD    | ortho      |       4 | none                                     |
| Admin Suresh       | supra        | ADMIN  | admin      |       1 | MNPI, CONFIDENTIAL, CONTROLLED_SUBSTANCE |
| Dr. Ananya         | supra        | EDITOR | medicine   |       8 | none                                     |
| City Clinic Doctor | city_clinic  | EDITOR | medicine   |       8 | none                                     |
| Pharmacist Ravi    | supra        | VIEWER | pharmacy   |      12 | CONTROLLED_SUBSTANCE                     |

## Important RLS Design Choice

The implementation uses one combined `SELECT` policy instead of four separate permissive policies.

Reason: PostgreSQL combines permissive RLS policies using OR logic by default. This assessment requires all four isolation boundaries to pass together, so the policy uses explicit AND logic in one auditable policy.

## Main Proof

Same SQL:

```sql
SELECT * FROM knowledge_nodes ORDER BY id;
```

Different simulated user claims.

Different rows returned.

No application-level filtering.

PostgreSQL is the security layer.
