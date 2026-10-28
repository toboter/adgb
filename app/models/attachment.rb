class Attachment < ApplicationRecord
  belongs_to :source

  # file_id is the stable Babili slug. Absolute URLs are derived from the current
  # provider_site so domain changes do not require rewriting persisted rows.
  def file_url
    return if file_id.blank?

    "#{provider_origin}/raw/files/#{CGI.escape(file_id)}/view?version=large"
  end

  def html_url
    return if file_id.blank?

    "#{provider_origin}/raw/files/#{CGI.escape(file_id)}"
  end

  private

  def provider_origin
    Rails.application.credentials.provider_site.to_s.sub(%r{/\z}, "")
  end
end
