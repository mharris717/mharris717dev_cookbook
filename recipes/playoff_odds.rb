hosted_site "poweb" do
  checkout "https://github.com/mharris717/poweb.git"
  port 8086
  setup_command "bundle exec rake db:migrate"
  subdomain "playoffodds"
end

site_lib "playoff_odds" do
  checkout "git@github.com:mharris717/playoff_odds.git"
  init_command "rake monitor:daemon"
  init_dir "#{node[:mharris717][:site_libs_dir]}/playoff_odds/src"
end