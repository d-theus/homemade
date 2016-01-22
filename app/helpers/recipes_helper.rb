module RecipesHelper
  def human_day(day)
    %w(первый второй третий четвёртый пятый)[day - 1]
  end

  def options_for_day
    featured = Recipe.featured.pluck(:day, :title).to_h
    result = []
    result << ['Нет', nil]
    [*1..5].each { |i| result << ["#{i} − #{featured[i] || 'свободно'}", i] }
    result
  end
end
