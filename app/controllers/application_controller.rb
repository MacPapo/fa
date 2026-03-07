class ApplicationController < ActionController::Base
  include Pagy::Method
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private
    # Ricostruisce l'URL di ritorno iniettando il nuovo parametro per il morphing
    def build_morph_url(base_url, param_key, param_value)
      uri = URI.parse(base_url)

      # Prende i parametri esistenti dell'URL (se ce ne sono) e li trasforma in un Hash
      query_params = Rack::Utils.parse_nested_query(uri.query || "")

      # Aggiunge o sovrascrive il nostro parametro (es. { "new_photographer_id" => "42" })
      query_params[param_key.to_s] = param_value.to_s

      # Ricostruisce la query string in formato Rails e la riattacca all'URL
      uri.query = query_params.to_query
      uri.to_s
    rescue URI::InvalidURIError
      # Fallback di sicurezza nel caso in cui params[:return_to] sia malformato
      root_path
    end
end
