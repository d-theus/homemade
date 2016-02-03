module WeeklyMenuSubscriptionsHelper
  def base64_icon(name)
    data = "data:;base64,"
    data << Base64.encode64(
      File.read(
        File.join(Rails.root, 'app', 'assets', 'images', name)
      )
    )
    data
  end
end
