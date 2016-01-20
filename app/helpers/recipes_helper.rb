module RecipesHelper
  def human_day(day)
    %w(первый второй третий четвёртый пятый)[day - 1]
  end

  def options_for_day
    result = []
    result << ['Нет', nil]
    [*1..5].each { |i| result << [i,i] }
    result
  end
end
