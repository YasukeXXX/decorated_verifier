require 'spec_helper'

RSpec.describe DecoratedVerifier do
  let(:verifier_model) do
    Class.new do
      include DecoratedVerifier

      def self.name
        'verifier_model'
      end
    end
  end

  let(:params) { { decorate_value: decorate_value, value_name: value_name, validate: validate, error_message: error_message, secret: secret } }
  let(:decorate_value) { 'decorate_value' }
  let(:error_message) { 'error_message' }
  let(:validate) { :validate }
  let(:value_name) { :generated_at }
  let(:secret) { nil }
  let(:verifier) { ActiveSupport::MessageVerifier.new('secret') }

  before do
    verifier_model.decorate_verifier verifier, params
  end

  describe '.generate' do
    subject { verifier_model.generate value }

    let(:value) { 'value' }
    let(:decorated_verifier) { ActiveSupport::MessageVerifier.new('decorated_verifier') }

    it { is_expected.to eq verifier.generate([value, decorated_verifier.generate(decorate_value)]) }
  end

  describe '.decorated_verifier' do
    subject { verifier_model.decorated_verifier }

    it { is_expected.to be_is_a ActiveSupport::MessageVerifier }
  end

  describe '.singed_decorate_value' do
    subject { verifier_model.signed_decorate_value }

    context 'with secret' do
      let(:secret) { 'secret' }
      let(:decorated_verifier) { ActiveSupport::MessageVerifier.new(secret) }

      it { is_expected.to eq decorated_verifier.generate decorate_value }
    end

    context 'without secret' do
      let(:decorated_verifier) { ActiveSupport::MessageVerifier.new('decorated_verifier') }

      it { is_expected.to eq decorated_verifier.generate decorate_value }
    end

    context 'when secret is proc' do
      let(:secret) { -> { 'secret' } }
      let(:decorated_verifier) { ActiveSupport::MessageVerifier.new(secret.call) }

      it { is_expected.to eq decorated_verifier.generate decorate_value }
    end
  end

  describe '#valid?' do
    subject { verifier_instance.valid? }

    let(:verifier_instance) { verifier_model.new token: token }
    let(:token) { verifier_model.generate value }
    let(:value) { 'value' }

    before do
      verifier_instance.define_singleton_method validate do
        decorated_message == 'decorate_value'
      end
    end

    context 'without token' do
      let(:token) { nil }

      it { is_expected.to be_falsy }
    end

    context 'with invalid value' do
      let(:decorate_value) { 'invalid_value' }

      it :aggregate_failer do
        is_expected.to be_falsy
        expect(verifier_instance.errors.full_messages).to include "Decorated message #{error_message}"
      end
    end

    context 'with valid value' do
      let(:decorate_value) { 'decorate_value' }

      it { is_expected.to be_truthy }
    end
  end

  describe '#decoreated_message' do
    subject { verifier_instance.decorated_message }

    let(:verifier_instance) { verifier_model.new token: token }
    let(:token) { verifier_model.generate value }
    let(:value) { 'value' }

    it { is_expected.to eq decorate_value }
  end

  describe '#original_message' do
    subject { verifier_instance.original_message }

    let(:verifier_instance) { verifier_model.new token: token }
    let(:token) { verifier_model.generate value }
    let(:value) { 'value' }
    let(:secret) { 'decorated_verifier' }
    let(:decorated_verifier) { ActiveSupport::MessageVerifier.new(secret) }
    let(:signed_decorate_value) { decorated_verifier.generate(decorate_value) }

    it { is_expected.to eq [value, signed_decorate_value] }
  end

  describe '#valid_message' do
    subject { verifier_instance.valid_message }

    let(:verifier_instance) { verifier_model.new token: token }
    let(:token) { verifier_model.generate value }
    let(:value) { 'value' }

    before do
      verifier_instance.define_singleton_method validate do
        decorated_message == 'decorate_value'
      end
    end

    context 'with invalid decorated message' do
      let(:decorate_value) { 'invalid_value' }

      it { is_expected.to be_falsy }
    end

    context 'with valid token' do
      let(:decorate_value) { 'decorate_value' }

      it { is_expected.to eq value }
    end
  end
end
