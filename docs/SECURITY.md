# ADGB — Sicherheit (Modernisierung ab Mitte Oktober 2026)

Kein Penetrationstest. Dieses Dokument hält fest, **was seit dem
Ruby-/Rails-Upgrade (Mitte Oktober 2026) sicherheitsrelevant gehärtet
wurde**, und welche **Rest- bzw. akzeptierten Risiken** danach noch
bestehen. Nachgezogene Bundle-Updates bis **November 2026**
(Rails **8.1.4.1**, Puma 8.x, OmniAuth 2.4, rubyzip 3.x, …). Audits mit
`brakeman` / `bundler-audit` auf dem aktuellen Stand (Ruby 3.4).

## Behoben / gehärtet seit Mitte Oktober 2026

| Thema | Was geändert wurde |
|---|---|
| Runtime-Stack | Ruby **3.4.2**, Rails **8.1.4.1** (inkl. Active-Storage-Security-Patches) |
| App-Server | **Puma ≥ 7.2.1** (Lock: 8.1.1) — Request-Smuggling-/PROXY-Advisories geschlossen |
| OmniAuth | **≥ 2.2** (Lock: 2.4.1); `OmniAuth.config.allowed_hosts` gegen gefälschte Callback-Hosts; CSRF-Protection bleibt aktiv |
| OAuth2-Client | `oauth2` ≥ 2.0.22, `jwt` ≥ 2.10.3 (Lock: 2.1.0 / 3.3.0) |
| CORS-Middleware | `rack-cors` ≥ 2.0.2 (Lock: 3.0.0) |
| ZIP / Excel-Import | `rubyzip` ≥ 3.4 (Lock: 3.7.0), `roo` ≥ 4.0 — Path-Traversal-Advisories der 2.x-Linie geschlossen |
| msgpack | ≥ 1.8.7 (Bootsnap) |
| Active Storage / Bilder | `mini_magick` **~> 5.1** (Lock: 5.4.0) — Pflicht ab Rails 8.1.4.1 ImageMagick-Policy |
| JS | `lodash` ≥ 4.18 (Lock: 4.18.1) |
| Test-Stack | `selenium-webdriver` ≥ 4.38 (Lock: 4.52.0), kompatibel mit rubyzip 3.x |
| Dynamisches `constantize` | Grants/Versions auf Allowlists beschränkt |
| Log-Filter | Tokens/Secrets (`access_token`, `refresh_token`, `client_secret`, …) |
| XML | `rexml` ≥ 3.3.9 |
| Audit | `brakeman` / `bundle-audit` nach den Upgrades; Findings priorisiert |

## Offen / akzeptiert

| ID | Thema | Einschätzung | Behandlung |
|---|---|---|---|
| A1 | Raw-SQL in `GrantsController#grant_multiple` | Mittel. Klassen und IDs sind allowlisted bzw. Integer; Pattern bleibt strukturell angreifbarer als ActiveRecord-Bulk. | Kurzfristig belassen. Langfristig auf AR-`insert_all`/Association-API umstellen. |
| A2 | OpenSearch ohne TLS (`http://localhost:9200`) | Niedrig auf Loopback; hoch bei öffentlicher Exposition. | Akzeptiert. Betrieb: nur `127.0.0.1` binden. |
| A3 | Langlebige OAuth-Access-Tokens (Babili-Provider) | Mittel bei Token-Diebstahl: gültig bis Widerruf. | Akzeptiert (Client-Abstimmung). Widerruf über Babili/Doorkeeper. |

## Betrieb

- OpenSearch nicht nach außen exposieren.
- `RAILS_MASTER_KEY` und OAuth-Secrets nur Credentials/Env, nie im Repository.
- OmniAuth-`allowed_hosts` bei neuen Domains/Hosts ergänzen.
- Nach größeren Dependency-Updates erneut `brakeman` und `bundle-audit check`.
