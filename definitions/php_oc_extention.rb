define :php_oc_extention, :module => nil, :action => nil, :config => nil, :type => 'module' do
  params[:module] ||= params[:name]

  if params[:action].is_a?(Hash)
    data = params[:action]
    action = params[:action]['action']
  else
    action = params[:action]
  end

  unless %w{install uninstall}.include?(action)
    raise "Set required params for module '#{params[:module]}'"
  end

  execute "php cli/index.php extensions/#{params[:type]} '#{action}' '#{params[:module]}'" do
    cwd node['deploy-project']['path']
  end

  unless data.nil?
    require 'json'

    json_data = data.to_json
    execute "echo '#{json_data}' | php cli/index.php extensions/#{params[:type]} 'configure' '#{params[:module]}'" do
      cwd node['deploy-project']['path']
    end
  end
end