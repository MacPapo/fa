module Avatarable
  extend ActiveSupport::Concern

  def avatar_initials
    # Assicuriamoci che display_name sia una stringa pulita
    name = display_name.to_s.strip
    return "?" if name.blank?

    # Dividiamo la stringa in parole usando gli spazi
    words = name.split(/\s+/)

    # Magia Ruby: prendiamo al massimo le prime 2 parole,
    # di ognuna estraiamo la prima lettera [0], le uniamo e le facciamo uppercase.
    # - "Mario Rossi" -> "MR"
    # - "Mario" -> "M"
    # - "Acme Corporation SpA" -> "AC"
    words.take(2).map { |word| word[0] }.join.upcase
  end
end
