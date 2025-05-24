class NfoWriter
  def self.create_episode_nfo(path, data, actual_season, actual_episode, thumb_base)
    File.write(path, <<~XML)
      <episodedetails>
        <title>#{data["name"]}</title>
        <season>#{actual_season}</season>
        <episode>#{actual_episode}</episode>
        <aired>#{data["air_date"]}</aired>
        <plot>#{data["overview"]}</plot>
        <runtime>#{data["runtime"] || 60}</runtime>
        <thumb>#{thumb_base}#{data["still_path"]}</thumb>
      </episodedetails>
    XML
  end

  def self.create_tvshow_nfo(series_dir, tv_data)
    nfo_path = File.join(series_dir, "tvshow.nfo")
    File.write(nfo_path, <<~XML)
      <tvshow>
        <title>#{tv_data["name"]}</title>
        <plot>#{tv_data["overview"]}</plot>
        <thumb>poster.jpg</thumb>
        <fanart>fanart.jpg</fanart>
        <episodeguide></episodeguide>
      </tvshow>
    XML
  end

  private_class_method def self.nfo_path(series_dir)
    File.join(series_dir, "tvshow.nfo")
  end
end
