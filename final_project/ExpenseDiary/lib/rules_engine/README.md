**Walley Rules Engine — Phase 2 (Frozen)**
Purpose

The Walley Rules Engine is a pure, deterministic decision engine that converts raw financial data into calm, non-judgmental awareness signals.

It is designed to:

reduce user anxiety

respect silence and rejection

avoid financial shaming

remain explainable and testable

This document freezes Phase 2, where behavior is fully locked using unit tests.

**Core Philosophy**

Awareness > Enforcement

Observation > Explanation

Silence is a valid state

Patterns > Totals

User rejection permanently alters behavior

The engine never:

blocks spending

suggests actions

predicts income

generates UI text

invokes AI

**Engine Responsibilities**

The Rules Engine answers only one question:

“Given this user data, is there something they should calmly be aware of?”

It outputs a neutral data object, never text.

class AwarenessResult {
  final AwarenessLevel level;
  final String? category;
  final AwarenessReason reason;
}

**Architecture Overview**
            User Data
   (expenses, budgets, suppression)
                    │
                    ▼
        ┌────────────────────┐
        │   Normalization     │
        │  (NR-01 → NR-03)    │
        │  - isolate spikes   │
        │  - ignore one-time  │
        │  - category-only    │
        └─────────┬──────────┘
                  ▼
        ┌────────────────────┐
        │   Observation      │
        │  (OR-01 → OR-04)   │
        │  - frequency       │
        │  - rhythm          │
        │  - velocity        │
        │  - category usage  │
        └─────────┬──────────┘
                  ▼
        ┌────────────────────┐
        │   Awareness Eval   │
        │  (AR-01 → AR-04)   │
        │  - silence rules   │
        │  - context         │
        │  - threshold       │
        │  - suppression     │
        └─────────┬──────────┘
                  ▼
           AwarenessResult

**Phase 2 — Unit Test Lock**

All behavior is locked using human-scenario-based unit tests, not coverage-driven tests.

What tests protect:

New users remain silent

Inactive users are not nudged

One-time / large expenses don’t distort patterns

Budget usage triggers context / threshold awareness

User dismissal permanently suppresses future signals

If a test fails, the logic is wrong — not the test.

**Folder Structure**
lib/
└── rules_engine/
    ├── rules_engine.dart      // Orchestrator
    ├── normalization.dart     // NR rules
    ├── observation.dart       // OR rules
    ├── awareness.dart         // AR rules
    ├── suppression.dart       // Trust & memory
    ├── models.dart            // Data contracts
    └── README.md              // This file

test/
└── rules_engine/
    ├── normalization_test.dart
    ├── observation_test.dart
    ├── awareness_levels_test.dart
    ├── awareness_silence_test.dart
    └── suppression_test.dart

“This engine is intentionally calm.
Silence is not a failure — it is a design choice.”

22.12.2025
## Project Status

Walley is currently in a **stable foundation phase**.

### Completed
- Traditional expense tracking & budgeting
- Unified add-expense pipeline (manual + auto)
- Behavior-aware data model (category, one-time flags)
- Deterministic Rules Engine for financial awareness
- EVE AI architecture (explanation-only, no decision logic)

### Paused (Planned Next)
- LLM integration & prompt refinement
- Observation-based testing
- UI/UX micro-interactions & polish
- Analytics & monthly narratives

The current version is intentionally frozen to preserve architectural clarity.
