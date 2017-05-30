work_dir = Chef::Config['file_cache_path'] || '/tmp'

check_installed = "test -f #{node['unimrcp']['install_dir']}/plugin/mrcpflite.so || test -f #{File.join(work_dir, 'flite-1.3.99/build/x86_64-linux-gnu/lib/libflite.a')}"

remote_file "#{work_dir}/flite-1.3.99-latest.tar.gz" do
  source 'http://unimrcp.net/files/flite-1.3.99-latest.tar.gz'
  not_if check_installed
end

bash "build_flite" do
  user "root"
  cwd work_dir
  code <<-CODE
    tar -zxf flite-1.3.99-latest.tar.gz
    cd flite-1.3.99
    ./configure --with-pic --disable-shared
    make
  CODE
  not_if check_installed
end
