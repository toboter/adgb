# README
DOGArtefacts / babylon-artefacts

ADGB is the Babylon excavation artefacts research app. It authenticates against **Babili** (sibling checkout at `~/dev/babili`) via OAuth2.

# Dependencies
* ruby 3.4.2
* rails 8.1.4
* bundler 2.5.x
* node >= 16.15.1
* yarn 1.22.x
* postgresql >= 15
* opensearch >= 2.4

Sharing / grants use a **local** `Sharing` concern and `ShareModel` (replaces the
unmaintained `shareable_models` gem). The `share_models` table is unchanged.

Frontend is still **Bootstrap 3 + jQuery + Turbolinks + Sprockets**. Recently
updated: **Uppy 4.18** (was 0.27), **`@rails/ujs` 7.1** (was rails-ujs 5.2),
**Chartkick 5**. Deferred later: Bootstrap 5, Turbo/Stimulus, Propshaft /
jsbundling, `font-awesome-rails` → npm FA, `sassc`/`uglifier` → dartsass/terser.

Babili-only markup/RDF stack (`html-pipeline` 2.x, `commonmarker`,
`linkeddata` / Getty AAT SPARQL) and Froala→Trix Writer notes are in the
Babili README — ADGB does not use those editors/gems.


# Local setup
```bash
cp config/database.yml.example config/database.yml
# Encrypted credentials (see config/credentials.yml.example):
#   bin/rails credentials:edit
# Needs config/master.key (gitignored). Set provider_site, client_id/secret,
# host_id, opensearch_url, …
bundle install
yarn install
bin/rails db:setup   # or restore a production dump for realistic data
```

Set `provider_site` to your local Babili API (e.g. `http://api.dev.local:3000`). Point `/etc/hosts` (and the Windows hosts file under WSL) so `api.dev.local` and `dev.local` resolve to `127.0.0.1`. ADGB listens on port **3001**; Babili on **3000**.

Minimal regression checks after upgrades:
```bash
bin/rails test test/models/visibility_test.rb test/controllers/api/v1/artefacts_controller_test.rb
```

# OpenSearch / Searchkick
Searchkick reads `OPENSEARCH_URL` (defaults to `http://localhost:9200`).

Recent OpenSearch (including the official Docker image) usually enables the security plugin. Then you must set an authenticated HTTPS URL, e.g.:

```bash
export OPENSEARCH_URL='https://admin:YOUR_PASSWORD@localhost:9200'
```

**Deploy:** set `OPENSEARCH_URL` in the production environment (env / secrets) to the cluster URL including credentials when security is on. Prefer real TLS with certificate verification in production; local Docker self-signed certs are allowed via `config/initializers/opensearch.rb` only for `https://` URLs in development-style setups.

### Reindex checklist
1. Set `OPENSEARCH_URL` (see above).
2. Reindex:
   ```bash
   bundle exec rake searchkick:reindex CLASS=Artefact
   bundle exec rake searchkick:reindex CLASS=Source
   ```
3. Raise `max_terms_count` on the artefacts index (required after every Artefact reindex; Searchkick creates a new physical index with the default 65536 limit). Without this, `/artefacts` fails when filtering all ~78k ids:
   ```bash
   curl -sk -u 'admin:YOUR_PASSWORD' -X PUT "https://localhost:9200/artefacts_development/_settings?pretty" \
     -H 'Content-Type: application/json' \
     -d '{"index":{"max_terms_count":100000}}'
   ```
   Use `artefacts_production` (and matching host/auth) in production.
4. Confirm:
   ```bash
   curl -sk -u 'admin:YOUR_PASSWORD' "https://localhost:9200/artefacts_development/_settings?pretty" | grep max_terms_count
   ```

# Upgrade / go-live (code + schema migrations only)

No special dump conversion is required. Production data already has PaperTrail as `jsonb` and no PostGIS. Walk Rails upgrades **locally**; cut over once with the finished apps onto the **existing** production databases.

## Local upgrade path
1. Develop against a restored dump (or empty DB) on Ruby 2.7 / Rails 5.2.
2. Climb the Rails ladder locally (6.0 → … → 8.1 + Ruby 3.4). Run `bin/rails db:migrate` when framework/gem migrations appear.
3. Do **not** deploy intermediate Rails versions to production.

## Production cutover checklist
1. Maintenance window; backup Postgres (and any Active Storage / file blobs).
2. Deploy final ADGB (Ruby 3.4 / Rails 8.1) alongside final Babili.
3. Set env / credentials, including `OPENSEARCH_URL` with credentials when security is on.
4. `bin/rails db:migrate RAILS_ENV=production` (schema only — no data conversion scripts).
5. Reindex Searchkick (`Artefact`, `Source`) and set `max_terms_count` (see above).
6. Smoke: sign-in via Babili OAuth, artefact/source CRUD, search.

**Not required at cutover:** restoring a converted dump, PostGIS casts, or PaperTrail YAML→JSON rewrites.
