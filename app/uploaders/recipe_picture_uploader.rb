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


  version :large do
    process pdf_page_to_jpg: [{ page: 1, density: 150, prefix: 'large' }]

    def full_filename(for_file = model.source.file)
      super.chomp(File.extname(super)) + '.jpg'
    end
  end

  version :small do
    process pdf_page_to_jpg: [{ page: 1, density: 96, prefix: 'small' }]

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

  def increase_density
    manipulate! do |img|
      img.density(300)
      img
    end
  end

  def pdf_page_to_jpg(options = {})
    options.reverse_merge!({ page: 0, density: 150, prefix: ''})
    manipulate! do |img|
      input = img.path
      output = File.join(Rails.root, 'public', cache_dir, "#{options[:prefix]}_#{File.basename(input)}.jpg")
      system 'convert', '-density', options[:density].to_s, "#{input}[#{options[:page]}]", output
      MiniMagick::Image.open(output)
    end
  end
end
