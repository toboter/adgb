# README
DOGArtefacts
babylon-artefacts

# Dependencies
* ruby 2.7.3
* rails 5.2.8
* bundler 2.3.26
* node >= 16.15.1
* yarn 1.22.19
* postgresql >= 15
* opensearch >= 2.4


# Installation
```bash
bundle exec rake searchkick:reindex CLASS=Artefact RAILS_ENV=production
bundle exec rake searchkick:reindex CLASS=Source RAILS_ENV=production
```

## Increase number of allowed terms
```
curl -X PUT "localhost:9200/artefacts_development/_settings?pretty" -H 'Content-Type: application/json' -d '
{
    "index" : {
        "max_terms_count" : 100000
    }
}
'
```

`curl -X GET "localhost:9200/artefacts_development/_settings?pretty"`


# Development
For local development you will have to set api.dev.local:Port as provider site.
