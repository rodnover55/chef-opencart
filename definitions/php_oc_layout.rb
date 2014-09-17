define :php_oc_layout, :layout_name => nil, :routes => [] do
  params[:layout_name] ||= params[:name]

  require 'json'

  data = {
      name: params[:layout_name],
      routes: params[:routes]
  }

  json_data = data.to_json

  execute "echo '#{json_data}' | php cli/index.php layout" do
    cwd node['deploy-project']['path']
  end
end