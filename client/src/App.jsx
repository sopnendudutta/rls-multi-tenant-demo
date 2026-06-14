import { useEffect, useMemo, useState } from "react";
import "./App.css";

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:5000";

function App() {
  const [users, setUsers] = useState([]);
  const [results, setResults] = useState({});
  const [selectedResult, setSelectedResult] = useState(null);
  const [loadingUserId, setLoadingUserId] = useState(null);
  const [error, setError] = useState("");
  const [policies, setPolicies] = useState([]);

  const orderedResults = useMemo(() => {
    return users.map((user) => results[user.id]).filter(Boolean);
  }, [users, results]);

  useEffect(() => {
    async function loadUsers() {
      const response = await fetch(`${API_URL}/api/users`);

      if (!response.ok) {
        throw new Error("Failed to load users");
      }

      const data = await response.json();
      setUsers(data.users || []);
    }

    async function loadPolicies() {
      const response = await fetch(`${API_URL}/api/policies`);

      if (!response.ok) {
        throw new Error("Failed to load RLS policies");
      }

      const data = await response.json();
      setPolicies(data.policies || []);
    }

    async function loadInitialData() {
      try {
        setError("");
        await loadUsers();
        await loadPolicies();
      } catch (err) {
        setError(err.message);
      }
    }

    loadInitialData();
  }, []);

  async function runQueryForUser(userId) {
    setError("");
    setLoadingUserId(userId);

    try {
      const response = await fetch(`${API_URL}/api/query/run`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ userId }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.details || data.error || "Query failed");
      }

      setResults((current) => ({
        ...current,
        [userId]: data,
      }));

      setSelectedResult(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoadingUserId(null);
    }
  }

  async function runAllQueries() {
    setError("");

    for (const user of users) {
      await runQueryForUser(user.id);
    }
  }

  function formatRoles(roles) {
    if (Array.isArray(roles)) {
      return roles.join(", ");
    }

    if (typeof roles === "string") {
      return roles;
    }

    return "public";
  }

  return (
    <main className="app">
      <section className="hero-screen">
        <div className="hero-content">
          <p className="eyebrow">BRAHMO </p>

          <h1>PostgreSQL is the security layer.</h1>





          <div className="hero-actions">
            <button
              className="primary-button"
              onClick={runAllQueries}
              disabled={loadingUserId !== null || users.length === 0}
            >
              {loadingUserId ? "Running RLS checks..." : "Run All Users"}
            </button>

            <span className="silent-note">
              Silent exclusion: no access denied errors, no hidden counts.
            </span>
          </div>
        </div>
      </section>

      {error && <div className="error-banner">{error}</div>}

      <section className="full-section">


        <div className="user-list">
          {users.map((user) => {
            const result = results[user.id];

            return (
              <div className="user-row" key={user.id}>
                <div className="user-main">
                  <h3>{user.name}</h3>
                  <p>{user.description}</p>
                </div>

                <div className="claims-simple">
                  <div>
                    <span>Organization</span>
                    <strong>{user.orgId}</strong>
                  </div>

                  <div>
                    <span>Role</span>
                    <strong>{user.role}</strong>
                  </div>

                  <div>
                    <span>Department</span>
                    <strong>{user.department}</strong>
                  </div>

                  <div>
                    <span>Ceiling</span>
                    <strong>L{user.ceiling}</strong>
                  </div>

                  <div>
                    <span>Clearance</span>
                    <strong>{user.clearance ? user.clearance : "none"}</strong>
                  </div>
                </div>

                <div className="row-action">
                  <strong>{result ? `${result.count} rows` : "Not run"}</strong>
                  <button
                    onClick={() => runQueryForUser(user.id)}
                    disabled={loadingUserId !== null}
                  >
                    {loadingUserId === user.id ? "Running..." : "Run"}
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      </section>

      {orderedResults.length > 0 && (
        <section className="full-section dark-section">
          <div className="section-header">
            <p className="eyebrow">Core Proof</p>
            <h2>Same query, different users, different rows</h2>
            <p>
              Different counts prove the database is enforcing isolation using
              user claims.
            </p>
          </div>

          <div className="comparison-table">
            {orderedResults.map((result) => (
              <button
                className="comparison-row"
                key={result.user.id}
                onClick={() => setSelectedResult(result)}
              >
                <span>{result.user.name}</span>
                <strong>{result.count}</strong>
                <small>visible rows</small>
              </button>
            ))}
          </div>
        </section>
      )}

      {selectedResult && (
        <section className="full-section">
          <div className="section-header result-header">
            <div>
              <p className="eyebrow">Returned by PostgreSQL</p>
              <h2>{selectedResult.user.name} result set</h2>
              <p>
                This is the complete result from the user’s perspective. Hidden
                rows are silently excluded by RLS.
              </p>
            </div>

            <div className="big-count">
              <strong>{selectedResult.count}</strong>
              <span>visible rows</span>
            </div>
          </div>

          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Org</th>
                  <th>Type</th>
                  <th>Title</th>
                  <th>Dept</th>
                  <th>Level</th>
                  <th>Zone</th>
                  <th>Compliance</th>
                </tr>
              </thead>

              <tbody>
                {selectedResult.rows.map((row) => (
                  <tr key={row.id}>
                    <td>{row.id}</td>
                    <td>{row.org_id}</td>
                    <td>{row.type}</td>
                    <td>{row.title}</td>
                    <td>{row.department || "hospital-wide"}</td>
                    <td>L{row.hierarchy_level}</td>
                    <td>{row.zone}</td>
                    <td>
                      {row.compliance_tags?.length
                        ? row.compliance_tags.join(", ")
                        : "none"}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      )}

      <section className="full-section policy-section">
        <div className="section-header">
          <p className="eyebrow">Active PostgreSQL Policy</p>
          <h2>RLS policy enforced on knowledge_nodes</h2>
          <p>
            This policy is read from PostgreSQL system metadata. It shows the
            database rule responsible for silently excluding unauthorized rows.
          </p>
        </div>

        <div className="policy-list">
          {policies.length === 0 ? (
            <p>No policies loaded yet.</p>
          ) : (
            policies.map((policy) => (
              <div className="policy-block" key={policy.policyname}>
                <div className="policy-meta">
                  <strong>{policy.policyname}</strong>
                  <span>Command: {policy.cmd}</span>
                  <span>Roles: {formatRoles(policy.roles)}</span>
                </div>

                <pre>{policy.qual}</pre>
              </div>
            ))
          )}
        </div>
      </section>

      <section className="proof-band">
        <div>
          <strong>Organization Isolation</strong>
          <span>City Clinic users see zero Supra rows.</span>
        </div>
        <div>
          <strong>Department Scoping</strong>
          <span>Users see own department, hospital-wide, and Zone 2 rows.</span>
        </div>
        <div>
          <strong>Permission Ceiling</strong>
          <span>Junior users cannot see HOD/admin-level records.</span>
        </div>
        <div>
          <strong>Compliance Filtering</strong>
          <span>MNPI/confidential rows require matching clearance.</span>
        </div>
      </section>
    </main>
  );
}

export default App;