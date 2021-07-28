# README
DOGArtefacts
babylon-artefacts

# Dependencies
* ruby 2.7.3
* rails 5.2.6
* gem bundler 2.2.17
* node >= 10.24.1
* yarn 1.22.5
* postgres >= 9.5
* elasticsearch = 6.8.15


# Installation
```bash
bundle exec rake searchkick:reindex CLASS=Artefact RAILS_ENV=production
bundle exec rake searchkick:reindex CLASS=Source RAILS_ENV=production
```


# Development
For local development you will have to set api.dev.local:Port as provider site.
