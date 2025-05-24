require 'net/http'
require 'json'
require 'uri'
require 'fileutils'
require 'yaml'
require 'open-uri'
require 'digest'

class TMDBClient
  def initialize(api_key, language = 'en')
    @api_key = api_key
    @language = language
    @series_ids = {}
  end

  def series_id(name)
    return @series_ids[name] if @series_ids[name]
    uri = build_search_uri(name)
    res = Net::HTTP.get_response(uri)
    data = JSON.parse(res.body)
    @series_ids[name] = data["results"]&.first&.[]("id")
  end

  def fetch_episode(tv_id, season, episode)
    uri = build_episode_uri(tv_id, season, episode)
    res = Net::HTTP.get_response(uri)
    return nil unless res.is_a?(Net::HTTPSuccess)
    JSON.parse(res.body)
  end

  def fetch_series(tv_id)
    uri = build_series_uri(tv_id)
    res = Net::HTTP.get_response(uri)
    return nil unless res.is_a?(Net::HTTPSuccess)
    JSON.parse(res.body)
  end

  def fetch_season(tv_id, season_number)
    uri = build_season_uri(tv_id, season_number)
    res = Net::HTTP.get_response(uri)
    return nil unless res.is_a?(Net::HTTPSuccess)
    JSON.parse(res.body)
  end

  private

  def build_search_uri(name)
    URI("https://api.themoviedb.org/3/search/tv?api_key=#{@api_key}&language=#{@language}&query=#{URI.encode_www_form_component(name)}")
  end

  def build_episode_uri(tv_id, season, episode)
    URI("https://api.themoviedb.org/3/tv/#{tv_id}/season/#{season}/episode/#{episode}?api_key=#{@api_key}&language=#{@language}")
  end

  def build_series_uri(tv_id)
    URI("https://api.themoviedb.org/3/tv/#{tv_id}?api_key=#{@api_key}&language=#{@language}")
  end

  def build_season_uri(tv_id, season_number)
    URI("https://api.themoviedb.org/3/tv/#{tv_id}/season/#{season_number}?api_key=#{@api_key}&language=#{@language}")
  end
end
