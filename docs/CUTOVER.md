# Production cutover (ADGB + Babili)

Code + schema migrations only. No converted-dump restore, no PostGIS casts, no PaperTrail YAML→JSON rewrite.

Prerequisite: both apps finished locally on Ruby 3.4 / Rails 8.1.

## Before the window

- [ ] Backup ADGB Postgres and Babili Postgres
- [ ] Backup Shrine / file storage (Babili)
- [ ] Confirm OpenSearch reachable; note admin password / `OPENSEARCH_URL`
- [ ] Confirm Doorkeeper redirect URIs include production ADGB callback
- [ ] Confirm Debian host can run Ruby 3.4, Node/Yarn, Redis (Babili Sidekiq)

## Deploy

1. Deploy final **Babili** then **ADGB** (or both together).
2. Set production env / credentials (`RAILS_MASTER_KEY`, OAuth secrets, `OPENSEARCH_URL=https://user:pass@host:9200`).
3. On each app:
   ```bash
   bundle install --deployment --without development test
   bin/rails db:migrate RAILS_ENV=production
   bin/rails assets:precompile RAILS_ENV=production
   ```
4. Babili only — clear unused PaperTrail drafts if any remain:
   ```sql
   TRUNCATE versions;
   ```
5. Restart Puma (both) and Sidekiq (Babili).

## Searchkick

```bash
# ADGB
export OPENSEARCH_URL='https://admin:PASSWORD@opensearch-host:9200'
bundle exec rake searchkick:reindex CLASS=Artefact RAILS_ENV=production
bundle exec rake searchkick:reindex CLASS=Source RAILS_ENV=production
curl -sk -u 'admin:PASSWORD' -X PUT "https://opensearch-host:9200/artefacts_production/_settings" \
  -H 'Content-Type: application/json' \
  -d '{"index":{"max_terms_count":100000}}'

# Babili — reindex Namespace, Biblio::Entry, Discussion::Thread, Writer::Document,
# Vocab::Concept, Zensus::Agent, Zensus::Event, Zensus::Appellation, Locate::Place
```

## Smoke

- [ ] Babili Devise login
- [ ] ADGB OAuth via Babili
- [ ] Artefact / source browse + search
- [ ] File upload from ADGB to Babili
- [ ] Sidekiq processing a job
