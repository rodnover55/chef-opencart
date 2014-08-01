define :php_oc_extention, :module => nil, :action => nil, :config => nil, :type => 'module' do
  unless %w{install uninstall}.include?(params[:action])
    raise 'Set required params'
  end
  params[:module] ||= params[:name]
  execute "php cli/index.php extensions/#{params[:type]} '#{params[:action]}' '#{params[:module]}'" do
    command "php cli/index.php extensions/#{params[:type]} '#{params[:action]}' '#{params[:module]}'"
    cwd node['deploy-project']['path']
    action :run
  end
end