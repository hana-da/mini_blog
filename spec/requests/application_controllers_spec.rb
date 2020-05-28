# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ApplicationControllers', type: :request do
  context 'RAILS_ENV が production の時' do
    before do
      allow(Rails.env).to receive(:production?).and_return(true)
    end

    context '環境変数: BASIC_AUTH_USERNAMEが存在しないと' do
      before do
        stub_const('ENV', ENV.to_h.tap { |h| h.delete('BASIC_AUTH_USERNAME') })
      end

      it 'Basic認証はかかっていない' do
        get '/'
        expect(response).to have_http_status(:ok)
      end
    end

    context '環境変数: BASIC_AUTH_PASSWORDが存在しないと' do
      before do
        stub_const('ENV', ENV.to_h.tap { |h| h.delete('BASIC_AUTH_PASSWORD') })
      end

      it 'Basic認証はかかっていない' do
        get '/'
        expect(response).to have_http_status(:ok)
      end
    end

    context '認証情報を環境変数に登録していれば' do
      let(:username) { 'Someone' }
      let(:password) { 'to Watch Over Me' }

      before do
        stub_const('ENV', ENV.to_h.merge('BASIC_AUTH_USERNAME' => username,
                                         'BASIC_AUTH_PASSWORD' => password))
      end

      it 'Basic認証がかかっている(401 Unauthorized)' do
        get '/'

        expect(response).to have_http_status(:unauthorized)
      end

      it '認証情報が合致しない時も401 Unauthorized' do
        get '/', headers: { 'HTTP_AUTHORIZATION' => "Basic #{Base64.strict_encode64('evil:attack')}" }

        expect(response).to have_http_status(:unauthorized)
      end

      it '認証情報が合致すれば200 OKになる' do
        get '/', headers: { 'HTTP_AUTHORIZATION' => "Basic #{Base64.strict_encode64("#{username}:#{password}")}" }

        expect(response).to have_http_status(:ok)
      end
    end
  end

  context 'RAILS_ENV が production でない時' do
    before do
      allow(Rails.env).to receive(:production?).and_return(false)

      it 'Basic認証はかかっていない' do
        get '/'
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
