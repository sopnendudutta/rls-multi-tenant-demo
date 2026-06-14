import { useEffect, useMemo, useState } from "react";
import "./App.css";

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:5000";

function App() {
  const [users, setUsers] = useState([]);
  const [results, setResults] = useState({});
  const [selectedResult, setSelectedResult] = useState(null);
  const [loadingUserId, setLoadingUserId] = useState(null);
  const [error, setError] = useState("");

  const orderedResults = useMemo(() => {
    return users
      .map((user) => results[user.id])
      .filter(Boolean);
  }, [users, results]);

  useEffect(() => {
    async function loadUsers() {
      try {
        const response = await fetch(`${API_URL}/api/users`);

        if (!response.ok) {
          throw new Error("Failed to load users");
        }

        const data = await response.json();
        setUsers(data.users || []);
      } catch (err) {
        setError(err.message);
      }
    }

    loadUsers();
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

  return (
    <main className="page-shell">
      <section className="hero">
        <div>
          <p className="eyebrow">BRAHMO RLS Assessment</p>
          <h1>Database-Enforced Multi-Tenant Isolation</h1>
          <p className="hero-text">
            This demo proves that PostgreSQL Row-Level Security silently filters
            healthcare knowledge nodes before the application receives them.
          </p>
        </div>

        <div className="query-box">
          <span>Same SQL for every user</span>
          <code>SELECT * FROM knowledge_nodes ORDER BY id;</code>
        </div>
      </section>

      {error && <div className="error-box">{error}</div>}

      <section className="section-card">
        <div className="section-heading">
          <div>
            <h2>Run the same query as different users</h2>
            <p>
              The frontend does not filter rows. Counts below come directly from
              PostgreSQL RLS.
            </p>
          </div>

          <button
            className="primary-button"
            onClick={runAllQueries}
            disabled={loadingUserId !== null || users.length === 0}
          >
            {loadingUserId ? "Running..." : "Run All Users"}
          </button>
        </div>

        <div className="user-grid">
          {users.map((user) => {
            const result = results[user.id];

            return (
              <article className="user-card" key={user.id}>
                <div>
                  <h3>{user.name}</h3>
                  <p>{user.description}</p>
                </div>

                <div className="claim-list">
                  <span>Org: {user.orgId}</span>
                  <span>Role: {user.role}</span>
                  <span>Dept: {user.department}</span>
                  <span>Ceiling: L{user.ceiling}</span>
                  <span>
                    Clearance: {user.clearance ? user.clearance : "none"}
                  </span>
                </div>

                <div className="card-footer">
                  <strong>{result ? `${result.count} rows` : "Not run"}</strong>

                  <button
                    onClick={() => runQueryForUser(user.id)}
                    disabled={loadingUserId !== null}
                  >
                    {loadingUserId === user.id ? "Running..." : "Run Query"}
                  </button>
                </div>
              </article>
            );
          })}
        </div>
      </section>

      {orderedResults.length > 0 && (
        <section className="section-card">
          <div className="section-heading">
            <div>
              <h2>Same-query comparison</h2>
              <p>
                Different counts prove that PostgreSQL is applying user-specific
                RLS policies.
              </p>
            </div>
          </div>

          <div className="comparison-grid">
            {orderedResults.map((result) => (
              <button
                className="comparison-card"
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
        <section className="section-card">
          <div className="section-heading">
            <div>
              <h2>{selectedResult.user.name} result set</h2>
              <p>
                Silent exclusion: no hidden count, no access denied message, no
                restricted-row hints.
              </p>
            </div>

            <div className="count-badge">{selectedResult.count} rows</div>
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

      <section className="proof-strip">
        <div>
          <strong>Proof 1</strong>
          <span>Same SQL, different users, different rows.</span>
        </div>
        <div>
          <strong>Proof 2</strong>
          <span>Frontend does not filter restricted records.</span>
        </div>
        <div>
          <strong>Proof 3</strong>
          <span>PostgreSQL RLS silently excludes unauthorized rows.</span>
        </div>
      </section>
    </main>
  );
}

export default App;