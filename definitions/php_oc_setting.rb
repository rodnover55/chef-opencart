define :php_oc_setting, :group => nil, :key => nil, :value => nil do
  if params[:group].nil?
    raise 'Set required params'
  end
  params[:key] ||= params[:name]
  if params[:value].nil?
    params[:value] = ''
  end
  execute "php cli/index.php configure '#{params[:group]}' '#{params[:key]}' '#{params[:value]}'" do
    command "php cli/index.php configure '#{params[:group]}' '#{params[:key]}' '#{params[:value]}'"
    cwd node['deploy-project']['path']
    action :run
  end
end