module FromHash
  def from_hash(ops)
    ops.each do |k,v|
      send("#{k}=",v)
    end
    self
  end
  def initialize(ops={})
    from_hash(ops)
  end
end

class Class
  def self.from_hash(ops={})
    res = new
    res.from_hash(ops)
    res
  end
end

module MharrisDevCookbook
  class Site
    include FromHash
    attr_accessor :name, :port
    def site; name; end

    def site_dir; @site_dir ||= "#{self.class.sites_dir}/#{site}"; end
    def config_file; @config_file ||= "/etc/unicorn/#{site}.rb"; end
    def subdomain; @subdomain ||= site; end
    def init_file; @init_file ||= "/etc/init.d/unicorn_#{site}"; end
    def nginx_conf_file; @nginx_conf_file ||= "/etc/nginx/conf.d/#{site}.conf"; end
    attr_writer :site_dir, :config_file, :subdomain, :init_file, :nginx_config_file

    attr_accessor :checkout, :enable, :setup_command, :type, :static_subdir
    def type
      @type ||= :rails
    end

    def static_dir
      "#{site_dir}/#{static_subdir}"
    end

    def unicorn_path
      h = {:rails => "unicorn_rails", :rack => "unicorn", :static => "junkxyz"}
      bin = h[type] || (raise "bad type")
      "#{self.class.node[:ruby_bin_path]}/#{bin}"
    end

    def vars
      {:site => site, :site_dir => site_dir, :config_file => config_file, :subdomain => subdomain, :port => port, :type => type, 
        :static_dir => static_dir, :unicorn_path => unicorn_path}
    end

    def bundle?
      [:rails,:rack].include?(type)
    end
    def init?
      bundle?
    end

    class << self
      def all
        @all ||= []
      end
      def make(ops)
        res = new(ops)
        self.all << res
        res
      end
      attr_accessor :node
      def sites_dir
        node[:mharris717][:sites_dir]
      end
    end
  end
end


define :hosted_site, :enable => true do
  MharrisDevCookbook::Site.node = node
  include_recipe "unicorn"

  site = MharrisDevCookbook::Site.make(params)

  template site.init_file do
    source "unicorn/init.erb"
    mode "0700"
    owner "root"
    group "root"

    variables site.vars
  end

  template site.nginx_conf_file do
    source "unicorn/nginx.conf.erb"
    variables site.vars
  end

  unicorn_config site.config_file do
    listen({ site.port => node[:unicorn][:options] })
    working_directory site.site_dir
    worker_timeout node[:unicorn][:worker_timeout]
    preload_app node[:unicorn][:preload_app]
    worker_processes node[:unicorn][:worker_processes]
    before_fork node[:unicorn][:before_fork]
  end

  service "unicorn_#{site.site}" do
    action [:enable]
  end

  if false
    execute "bundle install #{site.site}" do
      cwd site.site_dir
      command "#{node[:bundle_path]} install"
    end
  end

  if site.checkout
    raise "bad checkout value #{site.checkout} for #{site.site}" unless site.checkout.kind_of?(String)
    git site.site_dir do
      repository site.checkout
      action :sync
    end
  end
end

define :hosted_static_site, :enable => true do
  MharrisDevCookbook::Site.node = node

  site = MharrisDevCookbook::Site.make(params.merge(:type => :static))

  if site.checkout
    raise "bad checkout value #{site.checkout} for #{site.site}" unless site.checkout.kind_of?(String)
    git site.site_dir do
      repository site.checkout
      action :sync
    end
  end
end

define :hosted_rack_site, :enable => true do
  MharrisDevCookbook::Site.node = node

  site = MharrisDevCookbook::Site.make(params.merge(:type => :rack))

  template site.init_file do
    source "unicorn/init.erb"
    mode "0700"
    owner "root"
    group "root"

    variables site.vars
  end

  template site.nginx_conf_file do
    source "unicorn/nginx.conf.erb"
    variables site.vars
  end

  unicorn_config site.config_file do
    listen({ site.port => node[:unicorn][:options] })
    working_directory site.site_dir
    worker_timeout node[:unicorn][:worker_timeout]
    preload_app node[:unicorn][:preload_app]
    worker_processes node[:unicorn][:worker_processes]
    before_fork node[:unicorn][:before_fork]
  end

  service "unicorn_#{site.site}" do
    action [:enable]
  end

  if site.checkout
    raise "bad checkout value #{site.checkout} for #{site.site}" unless site.checkout.kind_of?(String)
    git site.site_dir do
      repository site.checkout
      action :sync
    end
  end
end

define :nginx_for_hosted_sites do
  template "/etc/nginx/conf.d/zzz_server.conf" do
    source "nginx/server.conf.erb"
    variables :sites => MharrisDevCookbook::Site.all.map { |x| x.vars }
  end

  template "#{MharrisDevCookbook::Site.sites_dir}/full_setup" do
    source "unicorn/full_setup.erb"
    mode "0700"
    owner "root"
    group "root"

    variables :sites => MharrisDevCookbook::Site.all
  end
end