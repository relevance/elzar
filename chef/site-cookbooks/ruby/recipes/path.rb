#
# Cookbook Name:: ruby
# Recipe:: path
#
# Copyright 2012, Relevance
#
# All rights reserved - Do Not Redistribute

bash "Add ruby to each user's PATH" do
  code <<-SH
    for f in `ls /home/*/.bashrc`; do
      if ! grep -q "#{node[:ruby][:install_path]}" "$f"; then
        echo -e '\\nexport PATH="#{node[:ruby][:install_path]}/bin:$PATH"\\n' | sudo tee -a "$f"
      fi
    done
  SH
end
