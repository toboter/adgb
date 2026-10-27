json.artefacts @artefacts do |artefact|
  json.partial! "artefacts/artefact", artefact: artefact
end
json.meta @meta if @meta
