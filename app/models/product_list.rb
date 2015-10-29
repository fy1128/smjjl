class ProductList < ActiveRecord::Base
  # data
  cattr_accessor :types
  self.types = DbItem.new(
    jd: {label: '京东',  value: 'ProductList::Jd'},
    dangdang: {label: '当当',  value: 'ProductList::Dangdang'},
    amazon: {label: '亚马逊',  value: 'ProductList::Amazon'},
    gome: {label: '国美',  value: 'ProductList::Gome'},
    newegg: {label: '新蛋',  value: 'ProductList::Newegg'}
    )
  # extends ...................................................................
  # includes ..................................................................
  include Patcher

  # security (i.e. attr_accessible) ...........................................
  attr_accessible :url, :url_key

  # relationships .............................................................
  # validations ...............................................................
  validates :url, uniqueness: { scope: :type }, presence: true
  validates :url_key, uniqueness: { scope: :type }, if: "url_key.present?"

  # callbacks .................................................................
  # scopes ....................................................................
  scope :unblocked, -> {where(is_blocked: false)}

  # additional config .........................................................
  # class methods .............................................................
  # public instance methods ...................................................
  # protected instance methods ................................................
  # private instance methods ..................................................
end
