-- Seed Data: knowledge_nodes
-- 30 nodes across 2 organizations
--
-- Supra Hospital: 25 nodes
-- City Clinic: 5 nodes


INSERT INTO knowledge_nodes (
    id,
    org_id,
    type,
    title,
    content,
    hierarchy_level,
    department,
    zone,
    compliance_tags
) VALUES


-- SUPRA HOSPITAL — ZONE 2 GLOBALS
-- These bypass department scoping only.
-- They still obey org isolation, hierarchy ceiling, and compliance.


(
    'S-G01',
    'supra',
    'CONSTRAINT',
    'Warfarin-NSAID Never Combine',
    'CRITICAL: Never prescribe NSAIDs to patients on Warfarin. GI bleed risk.',
    10,
    NULL,
    2,
    '{}'
),
(
    'S-G02',
    'supra',
    'CONSTRAINT',
    'Two-Person Transfusion Verification',
    'All blood transfusions require two-person verification.',
    10,
    NULL,
    2,
    '{}'
),
(
    'S-G03',
    'supra',
    'CONSTRAINT',
    'Hand Hygiene 5-Moment',
    'WHO 5-moment hand hygiene. Supra target 95%.',
    10,
    NULL,
    2,
    '{}'
),
(
    'S-G04',
    'supra',
    'FACT',
    'Emergency Codes',
    'Blue=arrest, Red=fire, Pink=abduction, Grey=combative.',
    10,
    NULL,
    2,
    '{}'
),

-- Zone 2 but confidential.
-- This proves Zone 2 does NOT bypass compliance.
(
    'S-G05',
    'supra',
    'DECISION',
    'Hospital Expansion Plan Confidential',
    'Board-approved: 80 beds by Q4 2027. Investment planning is confidential.',
    1,
    NULL,
    2,
    '{"MNPI","CONFIDENTIAL"}'
),

-- Zone 2 but high hierarchy sensitivity.
-- This proves Zone 2 does NOT bypass permission ceiling.
(
    'S-G06',
    'supra',
    'DECISION',
    'Department Budget Allocation Formula',
    'Budget formula: 45% implants, 30% staff, 15% equipment, 10% training.',
    4,
    NULL,
    2,
    '{}'
),


-- SUPRA HOSPITAL — ORTHOPAEDICS


(
    'S-O01',
    'supra',
    'DECISION',
    'Paracetamol First-Line Post-TKR',
    'Paracetamol 650mg QDS. Escalate to Tramadol if VAS score is greater than 6.',
    8,
    'ortho',
    1,
    '{}'
),
(
    'S-O02',
    'supra',
    'CONSTRAINT',
    'DVT Prophylaxis All Surgical',
    'Enoxaparin 40mg SC daily. TKR 14 days, THR 28 days.',
    5,
    'ortho',
    1,
    '{}'
),
(
    'S-O03',
    'supra',
    'ANTI_PATTERN',
    'Never Discharge TKR Under 48h',
    'Past DVT incident after 36-hour discharge. Minimum observation required.',
    5,
    'ortho',
    1,
    '{}'
),
(
    'S-O04',
    'supra',
    'FACT',
    'Ortho Ward 45 Beds',
    'Ortho Ward has 45 beds. Overflow goes to Medicine during winter.',
    10,
    'ortho',
    1,
    '{}'
),
(
    'S-O05',
    'supra',
    'FACT',
    'Ortho Nurse Ratio 1:6',
    'Day nurse ratio is 1:6, night ratio is 1:8, post-op ratio is 1:4.',
    10,
    'ortho',
    1,
    '{}'
),
(
    'S-O06',
    'supra',
    'DECISION',
    'Zimmer Biomet Implant Preference',
    'Zimmer preferred. Smith & Nephew for revisions only.',
    5,
    'ortho',
    1,
    '{}'
),

-- Ortho HOD-level sensitive nodes
(
    'S-O07',
    'supra',
    'DECISION',
    'Ortho Budget 2026',
    'FY 2026 ortho budget planning for implants, staffing, and arthroscopy.',
    4,
    'ortho',
    1,
    '{"MNPI"}'
),
(
    'S-O08',
    'supra',
    'DECISION',
    'Vendor Negotiation Zimmer',
    'Renegotiate July 2026. Target discount on high-volume implant purchases.',
    4,
    'ortho',
    1,
    '{"MNPI","CONFIDENTIAL"}'
),


-- SUPRA HOSPITAL — GENERAL MEDICINE


(
    'S-M01',
    'supra',
    'DECISION',
    'Sepsis Protocol v3 2026',
    'Lactate within 1 hour. Pip-Tazo empiric protocol.',
    5,
    'medicine',
    1,
    '{}'
),
(
    'S-M02',
    'supra',
    'CONSTRAINT',
    'Diabetic Fasting Protocol',
    'Adjust insulin timing, not dose. Skip Glimepiride on fasting days.',
    5,
    'medicine',
    1,
    '{}'
),
(
    'S-M03',
    'supra',
    'ANTI_PATTERN',
    'Sliding Scale Alone Bad',
    'Never use sliding scale alone. Always use basal insulin.',
    8,
    'medicine',
    1,
    '{}'
),
(
    'S-M04',
    'supra',
    'FACT',
    'Medicine Specialty Clinics',
    'DM Mon/Wed, HTN Tue/Thu, Respiratory Fri.',
    10,
    'medicine',
    1,
    '{}'
),


-- SUPRA HOSPITAL — CARDIOLOGY


(
    'S-C01',
    'supra',
    'CONSTRAINT',
    'Cardiac Cath Consent 4 Hours',
    'Written consent minimum 4 hours before catheterization.',
    5,
    'cardiology',
    1,
    '{}'
),
(
    'S-C02',
    'supra',
    'DECISION',
    'CCU Troponin Serial Protocol',
    'hs-cTnI at 0, 3, and 6 hours. Early rule-out at 1 hour if less than 5.',
    8,
    'cardiology',
    1,
    '{}'
),
(
    'S-C03',
    'supra',
    'FACT',
    'ATOM-2026 Trial Confidential',
    'Atorvastatin optimization trial. 50 patients. Principal investigator: Dr. Mehta.',
    5,
    'cardiology',
    1,
    '{"MNPI","CONFIDENTIAL"}'
),


-- SUPRA HOSPITAL — ADMIN / HOSPITAL-WIDE


(
    'S-A01',
    'supra',
    'DECISION',
    'Staff Salary Restructuring',
    'Nurses and technicians salary restructuring plan effective July 2026.',
    1,
    NULL,
    1,
    '{"MNPI","CONFIDENTIAL"}'
),
(
    'S-A02',
    'supra',
    'FACT',
    'NABH Accreditation Status',
    'Valid until March 2027. Gap: medication error reporting is below target.',
    3,
    NULL,
    1,
    '{}'
),


-- SUPRA HOSPITAL — PATIENT / WARD LEVEL


(
    'S-P01',
    'supra',
    'CONSTRAINT',
    'Patient Rajan: No NSAIDs',
    'Absolute contraindication. Cardiac stent plus Warfarin.',
    12,
    'ortho',
    1,
    '{}'
),

-- Extra node added to make the seed dataset exactly 30 rows.
-- Also useful for surprise-user testing with a pharmacist profile.

(
    'S-PH01',
    'supra',
    'CONSTRAINT',
    'Controlled Substance Storage Protocol',
    'Controlled substances must be double-locked and logged during every handoff.',
    12,
    'pharmacy',
    1,
    '{"CONTROLLED_SUBSTANCE"}'
),


-- CITY CLINIC — SEPARATE ORGANIZATION
-- These must never be visible to Supra users.


(
    'CC-01',
    'city_clinic',
    'CONSTRAINT',
    'Hand Hygiene Policy',
    'Alcohol-based handrub mandatory before patient contact.',
    8,
    NULL,
    2,
    '{}'
),
(
    'CC-02',
    'city_clinic',
    'DECISION',
    'Paracetamol Dosing',
    'Adults: 500mg QDS max. Children: weight-based dosing.',
    8,
    'medicine',
    1,
    '{}'
),
(
    'CC-03',
    'city_clinic',
    'FACT',
    'Clinic Hours',
    'Mon-Sat 8am-8pm. Sunday emergency only.',
    10,
    NULL,
    1,
    '{}'
),
(
    'CC-04',
    'city_clinic',
    'DECISION',
    'Referral Policy',
    'Refer to district hospital for any surgical case.',
    8,
    'medicine',
    1,
    '{}'
),
(
    'CC-05',
    'city_clinic',
    'FACT',
    'Staff Count',
    '2 doctors, 4 nurses, 1 pharmacist, 1 lab technician.',
    10,
    NULL,
    1,
    '{}'
);