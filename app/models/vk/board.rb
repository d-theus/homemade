module Vk
  class Board
    attr_accessor :comments

    def initialize(id)
      @tid = id
      @vk = ::VkontakteApi::Client.new(code: ENV['VK_APP_TOKEN'])
      @comments ||= fetch_comments
    end

    def refresh
      @comments = fetch_comments
    end

    protected

    def fetch_comments
      comments = @vk.board.get_comments(group_id: GROUP_ID, topic_id: @tid)['comments'].drop(1)
      user_ids = comments.map(&:from_id)
      users = @vk.users.get(user_ids: user_ids, fields: %w(photo_50))
      comments.each_with_index { |cm, i| cm[:user] = users[i] }
    end
  end
end

