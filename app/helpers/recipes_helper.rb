module RecipesHelper
  def human_day(day)
    %w(первый второй третий четвёртый пятый)[day - 1]
  end
end
