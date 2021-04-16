# README
DOGArtefacts
babylon-artefacts

# Dependencies
* Ruby 2.4 (Rails 5.2.3)
* ES 6.6
* PG 9.5


# Installation
```bash
bundle exec rake searchkick:reindex CLASS=Artefact RAILS_ENV=production
bundle exec rake searchkick:reindex CLASS=Source RAILS_ENV=production
```


# Development
For local development you will have to set api.dev.local:Port as provider site. 
