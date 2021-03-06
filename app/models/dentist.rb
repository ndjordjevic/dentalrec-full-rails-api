class Dentist < ActiveRecord::Base
  validates :auth_token, uniqueness: true

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_create :generate_authentication_token!

  has_many :appointments, dependent: :destroy

  def generate_authentication_token!
    begin
      self.auth_token = Devise.friendly_token
    end while self.class.exists?(auth_token: auth_token)
  end

  scope :filter_by_email, lambda { |email|
                          where('lower(email) LIKE ?', "%#{email.downcase}%")
                        }

  def self.search(params = {})
    dentists = Dentist.all
    dentists = dentists.filter_by_email(params[:email]) if params[:email]

    dentists
  end
end
