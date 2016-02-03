# encoding: utf-8

class RecipePhotoUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :preview do
    process :resize_to_fill => [800, 600]
  end

  version :show do
    process :resize_to_fit => [1200, 800]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  def full_cache_path
    "#{::Rails.root}/public/#{cache_dir}/#{cache_name}"
  end

  def base64
    data = "data:image/jpeg;base64,"
    data << Base64.encode64(self.preview.read)
    data
  end
   
  #private

  #def encode_base64
    #image = 
      #manipulate! do |img|
       #img.resize_to_fit [480, 480]
      #img
      #end.read
    #data << Base64.encode64(image)
    #File.write(self.current_path,data)
  #end
end
