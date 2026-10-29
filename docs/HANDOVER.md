# Übergabedokumentation ADGB

**Zielgruppe:** Verwaltung und Betrieb (nicht Entwicklerinnen/Entwickler im
Tagesgeschäft).  
**Stand:** Oktober 2026 — nach Modernisierung auf Ruby 3.4 / Rails 8.1.  
**Schwestersystem:** Babili (OAuth-Provider, Dateien, Vokabular, Bibliographie).

---

## 1. Worum handelt es sich?

ADGB (auch: DOGArtefacts / babylon-artefacts) ist die webbasierte Anwendung zur
Verwaltung und Recherche von **Artefakten** und **Quellen** der Grabungen in
Babylon. Forschende melden sich an, durchsuchen Bestände, pflegen Datensätze,
steuern die **Sichtbarkeit** (veröffentlichen / freigeben) und laden bei Bedarf
**Abbildungen** hoch.

Technisch ist ADGB eine eigenständige Rails-Anwendung. Die Anmeldung läuft über
**Babili** (OAuth2). Hochgeladene Dateien werden bei Babili gespeichert; ADGB
merkt sich nur eine stabile Datei-ID und baut Anzeige-URLs daraus.

Öffentliche Domains (Produktion, Beispiel): Hosts unter
`*.babylon-online.org` (u. a. ADGB-Frontend). Die genaue Subdomain legt die
IT-Infrastruktur fest.

---

## 2. Was wurde modernisiert? (Kurz für Nicht-Techniker)

Zwischen älterem Stand (Ruby 2.x / Rails 5) und dem jetzigen Stand wurden
vor allem **Technik und Bibliotheken** erneuert, damit die Anwendungen weiter
sicher und wartbar laufen. Die **fachlichen Funktionen** (Artefakte, Quellen,
Suche, Rechte) bleiben erhalten.

Wesentliche technische Änderungen:

| Thema | Vorher (sinngemäß) | Nachher |
|---|---|---|
| Programmiersprache / Framework | ältere Ruby-/Rails-Versionen | Ruby **3.4.2**, Rails **8.1.4** |
| Rechte teilen | externes, nicht mehr gepflegtes Gem | eigene, lokale Lösung im Code |
| Hintergrundjobs | (über Babili/Sidekiq historisch) | ADGB selbst: synchrone Web-Requests; Dateien/Jobs bei Babili mit Solid Queue |
| Datei-Upload-UI | sehr altes Uppy | Uppy 4 |
| Suche | Elasticsearch-Ära → OpenSearch | OpenSearch **lokal auf dem Server**, HTTP |
| Frontend-Design | Bootstrap 3 | **unverändert** Bootstrap 3 (kein Redesign im Auftrag) |

**Nicht** Bestandteil dieser Modernisierung: neues Design, Bootstrap 5,
grundlegende neue Fachfunktionen, laufender 24/7-Support außerhalb der
vereinbarten Leistungen, umfassender Penetrationstest.

---

## 3. Architektur im Überblick

```text
  Browser (Mitarbeitende)
           |
           v
     ADGB (Port typ. hinter nginx)
           |
           +-- PostgreSQL (Artefakte, Quellen, Rechte, …)
           |
           +-- OpenSearch auf localhost:9200  (Volltextsuche)
           |
           +-- OAuth / API / Dateien -------> Babili
                                              |
                                              +-- eigene Postgres
                                              +-- Dateispeicher (Shrine)
```

**Wichtig für den Betrieb:**

1. ADGB und Babili müssen **gemeinsam** erreichbar und versioniert zueinander
   passen (OAuth-Client-ID/Secret, Redirect-URLs).
2. OpenSearch läuft **nur auf dem gleichen Rechner** wie die App, über
   `http://localhost:9200`, **ohne SSL**. Der Port darf **nicht** aus dem
   Internet erreichbar sein.
3. Datei-URLs in ADGB werden aus der gespeicherten **Datei-ID** und der
   Einstellung `provider_site` (Babili-Basis-URL) erzeugt. Bei Domain-Wechsel
   von Babili reicht die Anpassung von `provider_site` — kein Massen-Update
   alter URL-Spalten nötig.

---

## 4. Server- und Softwarevoraussetzungen

| Komponente | Anforderung |
|---|---|
| Betriebssystem | bestehendes Debian-/Linux-Zielsystem (kein Neuaufbau vorgesehen) |
| Ruby | 3.4.2 (rbenv oder vergleichbar) |
| Node.js / Yarn | für Asset-Kompilierung |
| PostgreSQL | ≥ 15 |
| OpenSearch | ≥ 2.4, lokal, HTTP |
| Webserver | nginx/Apache als Reverse-Proxy vor Puma |
| App-Server | Puma |

Geheimnisse liegen in **Rails Credentials** (`RAILS_MASTER_KEY`) bzw.
Umgebungsvariablen — nicht im Git-Repository.

Wichtige Credential-/Env-Felder:

- `provider_site` — Basis-URL der Babili-API (z. B. `https://api.babylon-online.org`)
- `client_id` / `client_secret` — Doorkeeper-Anwendung in Babili
- `host_id` — Anwendungs-ID in Babili
- `opensearch_url` — typisch `http://localhost:9200`
- `secret_key_base`

---

## 5. Aktualisierung in Produktion (kein Neu-Deploy)

Das bestehende System wird **aktualisiert**, nicht neu installiert.
Schritt-für-Schritt-Checkliste: [CUTOVER.md](CUTOVER.md).

Ablauf in Kurzform:

1. Wartungsfenster vereinbaren; Backups von Postgres (ADGB + Babili) und
   Babili-Dateispeicher.
2. Neuen Code auf den Host bringen (Babili zuerst oder parallel, dann ADGB).
3. Abhängigkeiten installieren, Assets kompilieren, Puma neu starten.
   **Datenbank:** Aus diesem Upgrade gibt es nur **eine** neue Migration —
   in **Babili** (Solid Queue / Solid Cable). Die ADGB-Datenbank ändert ihr
   Schema dabei nicht.
4. Suchindizes neu aufbauen (Searchkick) und bei Artefakten
   `max_terms_count` setzen.
5. Smoke-Tests: Login, Suche, Datensatz öffnen, Upload, Rechte vergeben.

---

## 6. Betriebliche Routine

### 6.1 Dienste

- **Puma** für ADGB (Prozessverwaltung wie bisher: systemd/supervisor o. Ä.).
- **OpenSearch** lokal; nach Reboot prüfen, ob Port 9200 antwortet:
  `curl -s http://localhost:9200`.
- **Babili** muss für Login und Uploads laufen.

### 6.2 Backups

- Regelmäßig: PostgreSQL-Dump ADGB.
- Abgestimmt mit Babili-Backups (DB + Dateispeicher), da Uploads dort liegen.

### 6.3 Suche reparieren

Wenn die Artefact-Liste Fehler wegen zu vieler Treffer zeigt:

```bash
export OPENSEARCH_URL=http://localhost:9200
bundle exec rake searchkick:reindex CLASS=Artefact RAILS_ENV=production
curl -s -X PUT "http://localhost:9200/artefacts_production/_settings" \
  -H 'Content-Type: application/json' \
  -d '{"index":{"max_terms_count":100000}}'
```

### 6.4 Logs

Anwendungslogs unter dem konfigurierten Log-Pfad (typisch `log/production.log`).
Passwörter und Tokens werden aus Logzeilen herausgefiltert.

---

## 7. Anmeldung und Rechte

- Login: „Sign in“ → Weiterleitung zu Babili → zurück zu ADGB mit Session.
- Abgelaufene Babili-Access-Tokens führen zur Abmeldung (Schutzmechanismus).
- **Sharing/Grants:** Datensätze können gezielt für Benutzer oder Gruppen
  freigegeben werden (Lesen/Schreiben). Bulk-Aktionen auf Listen möglich.
- **Veröffentlichen / Entsperren:** steuert die öffentliche bzw. freigegebene
  Sichtbarkeit (PaperTrail-Ereignisse).

Bei Login-Problemen zuerst Babili-Erreichbarkeit und Doorkeeper-Redirect-URI
prüfen (muss exakt zur ADGB-Callback-URL passen).

---

## 8. Dateien / Anhänge an Quellen

- Upload über Uppy im Quellen-Formular → Speicherung in Babili → in ADGB nur
  `file_id`.
- Anzeige-URL: `{provider_site}/raw/files/{file_id}/view?version=large`
- Bei Domain-Änderung von Babili: `provider_site` in Credentials anpassen.

---

## 9. Tests und Qualität

Automatisierte Tests (Stand Übergabe): Suite läuft ohne Fehler; einzelne
ältere Generator-Tests sind bewusst übersprungen. Kernprüfungen:

- Sichtbarkeit / Veröffentlichung  
- API Artefacts/Sources  
- Grants  
- OAuth-Session  

Manuelle Smoke-Liste: siehe [CUTOVER.md](CUTOVER.md).

---

## 10. Sicherheit (Verwaltungs-Zusammenfassung)

Im Zuge der Modernisierung wurden u. a. Allowlists bei Grants/Versions,
erweiterte Log-Filter und der aktuelle Rails-/Ruby-Stack nachgezogen.
**Offene bzw. bewusst akzeptierte Rest-Risiken** (kein Changelog der Fixes):
[SECURITY.md](SECURITY.md).

- HTTPS für die Web-Oberfläche über den Reverse-Proxy (`force_ssl` in Rails).
- Secrets verschlüsselt; Master-Key nur auf dem Server.
- OpenSearch nicht öffentlich.

---

## 11. Ansprechpartner und weiterführende Unterlagen

| Dokument | Zweck |
|---|---|
| [README.md](../README.md) | Technische Kurzübersicht / lokale Dev-Setup |
| [CUTOVER.md](CUTOVER.md) | Checkliste Update-Fenster |
| [SECURITY.md](SECURITY.md) | Offene / akzeptierte Rest-Risiken |
| Babili `docs/HANDOVER.md` | Übergabe der Partner-Anwendung |

Fachliche oder infrastrukturelle Eskalation: bisherige Projekt-Maintainers /
IT des Auftraggebers gemäß bestehender Vereinbarung.
