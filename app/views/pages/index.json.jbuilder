json.array!(@pages) do |page|
  json.extract! page, :id, :parent_id, :name, :title, :body, :reference
  json.url page_url(page, format: :json)
end
