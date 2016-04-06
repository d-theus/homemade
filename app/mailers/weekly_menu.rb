class WeeklyMenu < ActionMailer::Base
  add_template_helper WeeklyMenuSubscriptionsHelper
  add_template_helper ApplicationHelper

  default from: 'HomeMade <sub@homemade-msk.ru>'

  def email(subscriber)
    @recipes = Rails.cache.fetch 'featured_recipes', expires_in: 10.seconds do
      Recipe.featured.includes(:inventory_items)
    end

    @sub = subscriber

    mail(to: @sub.email, subject: I18n.t('mailers.weekly_menu.subject.email') )
  end

  def subscribed_email(subscriber)
    @sub = subscriber

    mail(to: @sub.email, subject: I18n.t('mailers.weekly_menu.subject.subscribed_email') )
  end
end
