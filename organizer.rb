require_relative 'tmdb_client'
require_relative 'downloader'
require_relative 'nfo_writer'
require_relative 'image_manager'
require 'fileutils'
require 'yaml'

class Organizer
  VIDEO_EXTENSIONS = %w[.mp4 .mkv .avi .mov]

  def initialize(api_key:, incoming_path:, library_path:, exceptions_path:)
    @tmdb = TMDBClient.new(api_key)
    @incoming_path = incoming_path
    @library_path = library_path
    @exceptions = File.exist?(exceptions_path) ? YAML.load_file(exceptions_path) : {}
  end

  def organize_incoming
    Dir.glob("#{@incoming_path}/**/* - S??E??.*").select do |file|
      VIDEO_EXTENSIONS.include?(File.extname(file).downcase)
    end.each { |file| process_file(file) }
  end

  private

  def process_file(file)
    name, season, episode, clean_name, search_season, search_episode = resolve_episode_info(file)
    return unless name

    puts "📦 Processando: #{clean_name} S%02dE%02d" % [season, episode]

    tv_id = @tmdb.series_id(clean_name)
    unless tv_id
      warn "❌ ID da série não encontrado: #{clean_name}"
      return
    end

    episode_data = @tmdb.fetch_episode(tv_id, search_season, search_episode)
    return unless validate_episode_data(episode_data, clean_name, season, episode, search_season, search_episode)

    paths = build_paths(clean_name, season, episode)
    thumb_url = ImageManager.episode_thumb_url(episode_data)

    begin
      FileUtils.mkdir_p(paths[:target_season_path])
      ImageManager.download_season_poster(@tmdb, tv_id, season, paths[:target_season_path])

      data = @tmdb.fetch_series(tv_id)
      if data
        ImageManager.update_series_images(paths[:target_series_path], data)
        NfoWriter.create_tvshow_nfo(paths[:target_series_path], data) unless File.exist?(File.join(paths[:target_series_path], "tvshow.nfo"))
      end

      puts "🔍 Confirmando episódio buscado: Season #{episode_data["season_number"]}, Episode #{episode_data["episode_number"]}, Title: #{episode_data["name"]}"
      puts "🔎 Thumb URL: #{thumb_url} for #{clean_name} S%02dE%02d" % [season, episode]

      ImageManager.download_episode_thumb(thumb_url, paths[:target_thumb_path]) or raise "imagem não baixada"
      NfoWriter.create_episode_nfo(paths[:target_nfo_path], episode_data, season, episode, ImageManager.episode_thumb_base)
    rescue => e
      warn "❌ Erro ao preparar episódio #{paths[:filename_base]}: #{e.message}"
      File.delete(paths[:target_thumb_path]) if File.exist?(paths[:target_thumb_path])
      return
    end

    move_related_files(file, paths[:target_season_path], paths[:filename_base])
    puts "✅ Finalizado: #{paths[:filename_base]}"
  end

  def resolve_episode_info(file)
    base = File.basename(file, File.extname(file))
    dirname = File.dirname(file)
    return [nil] * 6 unless base =~ /^(.+?) - S(\d{2})E(\d{2})$/

    name, season, episode = $1.strip, $2.to_i, $3.to_i
    clean_name = name.gsub(/[_\-.]/, ' ').squeeze(" ").strip
    mapped = @exceptions.dig(clean_name, "S%02dE%02d" % [season, episode])

    if mapped && (md = mapped.match(/S(\d+)E(\d+)/))
      search_season, search_episode = [md[1].to_i, md[2].to_i]
    else
      search_season, search_episode = [season, episode]
    end

    [name, season, episode, clean_name, search_season, search_episode]
  end

  def validate_episode_data(episode_data, clean_name, season, episode, search_season, search_episode)
    unless episode_data
      warn "⚠️ Episódio não encontrado no TMDB: #{clean_name} S%02dE%02d" % [search_season, search_episode]
      return false
    end
    unless episode_data["still_path"]
      warn "⚠️ Episódio sem imagem: #{clean_name} S%02dE%02d" % [season, episode]
      return false
    end
    true
  end

  def build_paths(clean_name, season, episode)
    filename_base = "#{clean_name} - S%02dE%02d" % [season, episode]
    target_series_path = File.join(@library_path, clean_name)
    target_season_path = File.join(target_series_path, "Season %02d" % season)
    target_thumb_path = File.join(target_season_path, "#{filename_base}.jpg")
    target_nfo_path = File.join(target_season_path, "#{filename_base}.nfo")
    {
      filename_base: filename_base,
      target_series_path: target_series_path,
      target_season_path: target_season_path,
      target_thumb_path: target_thumb_path,
      target_nfo_path: target_nfo_path
    }
  end

  def move_related_files(file, target_season_path, filename_base)
    base = File.basename(file, File.extname(file))
    dirname = File.dirname(file)
    Dir.glob(File.join(dirname, "#{base}.*")).each do |f|
      FileUtils.mv(f, File.join(target_season_path, filename_base + File.extname(f)))
    end
  end
end
