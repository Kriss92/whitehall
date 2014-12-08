require 'test_helper'

class PublishingApiPresenters::UnpublishingTest < ActiveSupport::TestCase
  setup do
    @case_study = create(:draft_case_study,
                        title: 'Case study title',
                        first_published_at: Time.zone.now,
                        summary: 'The summary')
    @unpublishing = create(:unpublishing, edition: @case_study,
                          explanation: 'it is rubbish')
  end

  def present(edition, options = {})
    PublishingApiPresenters::Unpublishing.new(edition, options).as_json
  end

  test "presenter generates valid JSON according to the schema" do
    presented_json = present(@case_study).to_json

    validator = GovukContentSchema::Validator.new('unpublishing', presented_json)
    assert validator.valid?, "JSON not valid against unpublishing schema: #{validator.errors.to_s}"
  end

  test 'presents an unpublished edition' do
    public_path = Whitehall.url_maker.public_document_path(@case_study)
    expected_hash = {
      content_id: @case_study.document.content_id,
      title: 'Case study title',
      description: 'The summary',
      base_path: public_path,
      format: 'unpublishing',
      locale: 'en',
      need_ids: [],
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: @case_study.public_timestamp,
      update_type: 'major',
      routes: [
        { path: public_path, type: 'exact' }
      ],
      redirects: [],
      details: {
        explanation: "<div class=\"govspeak\"><p>it is rubbish</p></div>",
        unpublished_at: @unpublishing.created_at,
        alternative_url: ""
      }
    }

    assert_equal expected_hash, present(@case_study)
  end
end
