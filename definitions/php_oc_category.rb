define :php_oc_category, :image => nil, :keyword => nil, :description => nil do
  params[:keyword] ||= params[:name]

  require 'json'

  category_data = {
      keyword: params[:keyword],
      image: params[:image],
      description: params[:description]
  }.to_json

  execute "echo '#{category_data}' | php cli/index.php category" do
    cwd node['deploy-project']['path']
    action :run
  end

end