class AddShortCodeToShortUrls < ActiveRecord::Migration[6.0]
  def change
    add_column :short_urls, :short_code, :string
  end
end
