const express = require("express");
const cors = require("cors");
require("dotenv").config();

const { pool } = require("./db");
const { USERS } = require("./users");

const app = express();

app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 5000;

app.get("/health", (req, res) => {
    res.json({
        ok: true,
        service: "BRAHMO RLS Demo API",
    });
});

app.get("/api/users", (req, res) => {
    res.json({
        users: Object.values(USERS),
    });
});

app.post("/api/query/run", async (req, res) => {
    const { userId } = req.body;

    const user = USERS[userId];

    if (!user) {
        return res.status(400).json({
            error: "Unknown userId",
        });
    }

    const client = await pool.connect();

    try {
        await client.query("BEGIN");


        await client.query("SET LOCAL ROLE authenticated");

        await client.query("SELECT set_config('app.current_org_id', $1, true)", [
            user.orgId,
        ]);
        await client.query("SELECT set_config('app.current_role', $1, true)", [
            user.role,
        ]);
        await client.query(
            "SELECT set_config('app.current_department', $1, true)",
            [user.department]
        );
        await client.query("SELECT set_config('app.current_ceiling', $1, true)", [
            String(user.ceiling),
        ]);
        await client.query(
            "SELECT set_config('app.current_clearance', $1, true)",
            [user.clearance]
        );

        const result = await client.query(`
      SELECT
        id,
        org_id,
        type,
        title,
        content,
        hierarchy_level,
        department,
        zone,
        compliance_tags,
        status,
        created_at
      FROM knowledge_nodes
      ORDER BY id;
    `);

        await client.query("COMMIT");

        res.json({
            user,
            sql: "SELECT * FROM knowledge_nodes ORDER BY id;",
            count: result.rowCount,
            rows: result.rows,
        });
    } catch (error) {
        await client.query("ROLLBACK");

        console.error("RLS query failed:", error);

        res.status(500).json({
            error: "Failed to run RLS query",
            details: error.message,
        });
    } finally {
        client.release();
    }
});

app.get("/api/policies", async (req, res) => {
    try {
        const result = await pool.query(`
      SELECT
        policyname,
        cmd,
        roles,
        qual,
        with_check
      FROM pg_policies
      WHERE schemaname = 'public'
        AND tablename = 'knowledge_nodes'
      ORDER BY policyname;
    `);

        res.json({
            table: "knowledge_nodes",
            policies: result.rows,
        });
    } catch (error) {
        console.error("Failed to fetch RLS policies:", error);

        res.status(500).json({
            error: "Failed to fetch RLS policies",
            details: error.message,
        });
    }
});

app.listen(PORT, () => {
    console.log(`BRAHMO RLS Demo API running on port ${PORT}`);
});