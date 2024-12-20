module Website::Crawlable
  extend ActiveSupport::Concern

  def crawl!
    # TODO: Crawl URL content and save it in data
    self.data = url
    save!
  end
end
