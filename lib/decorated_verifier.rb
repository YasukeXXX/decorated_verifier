require 'active_support'
require 'active_model'
require 'pry'

module DecoratedVerifier
  extend ActiveSupport::Concern
  include ActiveModel::Model

  class_methods do
    def decorate_verifier(verifier, **options)
      define_singleton_method :verifier { verifier }
      define_singleton_method :value_name { options[:value_name] }
      define_singleton_method :validate { options[:validate] }
      define_singleton_method :error_message { options[:error_message] }
      define_singleton_method :decorate_value do
        return options[:decorate_value].call if options[:decorate_value].is_a? Proc
        options[:decorate_value]
      end
      define_singleton_method :secret do
        return 'decorated_verifier' unless options[:secret]
        return options[:secret].call if options[:secret].is_a? Proc
        options[:secret]
      end

      send(:alias_method, options[:value_name], :decorated_message)
    end

    def generate(value)
      verifier.generate([value, signed_decorate_value])
    end

    def signed_decorate_value
      decorated_verifier.generate decorate_value
    end

    def decorated_verifier
      ActiveSupport::MessageVerifier.new(secret)
    end
  end

  included do
    attr_accessor :token

    validates :token, presence: true
    validates_each :decorated_message do |record, attr, _|
      record.errors.add(attr, error_message) unless record.send(validate)
    end

    delegate :verifier, :decorated_verifier, to: :class
    delegate_missing_to :verifier
  end

  def decorated_message
   @decorated_message ||= decorated_verifier.verified original_message&.last
  end

  def original_message
    @original_message ||= verified token
  end

  def valid_message
    return unless valid?

    @valid_message ||= original_message&.first
  end
end
