fail 'Yandex.Kassa API key required' unless ENV["YANDEX_KASSA_KEY"] && ENV["YANDEX_KASSA_SHOP_ID"]

class YandexKassa
  attr_accessor :shop_id, :shop_key, :url
  CODE_SUCCESS = 0
  CODE_UNAUTHORIZED = 1
  CODE_DENY = 100
  CODE_UNPROCESSABLE = 200

  def hash(h)
    h = h.stringify_keys
    h['shopPassword'] ||= shop_key || fail("<shop_key> required")
    h['shopId'] ||= shop_id || fail("<shop_id> required")
    params = %w(action orderSumAmount orderSumCurrencyPaycash orderSumBankPaycash shopId invoiceId customerNumber shopPassword)

    params.each do |param|
      fail "Parameter #{param} required" unless h[param]
    end

    str = params.map { |p| h[p] }.join(';')

    Digest::MD5.hexdigest(str).upcase
  end
end

Rails.application.config.yandex_kassa = YandexKassa.new
Rails.application.config.yandex_kassa.shop_id = ENV["YANDEX_KASSA_SHOP_ID"]
Rails.application.config.yandex_kassa.shop_key = ENV["YANDEX_KASSA_KEY"]
Rails.application.config.yandex_kassa.url = "https://demomoney.yandex.ru/eshop.xml"

