# Submission Checklist

## Core Database

- [ ] `knowledge_nodes` table created
- [ ] 30 seed nodes loaded
- [ ] Supra Hospital has 25 nodes
- [ ] City Clinic has 5 nodes
- [ ] RLS enabled on `knowledge_nodes`
- [ ] RLS forced on `knowledge_nodes`
- [ ] Combined SELECT policy exists
- [ ] `authenticated` role has SELECT grant

## RLS Boundaries

- [ ] Organization isolation works
- [ ] Department scoping works
- [ ] Permission ceiling works
- [ ] Compliance filtering works
- [ ] Zone 2 bypasses department only
- [ ] Admin bypasses department and ceiling but not organization
- [ ] Compliance clearance is still required for sensitive records

## Demo Users

- [ ] Priya returns only safe Supra Ortho/global rows
- [ ] Vikram sees more than Priya but no MNPI/confidential rows
- [ ] Suresh sees Supra rows including sensitive records
- [ ] Suresh sees zero City Clinic rows
- [ ] Ananya sees Medicine/global rows only
- [ ] City Clinic Doctor sees zero Supra rows
- [ ] Ravi demonstrates surprise-user style behavior

## Application

- [ ] Server starts with `npm run dev`
- [ ] `/health` works
- [ ] `/api/users` works
- [ ] `/api/query/run` works
- [ ] `/api/policies` works
- [ ] Client starts with `npm run dev`
- [ ] Client build passes with `npm run build`
- [ ] Run All Users works
- [ ] Policy viewer displays active PostgreSQL policy

## Documentation

- [ ] `README.md` has setup instructions
- [ ] `docs/architecture.md` explains RLS design
- [ ] `docs/demo_script.md` explains Loom/live demo flow
- [ ] `docs/direct_db_proof.md` explains SQL Editor proof
- [ ] `data_sources.md` explains synthetic data sources
- [ ] `.env.example` files are present
- [ ] Real `.env` files are not committed

## GitHub

- [ ] Working tree clean
- [ ] Latest code pushed to GitHub
- [ ] Repo link opens correctly
- [ ] README displays correctly on GitHub