# == Schema Information
#
# Table name: shortened_urls
#
#  id           :integer          not null, primary key
#  long_url     :string
#  short_url    :string
#  submitter_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class ShortenedUrl < ActiveRecord::Base
  validates :submitter_id, presence: true
  validates :long_url, length: { maximum: 1024 }
  validates :short_url, presence: true, uniqueness: true
  validate :less_than_5_urls_per_minute

  belongs_to(
    :submitter,
    class_name: 'User',
    foreign_key: :submitter_id,
    primary_key: :id
  )

  has_many(
    :visits,
    class_name: 'Visit',
    foreign_key: :short_url_id,
    primary_key: :id
  )

  has_many(
    :visitors,
    -> { distinct },
    through: :visits,
    source: :user
  )

  has_many(
    :taggings,
    class_name: 'Tagging',
    foreign_key: :short_url_id,
    primary_key: :id
  )

  has_many :tag_topics, :through => :taggings, :source => :tag_topic

  def self.random_code
    code = SecureRandom.base64
    until !ShortenedUrl.exists?(:short_url => code)
      code = SecureRandom.base64
    end
    code
  end

  def self.create_for_user_and_long_url!(user, long_url)
    ShortenedUrl.create!(
      :long_url => long_url,
      :short_url => ShortenedUrl.random_code,
      :submitter_id => user.id
      )
  end

  def num_clicks
    visits.count
  end

  def num_uniques
    visitors.count
  end

  def num_recent_uniques
    visitors.where("visits.updated_at >= ?", 10.minutes.ago).count
  end

  private
  def less_than_5_urls_per_minute
    user_urls = ShortenedUrl.where("submitter_id == ?", self.submitter_id)
    if user_urls.where("created_at >= ?", 1.minute.ago).count > 5
      raise "STOP"
    end
  end

end
