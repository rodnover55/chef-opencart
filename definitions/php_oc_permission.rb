define :php_oc_permission, :action => 'add', :group => nil, :type => 'access', :page => nil do
  if params[:page].nil?
    raise 'Set required params'
  end
  params[:group] ||= params[:name]

  execute "php cli/index.php configure/permissions '#{params[:action]}' '#{params[:group]}' '#{params[:type]}' '#{params[:page]}'" do
    command "php cli/index.php configure/permissions '#{params[:action]}' '#{params[:group]}' '#{params[:type]}' '#{params[:page]}'"
    cwd node['deploy-project']['path']
    action :run
  end
end