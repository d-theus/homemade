module LandingHelper
  def landing?
    controller_name == 'landing'
  end

  def format(date)
    I18n.l(date, format: '%e %B')
  end

  def next_week_begin
    today = Date.today
    if today.sunday?
      format(today + 8.days)
    else
      format today.next_week
    end
  end

  def next_week_end
    today = Date.today
    if today.sunday?
      format(today + 12.days)
    else
      format(today.next_week + 4.days)
    end
  end

  def next_sunday
    today = Date.today
    if today.sunday?
      format(today + 1.week)
    else
      format today.sunday
    end
  end
end
