require 'rails_helper'

RSpec.describe UpdateTitleJob, type: :job do
  include ActiveJob::TestHelper

  let(:short_url) { ShortUrl.create(full_url: "https://www.beenverified.com/faq/") }
  let(:job) { UpdateTitleJob.perform_later(short_url.id) }

  it "updates the title" do
    expect(short_url.title).to be_nil
    perform_enqueued_jobs { job }
    short_url.reload
    expect(short_url.title).to eq("Frequently Asked Questions | BeenVerified")
  end

end
