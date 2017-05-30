work_dir = Chef::Config['file_cache_path'] || '/tmp'

check_installed = "test -f #{node['unimrcp']['install_dir']}/plugin/mrcppocketsphinx.so"

remote_file "#{work_dir}/sphinxbase-0.8.tar.gz" do
  source 'http://downloads.sourceforge.net/project/cmusphinx/sphinxbase/0.8/sphinxbase-0.8.tar.gz'
  not_if check_installed
end

bash "build_sphinxbase" do
  user "root"
  cwd work_dir
  code <<-CODE
    tar -zxf sphinxbase-0.8.tar.gz
    cd sphinxbase-0.8
    ./configure --with-pic --disable-shared
    make
  CODE
  not_if check_installed
end

remote_file "#{work_dir}/pocketsphinx-0.8.tar.gz" do
  source 'http://downloads.sourceforge.net/project/cmusphinx/pocketsphinx/0.8/pocketsphinx-0.8.tar.gz'
  not_if check_installed
end

bash "build_pocketsphinx" do
  user "root"
  cwd work_dir
  code <<-CODE
    tar -zxf pocketsphinx-0.8.tar.gz
    cd pocketsphinx-0.8
    ./configure --with-pic --disable-shared
    make
  CODE
  not_if check_installed
end
