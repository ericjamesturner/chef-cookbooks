
cookbook_file "/etc/sudoers" do
  source "sudo"
  mode 440
end

