namespace :orders do
  desc "Clean up orders for last week"
  task close: :environment do
    Order.close
  end

  desc "Switch orders statuses appropriately"
  task advance: :environment do
    Order.advance
  end
end
