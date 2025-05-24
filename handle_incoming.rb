require_relative 'organizer'

API_KEY = ENV["TMDB_API_KEY"]
INCOMING_PATH = ENV["INCOMING_PATH"] || "/incoming"
LIBRARY_PATH = ENV["LIBRARY_PATH"] || "/library"
EXCEPTIONS_PATH = ENV["EXCEPTIONS_PATH"] || "./exceptions.yml"

abort("❌ TMDB_API_KEY não está configurada.") if API_KEY.to_s.empty?

Organizer.new(
  api_key: API_KEY,
  incoming_path: INCOMING_PATH,
  library_path: LIBRARY_PATH,
  exceptions_path: EXCEPTIONS_PATH
).organize_incoming

puts "\n✅ Todos os arquivos foram processados com sucesso."
