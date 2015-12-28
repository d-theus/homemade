module ApplicationHelper
  SRCW = { 'lg' => 1440, 'md' => 920, 'sm' => 520}
  def card(&block)
    capture_haml do
      haml_tag :div, class: 'card' do
        yield
      end
    end
  end

  def card_image(image, &block)
    capture_haml do
      haml_tag :div, class: 'card-img-container' do
        haml_tag :img, src: image_path(image)
      end
    end
  end
end
