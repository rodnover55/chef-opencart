execute "#{node['deploy-project']['path']}/bin/install_steroids.sh" do
  cwd node['deploy-project']['path']
end