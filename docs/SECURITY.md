# ADGB — Sicherheit (Modernisierung ab Mitte Oktober 2026)

Kein Penetrationstest. Dieses Dokument hält fest, **was seit dem
Ruby-/Rails-Upgrade (Mitte Oktober 2026) sicherheitsrelevant gehärtet
wurde**, und welche **Rest- bzw. akzeptierten Risiken** danach noch
bestehen. Abschlussprüfung mit `brakeman` und `bundler-audit` auf dem
aktuellen Stand (Rails 8.1 / Ruby 3.4).

## Behoben / gehärtet seit Mitte Oktober 2026

| Thema | Was geändert wurde |
|---|---|
| Runtime-Stack | Ruby **3.4.2**, Rails **~> 8.1** — Framework-Security-Patches und unterstützte Laufzeit |
| Doorkeeper / OAuth-Client | Doorkeeper und zugehörige Integration auf aktuelle Minor-Versionen; CSRF-Schutz für OmniAuth bleibt aktiv |
| Dynamisches `constantize` (Grants) | Nur noch `Artefact`/`Source` bzw. `User`/`Group` über Allowlist |
| Dynamisches `constantize` (Versions) | Nur noch `Artefact`/`Source` |
| Log-Filter | Erweitert u. a. um `access_token`, `refresh_token`, `client_secret`, `authenticity_token`, `git_token` |
| Abhängigkeiten | u. a. `rexml` ≥ 3.3.9; Produktions-Bundle auf dem aktualisierten Lockfile |
| Audit | `brakeman` und `bundle-audit` nach den Upgrades ausgeführt; Findings priorisiert (siehe unten) |

## Offen / akzeptiert

| ID | Thema | Einschätzung | Behandlung |
|---|---|---|---|
| A1 | Raw-SQL in `GrantsController#grant_multiple` | Mittel. Klassen und IDs sind allowlisted bzw. Integer; Pattern bleibt strukturell angreifbarer als ActiveRecord-Bulk. | Kurzfristig belassen. Langfristig auf AR-`insert_all`/Association-API umstellen. |
| A2 | OpenSearch ohne TLS (`http://localhost:9200`) | Niedrig auf Loopback; hoch bei öffentlicher Exposition. | Akzeptiert. Betrieb: nur `127.0.0.1` binden. |
| A3 | Langlebige OAuth-Access-Tokens (Babili-Provider) | Mittel bei Token-Diebstahl: gültig bis Widerruf. | Akzeptiert (Client-Abstimmung). Widerruf über Babili/Doorkeeper. |
| A4 | CVEs in Test-Gems (`selenium-webdriver`, transitives `rubyzip`/`rexml` in der Test-Gruppe) | Produktionsrisiko vernachlässigbar. | Beim nächsten Dev/Test-Bundle-Update; vor Prod-Deploy erneut auditieren. |

## Betrieb

- OpenSearch nicht nach außen exposieren.
- `RAILS_MASTER_KEY` und OAuth-Secrets nur Credentials/Env, nie im Repository.
- Nach größeren Dependency-Updates erneut `brakeman` und `bundle-audit check`.
