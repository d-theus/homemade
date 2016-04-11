module ApplicationHelper
  SRCW = { 'lg' => 1440, 'md' => 920, 'sm' => 520}
  def card(options = {}, &block)
    capture_haml do
      haml_tag :div, options.deep_merge(class: 'card') do
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

  def admin?
    admin_signed_in?
  end

  def date_format(date)
    I18n.l(date, format: '%e %B')
  end

  def next_week_begin(today = Time.zone.today)
    if today.days_to_week_start < 4
      date_format(today.next_week)
    else
      date_format(today.next_week + 1.week)
    end
  end

  def next_week_end(today = Time.zone.today)
    if today.days_to_week_start < 4
      date_format(today.next_week + 4.days)
    else
      date_format(today.next_week + 11.days)
    end
  end

  def next_sunday(today = Time.zone.today)
    if today.days_to_week_start < 4
      date_format(today.sunday)
    else
      date_format(today.next_week.sunday)
    end
  end

  def phone_number(number)
    country = number[0]
    code = number[1..3]
    num1  = number[4..6]
    num2  = number[7..10]
    "+#{country} (#{code}) #{num1} #{num2}"
  end
end
