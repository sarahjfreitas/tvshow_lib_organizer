require 'open-uri'
require 'digest'

class Downloader
  def self.download_image(url, dest)
    tmp_data = URI.open(url).read
    tmp_hash = Digest::MD5.hexdigest(tmp_data)
    if File.exist?(dest)
      existing_hash = Digest::MD5.hexdigest(File.read(dest))
      return if tmp_hash == existing_hash
    end
    File.write(dest, tmp_data)
  rescue => e
    warn "❌ Falha ao baixar imagem #{url}: #{e.message}"
    nil
  end

  private_class_method def self.file_hash(path)
    Digest::MD5.hexdigest(File.read(path))
  end
end
