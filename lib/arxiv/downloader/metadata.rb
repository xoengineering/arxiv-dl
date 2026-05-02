module Arxiv
  module Downloader
    Metadata = Data.define(
      :arxiv_id,
      :arxiv_url,
      :pdf_url,
      :title,
      :authors,
      :abstract,
      :published,
      :updated,
      :primary_category,
      :categories,
      :comment,
      :doi,
      :journal_ref
    )
  end
end
