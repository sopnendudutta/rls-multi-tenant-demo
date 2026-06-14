# Data Sources

## Overview

This demo uses synthetic assessment data for a Row-Level Security implementation.

No real patient records, real hospital data, or protected health information are used.

## Source 1: BRAHMO Assessment Setup Guide

Most seed records are based on the sample seed data provided in the assessment setup guide.

These records include synthetic examples for:

* Supra Hospital
* City Clinic
* Orthopaedics
* General Medicine
* Cardiology
* Hospital-wide policies
* Compliance-sensitive records
* Zone 2 global knowledge nodes

The data is used only to demonstrate RLS behavior.

## Source 2: Synthetic Demo Adjustments

Some values were adjusted for clearer demonstration of RLS boundaries.

Examples:

* Zone 2 global safety records were set to a ward-visible hierarchy level so viewer-level users can see safe global policies.
* Confidential Zone 2 records remain restricted by hierarchy and compliance.
* City Clinic rows were adjusted to ensure the City Clinic user has visible records for the demo.
* One synthetic pharmacy-related node was added to support a surprise-style user test.

## Added Synthetic Node

The following node was added for RLS edge-case testing:

```txt
S-PH01: Controlled Substance Storage Protocol
```

Purpose:

* Demonstrates a pharmacy department user.
* Demonstrates `CONTROLLED_SUBSTANCE` compliance clearance.
* Helps test a surprise-user scenario without changing RLS policy code.

## Clinical Accuracy Note

The clinical examples in this project are simplified and synthetic.

They are not intended for real clinical decision-making.

They exist only to test:

```txt
organization isolation
department scoping
permission ceiling
compliance filtering
silent exclusion
```

## Privacy Note

This dataset contains no real patient identifiers and no real protected health information.

Any patient-like examples are fictional and are included only for security testing.
