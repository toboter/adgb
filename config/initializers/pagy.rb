# frozen_string_literal: true
# Pagy 43 — see https://ddnexus.github.io/pagy/

# Default page size (session[:per_page] / params[:per_page] override per request).
Pagy::OPTIONS[:limit] = 50
Pagy::OPTIONS.freeze
