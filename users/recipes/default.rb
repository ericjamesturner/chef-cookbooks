#
# Cookbook Name:: users
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

node[:purge_users].each do |u|
  user u do
    action :delete
  end
end

search(:users).each do |u|
  user u.id do
    comment u[:fullname]
    shell "/bin/bash"
    manage_home true
  end

  cookbook_file "/home/#{u.id}/.prompt" do
    source 'prompt'
  end

  cookbook_file "/home/#{u.id}/.vimrc" do
    action :create_if_missing
    source 'vimrc'
  end

  ruby_block "add .prompt for #{u.id}" do
    not_if "grep 'source ~/.prompt' /home/#{u.id}/.profile"
    block do
      f=Chef::Util::FileEdit.new("/home/#{u.id}/.profile")
      f.insert_line_if_no_match(/.prompt/,"source ~/.prompt")
      f.write_file
    end
  end

  directory "/home/#{u.id}/.ssh" do
    user u.id
    group u.id
  end

  file "/home/#{u.id}/.ssh/authorized_keys" do
    content u[:ssh_key]
  end

  if u[:sudo]
    group "Give sudo access to #{u.id}" do
      group_name 'adm'
      members u.id
      append true
    end
  end
  #

end


