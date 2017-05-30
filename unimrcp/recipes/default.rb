include_recipe 'build-essential'

case node['platform_family']
when 'debian'
  package 'pkg-config'
end

unimrcp_name = "uni-ast-package-#{node['unimrcp']['version']}"
work_dir = Chef::Config['file_cache_path'] || '/tmp'
node.default['unimrcp']['src_dir'] = unimrcp_src_dir = "#{work_dir}/#{unimrcp_name}"

target_dir = node['unimrcp']['install_dir']

apr_src_dir = "#{unimrcp_src_dir}/unimrcp/libs/apr"

check_installed = "test -f #{target_dir}/lib/libunimrcpclient.a"

configure_line = "./configure --prefix=#{target_dir} --with-apr=#{target_dir} --with-apr-util=#{target_dir}"

if node['unimrcp']['install_flite']
  include_recipe 'unimrcp::flite'
  configure_line << " --enable-flite-plugin --with-flite=#{File.join(work_dir, 'flite-1.3.99')}"
  check_installed << " && test -f #{target_dir}/plugin/mrcpflite.so"
end

if node['unimrcp']['install_pocketsphinx']
  include_recipe 'unimrcp::pocketsphinx'
  configure_line << " --enable-pocketsphinx-plugin --with-pocketsphinx=#{File.join(work_dir, 'pocketsphinx-0.8')} --with-sphinxbase=#{File.join(work_dir, 'sphinxbase-0.8')}"
  check_installed << " && test -f #{target_dir}/plugin/mrcppocketsphinx.so"
end

remote_file "#{work_dir}/#{unimrcp_name}.tar.gz" do
  source "http://unimrcp.googlecode.com/files/#{unimrcp_name}.tar.gz"
  not_if check_installed
end

bash "prepare_dir" do
  user "root"
  cwd work_dir
  code "tar -zxf #{unimrcp_name}.tar.gz"
  not_if check_installed
end

bash "install_apr" do
  user "root"
  cwd apr_src_dir
  code <<-EOH
    ./configure --prefix=#{target_dir}
    make
    make install
  EOH
  not_if "test -f #{target_dir}/lib/libapr-1.a"
end

bash "install_apr_util" do
  user "root"
  cwd "#{unimrcp_src_dir}/unimrcp/libs/apr-util"
  code <<-EOH
    ./configure --prefix=#{target_dir} --with-apr=#{apr_src_dir}
    make
    make install
  EOH
  not_if "test -f #{target_dir}/lib/libaprutil-1.a"
end

bash "install_sofia" do
  user "root"
  cwd "#{unimrcp_src_dir}/unimrcp/libs/sofia-sip"
  code <<-EOH
    ./configure --with-glib=no
    make
    make install
  EOH
  not_if 'test -f /usr/local/lib/libsofia-sip-ua.a'
end

bash "install_unimrcp" do
  user "root"
  cwd "#{unimrcp_src_dir}/unimrcp"
  code <<-EOH
    #{configure_line}
    make
    make install
  EOH
  not_if check_installed
end

if node['unimrcp']['install_pocketsphinx']
  remote_file "#{work_dir}/communicator.tar.gz" do
    source "http://files.freeswitch.org/downloads/libs/communicator_semi_6000_20080321.tar.gz"
    not_if "test -d #{target_dir}/data/Communicator_semi_40.cd_semi_6000"
    retries 10
    checksum '504941aa35924af84cee1bf61914d923'
    notifies :run, 'bash[extract_pocketsphinx_communicator]', :immediately
  end

  bash "extract_pocketsphinx_communicator" do
    cwd work_dir
    code "tar --extract --file communicator.tar.gz --directory #{target_dir}/data"
    action :nothing
  end
end

bash "ldconfig" do
  user "root"
  code 'ldconfig'
end
