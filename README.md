# ADGB (DOGArtefacts / babylon-artefacts)

ADGB ist die Forschungsanwendung zu Grabungsfunden und Quellen aus Babylon.
Benutzer melden sich über **Babili** (OAuth2) an. Dateien, Vokabular und
Bibliographie liegen bei Babili; ADGB speichert Artefakte, Quellen und
Zugriffsrechte lokal.

Schwesterprojekt: Babili (`~/dev/babili` bzw. Produktion `*.babylon-online.org`).

## Abhängigkeiten (Stand Modernisierung 2026)

| Komponente | Version / Hinweis |
|---|---|
| Ruby | **3.4.2** |
| Rails | **8.1.4** |
| Bundler | 2.5.x |
| Node | ≥ 16.15 |
| Yarn | 1.22.x |
| PostgreSQL | ≥ 15 |
| OpenSearch | ≥ 2.4, **lokal auf dem App-Host, HTTP ohne SSL** (`http://localhost:9200`) |

### Ruby-Gems (Auswahl)

- Suche: Searchkick 6.x + opensearch-ruby 3.x  
- Sharing: lokale Concerns `Sharing` / `ShareModel` (ersetzt `shareable_models`)  
- Pagination: Pagy 43  
- Versionierung: PaperTrail 17  
- Tags: acts-as-taggable-on 13  
- Charts: Chartkick 5  
- Auth-Client: OmniAuth OAuth2 + CSRF-Protection  

### JavaScript (Yarn)

- Uppy **4.18** (Datei-Upload nach Babili)  
- `@rails/ujs` **7.1**  
- jQuery, Leaflet, Selectize, Magnific Popup, Toastr, Chartkick  

### Frontend (bewusst unverändert)

Weiterhin **Bootstrap 3 + jQuery + Turbolinks + Sprockets**. Eine visuelle
Modernisierung (Bootstrap 5 usw.) ist **nicht** Bestandteil der
Stack-Modernisierung.

## Lokale Einrichtung

```bash
cp config/database.yml.example config/database.yml
# Credentials: bin/rails credentials:edit  (benötigt config/master.key)
# Mindestens: provider_site, client_id, client_secret, host_id, opensearch_url
bundle install
yarn install
bin/rails db:setup   # oder Produktions-Dump einspielen
```

Hosts (WSL + Windows-Hosts-Datei): `api.dev.local` und `dev.local` → `127.0.0.1`.  
ADGB: Port **3001**. Babili: Port **3000** (`provider_site: http://api.dev.local:3000`).

OpenSearch-Beispiel in Credentials:

```yaml
opensearch_url: http://localhost:9200
```

## OpenSearch / Searchkick

Betrieb: OpenSearch nur auf demselben Rechner wie die App, **HTTP, ohne TLS**.
Port 9200 nicht öffentlich freigeben.

```bash
export OPENSEARCH_URL='http://localhost:9200'
bundle exec rake searchkick:reindex CLASS=Artefact
bundle exec rake searchkick:reindex CLASS=Source
# Nach jedem Artefact-Reindex:
curl -s -X PUT "http://localhost:9200/artefacts_development/_settings" \
  -H 'Content-Type: application/json' \
  -d '{"index":{"max_terms_count":100000}}'
```

In Production Indexname `artefacts_production` verwenden.

## Tests

```bash
bin/rails test
# Kern-Regression:
bin/rails test test/models/visibility_test.rb \
  test/controllers/api/v1/artefacts_controller_test.rb
```

Ältere Scaffold-Controller-Tests sind bewusst übersprungen (Routen/Auth
geändert). Maßgeblich sind Visibility-, Grants-, Sessions- und API-Tests.

## Dokumentation für Betrieb / Verwaltung

| Dokument | Inhalt |
|---|---|
| [docs/HANDOVER.md](docs/HANDOVER.md) | Übergabe an Verwaltung / Betrieb |
| [docs/CUTOVER.md](docs/CUTOVER.md) | Checkliste Produktions-**Aktualisierung** |
| [docs/SECURITY.md](docs/SECURITY.md) | Kurzbefund Sicherheit |

## Produktions-Aktualisierung (Kurz)

Kein Neuaufbau des Servers. Bestehenden Stand aktualisieren: Code ausrollen,
`bundle install`, `assets:precompile`, Puma neu starten, Searchkick
reindizieren. **Schema:** Dieses Upgrade bringt nur in **Babili** eine neue
Migration (Solid Queue/Cable); ADGB unverändert. Details:
[docs/CUTOVER.md](docs/CUTOVER.md).
