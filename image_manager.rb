require_relative 'downloader'

class ImageManager
  EPISODE_THUMB_BASE = "https://image.tmdb.org/t/p/w500"
  SERIES_POSTER_BASE = "https://image.tmdb.org/t/p/w500"

  def self.episode_thumb_base
    EPISODE_THUMB_BASE
  end

  def self.episode_thumb_url(episode_data)
    return nil unless episode_data && episode_data["still_path"]
    EPISODE_THUMB_BASE + episode_data["still_path"]
  end

  def self.download_episode_thumb(url, dest)
    Downloader.download_image(url, dest)
  end

  def self.update_series_images(series_dir, series_data)
    poster_url = poster_url(series_data)
    fanart_url = fanart_url(series_data)
    {
      "poster.jpg" => poster_url,
      "fanart.jpg" => fanart_url
    }.each do |filename, url|
      path = File.join(series_dir, filename)
      begin
        Downloader.download_image(url, path)
        puts "🎨 Atualizado: #{filename}"
      rescue => e
        warn "⚠️ Falha ao baixar #{filename}: #{e.message}"
      end
    end
  end

  def self.download_season_poster(tmdb_client, tv_id, season_number, series_dir)
    data = tmdb_client.fetch_season(tv_id, season_number)
    return unless data && data["poster_path"]
    local_path = File.join(series_dir, "season#{season_number.to_s.rjust(2, '0')}-poster.jpg")
    url = SERIES_POSTER_BASE + data["poster_path"]
    Downloader.download_image(url, local_path)
  end

  private_class_method def self.poster_url(series_data)
    return nil unless series_data && series_data["poster_path"]
    SERIES_POSTER_BASE + series_data["poster_path"]
  end

  private_class_method def self.fanart_url(series_data)
    return nil unless series_data && series_data["backdrop_path"]
    SERIES_POSTER_BASE + series_data["backdrop_path"]
  end
end
