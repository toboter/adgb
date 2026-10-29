# Produktions-Aktualisierung (ADGB + Babili)

**Kein Neu-Deploy / keine Neuinstallation.** Bestehendes Zielsystem und bestehende
PostgreSQL-Datenbanken werden auf den modernisierten Stand (Ruby 3.4 / Rails 8.1)
aktualisiert. Kein konvertierter Dump-Restore, keine PostGIS-Casts, kein
PaperTrail YAML→JSON-Rewrite.

Voraussetzung: beide Apps lokal auf Ruby 3.4 / Rails 8.1 fertiggestellt und
getestet. Schwester-Checkliste: Babili `docs/CUTOVER.md`.

## Vor dem Wartungsfenster

- [ ] Backup ADGB-Postgres und Babili-Postgres
- [ ] Backup Shrine-/Datei-Storage (Babili)
- [ ] OpenSearch auf dem App-Host erreichbar unter `http://localhost:9200`
      (HTTP, ohne SSL; nicht öffentlich binden)
- [ ] `OPENSEARCH_URL` in Credentials/Env auf `http://localhost:9200` (oder
      lokalen HTTP-Endpoint) gesetzt
- [ ] Doorkeeper-Redirect-URIs enthalten den Produktions-Callback von ADGB
- [ ] Host: Ruby 3.4.2, Node/Yarn verfügbar; Sidekiq/Redis für Babili **nicht**
      mehr nötig (Solid Queue in Puma)

## Aktualisierung

1. Code von **Babili**, dann **ADGB** (oder gemeinsam) auf dem bestehenden Host
   ausrollen.
2. Env / Credentials prüfen (`RAILS_MASTER_KEY`, OAuth-Secrets,
   `OPENSEARCH_URL=http://localhost:9200`).
3. Abhängigkeiten und Assets. **Schema:** Aus dem Upgrade (Mitte Oktober 2026)
   gibt es **nur eine neue Migration — in Babili**
   (`db/migrate/20261027120000_create_solid_queue_and_cable_tables.rb`,
   Solid Queue + Solid Cable). **ADGB hat keine neue Schema-Migration;**
   `db:migrate` dort ist ein No-op, sofern die DB schon auf dem bisherigen
   Stand war.

   ```bash
   # Babili (Schema-Änderung hier)
   bundle install --deployment --without development test
   bin/rails db:migrate RAILS_ENV=production
   bin/rails assets:precompile RAILS_ENV=production

   # ADGB (kein neues Schema aus diesem Upgrade)
   bundle install --deployment --without development test
   bin/rails assets:precompile RAILS_ENV=production
   # optional: bin/rails db:migrate RAILS_ENV=production  # sollte „nothing to migrate“ sein
   ```

4. Nur Babili — ungenutzte PaperTrail-Entwürfe entfernen, falls noch Zeilen
   vorhanden:

   ```sql
   TRUNCATE versions;
   ```

5. Puma neu starten (beide Apps). Babili: Solid Queue läuft standardmäßig im
   Puma-Prozess (`SOLID_QUEUE_IN_PUMA=true`). Kein Sidekiq, kein Redis.
   Optional separater Worker: `SOLID_QUEUE_IN_PUMA=false bin/jobs`.

## Searchkick / OpenSearch (lokal, HTTP)

```bash
# ADGB
export OPENSEARCH_URL='http://localhost:9200'
bundle exec rake searchkick:reindex CLASS=Artefact RAILS_ENV=production
bundle exec rake searchkick:reindex CLASS=Source RAILS_ENV=production
curl -s -X PUT "http://localhost:9200/artefacts_production/_settings" \
  -H 'Content-Type: application/json' \
  -d '{"index":{"max_terms_count":100000}}'

# Babili — Reindex der in der Babili-README genannten Klassen
# (Namespace, Biblio::Entry, Discussion::Thread, Writer::Document,
#  Vocab::Concept, Zensus::Agent, Zensus::Event, Zensus::Appellation, Locate::Place)
```

Nach jedem Artefact-Reindex erneut `max_terms_count` setzen (Searchkick erzeugt
einen neuen physischen Index mit Default-Limit).

## Smoke nach dem Update

- [ ] Babili: Devise-Login
- [ ] ADGB: OAuth-Login über Babili
- [ ] Artefact-/Source-Liste und Suche
- [ ] Datei-Upload von ADGB nach Babili
- [ ] Hintergrundjob (Solid Queue) verarbeitet eine Aufgabe
- [ ] Sharing/Grants (Zugriff teilen / entziehen)

## Nicht erforderlich

- Wiederherstellung eines konvertierten Dumps
- PostGIS / Geometrie-Casts
- PaperTrail YAML→JSON-Umwandlung
- Neuaufbau von Webserver, Postgres oder OpenSearch
- Extension `vector` / pgvector (wird von keiner App genutzt)

## Hinweis zu `schema.rb` vs. Migrationen

Der große Diff an `db/schema.rb` beim Rails-8-Upgrade (Okt. 2026) kam vor allem
vom **Neu-Dump** der lokalen DB, nicht von neuen Fach-Migrationen:

- `datetime … precision: nil` und `pg_catalog.plpgsql` = Dump-Stil Rails 8 / neuer
  PG-Adapter, keine inhaltliche Schemaänderung.
- `enable_extension "vector"` war Dump-Müll vom Entwickler-Host (pgvector
  systemweit) und wurde aus beiden `schema.rb` entfernt — **nicht** migraten,
  **nicht** auf Produktion aktivieren.
- **ADGB `imports`:** Migration existiert seit 2018
  (`20180905115745_add_import`). Die Tabelle fehlte jahrelang nur in
  `schema.rb` (2019 aus dem Dump verschwunden) und tauchte 2026 wieder auf,
  weil die lokale DB sie noch hatte. Keine neue Migration nötig.
- **ADGB `import_events` / `import_headers` / `import_sheets`:** stehen seit
  2019 in `schema.rb`, **ohne** eigene Migrationen (historisch nur per Dump
  nachgezogen). Auf bestehenden Systemen nicht neu anlegen, sofern schon
  vorhanden; Neuaufbau einer DB nur über `db:schema:load`, nicht über
  „alle Migrationen von null“.
- **Babili PostGIS / `locate_locations`:** 2023 aus `schema.rb` entfernt, ohne
  `drop_…`-Migration. Die alte `create_table` mit `t.geometry` liegt weiter
  unter `db/migrate/`; Produktion und aktuelles Schema sind ohne PostGIS.
  Deshalb: bestehendes System **nur** `db:migrate` (Solid-Tabellen), kein
  PostGIS nachinstallieren, kein Geometrie-Cast.
- **Einzige neue Migration dieses Upgrades:** Babili
  `20261027120000_create_solid_queue_and_cable_tables` (Solid Queue + Cable).
