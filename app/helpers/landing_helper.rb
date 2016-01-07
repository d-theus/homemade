module LandingHelper
  def landing?
    controller_name == 'landing'
  end

  def date_format(date)
    I18n.l(date, format: '%e %B')
  end

  def next_week_begin
    today = Date.today
    if today.days_to_week_start < 4
      date_format(today.next_week)
    else
      date_format(today.next_week + 1.week)
    end
  end

  def next_week_end
    today = Date.today
    if today.days_to_week_start < 4
      date_format(today.next_week + 4.days)
    else
      date_format(today.next_week + 11.days)
    end
  end

  def next_sunday
    today = Date.today
    if today.days_to_week_start < 4
      date_format(today.sunday)
    else
      date_format(today.next_week.sunday)
    end
  end
end
