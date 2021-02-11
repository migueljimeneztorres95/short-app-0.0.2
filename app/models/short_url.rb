require 'open-uri'

class ShortUrl < ApplicationRecord

  validates :full_url, presence: true
  validate :validate_full_url
  before_create :generate_short_code

  scope :ordered, -> { order(click_count: :desc) }

  def update_title!
    title = open(full_url).read.scan(/<title>(.*?)<\/title>/)
    update(title: title.flatten.first)
  end

  def public_attributes
    {
      "title"=> title,
      "click_count"=> click_count,
      "full_url"=> full_url,
      "short_code"=> short_code,
    }
  end

  private

  def generate_short_code
    max = ShortUrl.last ? (ShortUrl.last.id.digits.count/2).ceil : 1
    code = SecureRandom.uuid[1..max]
    while ShortUrl.find_by(short_code: code) do
      code = SecureRandom.uuid[1..max]
    end
    self[:short_code] = code
  end

  def validate_full_url
    uri = begin
      URI.parse(full_url)
    rescue StandardError
      errors.add(:full_url, :invalid_url)
    end

    return if uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

    errors.add(:full_url, :invalid_url)
  end

end
