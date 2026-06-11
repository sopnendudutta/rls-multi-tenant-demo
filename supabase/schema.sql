
-- Schema for  knowledge_nodes
-- Purpose is => 
--   Store clinical/organizational knowledge records that must be
--   protected by postgresql rls.



DROP TABLE IF EXISTS knowledge_nodes CASCADE;

CREATE TABLE knowledge_nodes (
    id TEXT PRIMARY KEY,


    org_id TEXT NOT NULL,

    -- Knowledge node 
    type TEXT NOT NULL CHECK (
        type IN ('CONSTRAINT', 'DECISION', 'ANTI_PATTERN', 'FACT')
    ),

    title TEXT NOT NULL,
    content TEXT NOT NULL,

    -- Lower number = higher privilege / more sensitive
    
    -- 1 = admin/board level
    -- 4 = HOD level
    -- 10 = ward/viewer level
    -- 12 = patient/ward staff level
    hierarchy_level INTEGER NOT NULL CHECK (hierarchy_level >= 1),

    
    department TEXT,

    -- 1 = normal addressed/local node
    -- 2 = global node that can bypass department scoping
    zone INTEGER NOT NULL DEFAULT 1 CHECK (zone IN (1, 2)),

    -- Example: {'MNPI', 'CONFIDENTIAL'}
    compliance_tags TEXT[] NOT NULL DEFAULT '{}',

    status TEXT NOT NULL DEFAULT 'ACTIVE' CHECK (
        status IN ('ACTIVE', 'ARCHIVED')
    ),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for RLS performance
-- RLS policies behave like automatic WHERE conditions, so these
-- columns should be indexed.


CREATE INDEX idx_nodes_org
ON knowledge_nodes(org_id);

CREATE INDEX idx_nodes_department
ON knowledge_nodes(department);

CREATE INDEX idx_nodes_hierarchy_level
ON knowledge_nodes(hierarchy_level);

CREATE INDEX idx_nodes_zone
ON knowledge_nodes(zone);

CREATE INDEX idx_nodes_status
ON knowledge_nodes(status);

CREATE INDEX idx_nodes_compliance_tags
ON knowledge_nodes USING GIN(compliance_tags);

-- Composite indexes for common RLS filtering paths
CREATE INDEX idx_nodes_org_department
ON knowledge_nodes(org_id, department);

CREATE INDEX idx_nodes_org_hierarchy
ON knowledge_nodes(org_id, hierarchy_level);

CREATE INDEX idx_nodes_org_dept_hierarchy
ON knowledge_nodes(org_id, department, hierarchy_level);