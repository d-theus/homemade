# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://www.homemade-msk.ru"

SitemapGenerator::Sitemap.create do
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
  Recipe.find_each do |recipe|
    add recipe_path(recipe), priority: recipe.day ? 0.9 : 0.5
  end
end
