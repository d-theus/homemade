# encoding: utf-8

class ItemImageUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(svg)
  end

  version :icon do
    process :resize_to_fill => [128,128]
    process :convert => 'png'

    def full_filename(for_file)
      original = File.basename(model.image.file.file)
      result = original.gsub(/\.svg\z/, '.png')
      result
    end
  end

  def base64
    data = "data:;base64,"
    data << Base64.encode64(self.icon.read)
    data
  end
end
