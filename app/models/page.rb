class Page < ActiveRecord::Base
  has_many :child, class_name: "Page", foreign_key: "parent_id", dependent: :destroy

  validates :name, uniqueness: true
  validates :name, :title, :body, presence: true
  validates :name, format: {with: /\A[\w\p#{'a-zA-Z0-9_'}]+\z/}

  accepts_nested_attributes_for :child, reject_if: :all_blank, allow_destroy: true
end
