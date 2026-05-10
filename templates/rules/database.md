---
paths: ["**/*.sql", "**/migrations/**", "**/models/**", "**/repositories/**"]
---
- Parameterized queries ONLY — never string-concatenate SQL
- Always add indexes on foreign key columns
- Wrap multi-table mutations in transactions
- Never `DROP` without explicit user confirmation in the conversation
- Migration files: forward-only (no rollback logic embedded)
- Use `EXPLAIN ANALYZE` before merging queries on tables >100K rows
- Connection pooling: never open raw connections in hot paths
