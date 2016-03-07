# encoding: utf-8

class RecipePictureUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(pdf)
  end


  version :full do
    process :extract
    process convert: :jpg

    def full_filename(for_file = model.source.file)
      super.chomp(File.extname(super)) + '.jpg'
    end
  end

  private

  # Only extract first page of PDF
  def extract
    manipulate! do |img|
      img.frames.second
    end
  end
end
