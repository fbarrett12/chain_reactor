📦 AI-Powered EDI / Document Normalization Service

A scalable, vendor-agnostic, AI-assisted file ingestion and normalization pipeline built with Ruby on Rails.

✨ Features

Upload CSV, JSON, or XML vendor data files

Background job processing

Config-driven vendor mapping rules

Multi-step normalization pipeline

Optional AI field enrichment

Validation + structured error annotations

Webhook callback support

Versioned JSON API (/api/v1/uploads)

Full RSpec test suite

🏗️ Architecture

          ┌──────────────────────────┐
          │  Client / External App   │
          └──────────────┬───────────┘
                         POST
                      /uploads
                         │
            ┌────────────▼────────────┐
            │      DocumentUpload     │
            │   (ActiveRecord model)  │
            └────────────┬────────────┘
                         │ enqueue
                         ▼
         ┌─────────────────────────────────┐
         │ ProcessDocumentUploadJob        │
         │  - Sets status lifecycle        │
         │  - Handles failure/retry        │
         └─────────────────┬──────────────┘
                           │
                           ▼
             ┌────────────────────────────┐
             │     DocumentNormalizer     │
             │  (Pipeline orchestrator)   │
             └────────────────────────────┘
                       │ │ │ │
                       │ │ │ └─────────────── Validation
                       │ │ └───────────────── AI enrichment
                       │ └─────────────────── Field mapping
                       └───────────────────── Parsing (CSV/JSON/XML)

                           ▼
        ┌──────────────────────────────────────┐
        │ Normalized payload stored in DB(JSON)│
        └──────────────────────────────────────┘
                           │
                           ▼ optional
             ┌────────────────────────────────┐
             │        WebhookNotifier         │
             │  - Sends results to client     │
             └────────────────────────────────┘



🧩 Key Components & Responsibilities
1. DocumentUpload (Model)

Central data structure representing each uploaded file.

Handles:

Status lifecycle (pending → processing → succeeded/failed)

Error logging

File attachment (ActiveStorage)

Storage for normalized payload (JSONB)

This encapsulated lifecycle makes upload state predictable and observable.

2. EdiRules (Config Loader)

Rules defined in config/edi_rules.yml:

Required fields per vendor

Source → canonical field mappings

Easily extended with new vendors

This enables clean separation between vendor formats and internal domain schema.

3. ParserFactory & Parsers

Strategy pattern for ingesting various file formats:

CsvParser

JsonParser

XmlParser (stubbed)

All parsers output the same intermediate structure:
array of Hashes with vendor-specific keys.

4. FieldMapper

Maps vendor-specific keys into canonical Rails symbols, using the mapping rules from the config.

Example: "UPCCode" → :upc.

Keeps _original record for validation and debugging.

5. AiFieldEnricher

Optional AI-assisted enrichment step.

Detects missing required fields

Generates suggestions (stubbed; ready for Azure OpenAI)

Adds _ai_suggestions metadata

Never overwrites existing data

This mirrors how AI should behave in production pipelines:
augment, don’t mutate raw data.


6. RecordValidator

Annotates missing required fields per vendor:

{ _validation_errors: { missing_fields: [...] } }

No exceptions thrown — client systems can decide whether to accept or reject records.

7. DocumentNormalizer (Orchestrator)

Pipeline coordinator.

Steps:

Parse

Map

AI enrich

Validate

Compute statistics (missing field counts, record totals)

Returns a structured JSON payload ready for client consumption.

8. Background Job: ProcessDocumentUploadJob

Wraps the entire pipeline in an async job

Manages state transitions

Captures exceptions and stores failure reasons

Optionally triggers webhook notifications

Idempotent in structure and retry-safe

9. WebhookNotifier

Sends POST callbacks to client URLs

Includes status, errors, and normalized payload

Gracefully logs failures

Webhook is sent for both success and failure.

10. API (v1)

Endpoints:

POST /api/v1/uploads

Upload a file + optional webhook URL.
Returns 202 Accepted and enqueues background job.

GET /api/v1/uploads/:id

Retrieve status + payload.

GET /api/v1/uploads

List uploads (recent first).

🧪 Test Suite Overview

The project includes a full RSpec suite covering:

Model specs

Lifecycle transitions

Error handling

processed_at and error_message behavior

Service specs

Validated in isolation using doubles/stubs:

FieldMapper

RecordValidator

AiFieldEnricher

DocumentNormalizer

ParserFactory (implicitly exercised)

WebhookNotifier

These confirm correct transformations and pipeline behavior.

Job specs

Successful normalization flow

Failure path

Webhook triggered or skipped appropriately

Uses:

instance_of(DocumentUpload) for resilient matches

Stabilized stubs for DocumentNormalizer + WebhookNotifier

Request specs

/uploads creates records & enqueues jobs

/uploads/:id returns expected JSON

/uploads lists uploads

Config loader specs

EdiRules loads YAML rules

Unknown vendor properly raises KeyError

The suite proves both correctness and modularity.

TO DO

1. Replace ActiveJob Inline with Sidekiq or Azure Queue

For horizontal scalability:

Sidekiq + Redis

Azure Service Bus

AWS SQS

Kafka for streaming ingest

Ensures at-least-once delivery and better monitoring.

2. Add Webhook Signing & Retry Strategy

Current webhook delivery is simple.

Production additions:

HMAC signature (X-Signature-SHA256)

Delivery attempt logs

Exponential backoff + DLQ

Eventual consistency guarantees

3. Add Observability Layer

Structured logging (Lograge)

Job metrics (Prometheus)

“Normalization error rate per vendor” dashboard

AI usage metrics

4. Batch processing for large vendor files

For CSVs with 100k+ rows:

Streaming CSV parser

Chunked job fan-out

Aggregation job for combining results

5. Full AI Integration

Replace stubs with Azure OpenAI:

Embeddings for similarity-based guessing

GPT-4o-mini for structured field inference

Model fallback strategy

Cost control: caching AI suggestions per field

6. Versioned Canonical Schema

Introduce:

/schema/v1

/schema/v2

Allow vendors to upgrade without breaking older integrations.

7. Add Authentication / API Keys

For multi-tenant systems:

HMAC API keys

JWT with vendor-scoped claims

Rate limiting (Rack::Attack)

8. Add Admin UI for Vendor Rules

Rules currently live in YAML.
A small admin dashboard could allow:

Editing required fields

Editing mappings

Testing transformations

Managing AI behavior per vendor
