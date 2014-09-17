include_recipe 'deploy-project::enviroment'

db_name = node['deploy-project']['db']['database'] || node['deploy-project']['project']

directory "#{node['deploy-project']['path']}/system/cache/" do
  owner node['apache']['user']
  group node['apache']['group']
  action :create
end

directory "#{node['deploy-project']['path']}/image/cache/" do
  owner node['apache']['user']
  group node['apache']['group']
  action :create
end

template "#{node['deploy-project']['path']}/.htaccess" do
  if node['opencart']['htaccess'].nil?
    source 'htaccess.erb'
  else
    source node['opencart']['htaccess']['template']
    cookbook node['opencart']['htaccess']['cookbook']
  end

  owner node['apache']['user']
  group node['apache']['group']
end

unless node['opencart']['email'].nil? || node['opencart']['password'].nil?
  execute "php install/cli_install.php install --db_driver '#{node['deploy-project']['db']['provider']}' --db_host '#{node['deploy-project']['db']['host']}' --db_user '#{node['deploy-project']['db']['user']}' --db_password '#{node['deploy-project']['db']['password']}' --db_name '#{db_name}' --username 'admin' --password '#{node['opencart']['password']}' --email '#{node['opencart']['email']}' --agree_tnc yes --http_server 'http://#{node['deploy-project']['domain']}/'" do
    cwd node['deploy-project']['path']
    not_if { ::File.exists?("#{node['deploy-project']['path']}/config.php") ||
        ::File.exists?("#{node['deploy-project']['path']}/admin/config.php") ||
        ::File.exists?("#{node['deploy-project']['path']}/cli/config.php") }
  end
end

if node['opencart']['steroids']
  include_recipe 'opencart::steroids'
end

unless node['opencart']['db']['migrations'].nil?
  node['opencart']['db']['migrations'].each do |recipe|
    include_recipe recipe
  end
end

# unless node['opencart']['informations'].nil?
#   node['opencart']['informations'].each do |information|
#     php_oc_information information['template'] do
#       keyword information['keyword']
#       title information['title']
#       sort_order information['sort_order'] || 0
#       bottom information['bottom'] || 1
#       status information['status'] || 1
#       force information['force'] || false
#       unless information['id'].nil?
#         id information['id']
#       end
#     end
#   end
# end

unless node['opencart']['settings'].nil?
  node['opencart']['settings'].each do |group, settings|
    settings.each do |key, value|
      php_oc_setting key do
        group group
        value value
      end
    end
  end
end

unless node['opencart']['store'].nil?
  node['opencart']['store'].each do |key, value|
    execute "php cli/index.php store/configure '#{key}' '#{value}'" do
      cwd node['deploy-project']['path']
    end
  end
end

%w(modules payments feeds totals shippings).each do |extention|
  unless node['opencart'][extention].nil?
    node['opencart'][extention].each do |name, action|
      php_oc_extention name do
        action action
        type extention
      end
    end
  end
end

unless node['opencart']['permissions'].nil?
  node['opencart']['permissions'].each do |type, permissions|
    permissions.each do |page, permission|
      if permission.is_a?(Array)
        permission.each do |name|
          php_oc_permission name do
            type type
            page page
          end
        end
      else
        permission.each do |action, groups|
          groups.each do |name|
            php_oc_permission name do
              type type
              page page
              action action
            end
          end
        end
      end
    end
  end
end
#
# unless node['opencart']['geo_zones'].nil?
#   node['opencart']['geo_zones'].each do |geo_zone|
#     php_oc_geo_zone geo_zone['slug'] do
#       geo_zone_name geo_zone['name']
#       description geo_zone['description']
#       zones geo_zone['zones']
#     end
#   end
# end
#
# unless node['opencart']['tax_rates'].nil?
#   node['opencart']['tax_rates'].each do |tax_rate|
#     php_oc_tax_rate tax_rate['slug'] do
#       tax_rate_name tax_rate['name']
#       rate tax_rate['rate']
#       type tax_rate['type']
#       geo_zone tax_rate['geo_zone']
#     end
#   end
# end
#
# unless node['opencart']['tax_classes'].nil?
#   node['opencart']['tax_classes'].each do |tax_class|
#     php_oc_tax_class tax_class['slug'] do
#       title tax_class['title']
#       description tax_class['description']
#       tax_rule tax_class['tax_rule']
#     end
#   end
# end
#
# unless node['opencart']['languages'].nil?
#   node['opencart']['languages'].each do |language|
#     php_oc_language language['name'] do
#       code language['code']
#       locale language['locale']
#       image language['image']
#       directory language['directory']
#       filename language['filename']
#     end
#   end
# end
#
# unless node['opencart']['enabled_languages'].nil?
#   languages = node['opencart']['enabled_languages'].join(' ')
#   execute "php cli/index.php configure/enable_languages #{languages}" do
#     cwd node['deploy-project']['path']
#     action :run
#   end
# end
#
# unless node['opencart']['customers_groups'].nil?
#   node['opencart']['customers_groups'].each do |customer_group|
#     php_oc_customer_group customer_group['slug'] do
#       approval customer_group['approval']
#       sort_order customer_group['sort_order']
#       discount customer_group['discount']
#       discount_minimum customer_group['discount_minimum']
#       description customer_group['description']
#
#       unless customer_group['customer_group_id'].nil?
#         customer_group_id customer_group['customer_group_id']
#       end
#     end
#   end
# end
#
# unless node['opencart']['length_classes'].nil?
#   node['opencart']['length_classes'].each do |length|
#     php_oc_length length['slug'] do
#       value length['value']
#       description length['description']
#
#       unless length['length_class_id'].nil?
#         length_class_id length['length_class_id']
#       end
#     end
#   end
# end
#
#
# unless node['opencart']['banners'].nil?
#   node['opencart']['banners'].each do |banner|
#     php_oc_banner banner['name'] do
#       status banner['status'] || 1
#       force banner['force'] || false
#       images banner['banner_image']
#     end
#   end
# end
#
unless node['opencart']['categories'].nil?
  node['opencart']['categories'].each do |keyword, category|
    php_oc_category keyword do
      image category['image']
      description category['description']
    end
  end
end
#
# unless node['opencart']['currencies'].nil?
#   node['opencart']['currencies'].each do |currency|
#     php_oc_currency currency['code'] do
#       title currency['title']
#       symbol_left currency['symbol_left']
#       symbol_right currency['symbol_right']
#       decimal_place currency['decimal_place']
#       value currency['value']
#       status currency['status']
#     end
#   end
# end
#
# unless node['opencart']['enabled_currencies'].nil?
#   currencies = node['opencart']['enabled_currencies'].join(' ')
#   execute "php cli/index.php currency/enable #{currencies}" do
#     cwd node['deploy-project']['path']
#     action :run
#   end
# end
#
unless node['opencart']['layouts'].nil?
  node['opencart']['layouts'].each do |name, routes|
    php_oc_layout name do
      routes routes
    end
  end
end

execute "rm -rf #{node['deploy-project']['path']}/system/cache/*" do
  action :run
end