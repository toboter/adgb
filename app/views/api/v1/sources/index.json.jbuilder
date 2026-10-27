json.sources @sources do |source|
  json.partial! "sources/source", source: source
end
json.meta @meta
