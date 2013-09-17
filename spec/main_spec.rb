require 'mharris_ext'

class Tests
  class << self
    fattr(:instance) { new }
    def method_missing(sym,*args,&b)
      instance.send(sym,*args,&b)
    end
  end

  fattr(:list) { [] }

  def mit(name,&b)
    self.list << Test.new(:name => name, :block => b)
  end

  def runx!(name,context)
    tests = list.select { |x| x.name == name }
    context.describe "vm tests" do
      tests.each do |t|
        t.run!(self)
      end
    end
  end

  def run!(name,context)
    tests = list.select { |x| x.name == name || name == :all }
    tests.each do |t|
      t.run!(context)
    end
  end

  class Test
    include FromHash
    attr_accessor :name, :block

    def run!(context)
      context.it(name,&block)
    end
  end
end

class Conn
  fattr(:ssh) do
    require 'net/ssh'
    Net::SSH.start('127.0.0.1','vagrant', 
      :port => 2222, 
      :keys => ["/Users/mharris717/.vagrant.d/insecure_private_key","/users/mharris717/.ssh/id_rsa"])
  end
  def run(cmd)
    ssh.exec!(cmd)
  end

  class << self
    fattr(:instance) { new }
    def run(cmd)
      instance.run(cmd)
    end
  end
end

def mit(name,&b)
  Tests.mit(name,&b)
end

mit 'smoke' do
  #ec_guest "sudo /var/sites/full_setup"
  2.should == 2
  vm_dir.should =~ /local/
end

mit 'cmd' do
  ec_guest("cat /vagrant/share/abc.txt").should == 'abc'
end

#mit 'ruby' do
#  ec_guest("ruby -v").should =~ /^ruby 1\.9\.3/
#end

mit 'nginx base page' do
  curl("basic/").should == 'index {}'
end

mit 'ps' do
  ps.select { |x| x[:cmd] == "ruby main.rb -p 8080" }.size.should == 1
end

mit 'unicorn site running' do
  ps.select { |x| x[:cmd] =~ /unicorn/ }.should_not be_empty
end

mit 'unicorn page' do
  curl("empty/pages").should == 'Index'
end

mit 'ascension cards' do
  curl("ascension_ws/cards").should =~ /\{"cards"/
end

mit 'mongo test' do
  source = File.dirname(__FILE__) + "/mongo_test.js"
  with_vm_file(source) do |target|
    res = ec_guest("mongo localhost/specdb #{target}")
    res.strip.split("\n")[2..-1].should == %w(0 3 2)
  end
end


describe "basic tests" do
  before(:all) do
    if false
      puts "vagrant provision"
      puts `cd #{vm_dir} && vagrant provision`
      raise "bad provision" unless $?.success?
    end

    #ec_guest "sudo /var/sites/full_setup"

    #ec_guest("sudo /etc/init.d/unicorn_empty_site start && sudo /etc/init.d/unicorn_empty_site2 start && sudo nginx -s stop && sudo nginx")
  end

  let(:conn) do
    Conn.new
  end

  def vm_dir
    File.expand_path(File.dirname(__FILE__) + "/../../local")
  end

  def ec_guest_old(cmd)
    cmd = "cd #{vm_dir} && vagrant ssh -c '#{cmd}'"
    res = `#{cmd}`
    #puts res
    res
  end

  def ec_guest(cmd)
    conn.run cmd
  end

  def ps
    ec_guest("ps ax").split("\n")[1..-1].map do |line|
      parts = line.split(/\s/).select { |x| x.present? }.map { |x| x.strip }
      {:pid => parts[0].to_i, :cmd => parts[4..-1].join(" ")}
    end
  end

  def curlx(url)
    puts "curl start"
    res = `curl http://localhost:5150/#{url} 2>junk.txt`.strip
    puts "curl over"
    res
  end

  def curl(url)
    url = "http://localhost:5150/#{url}"
    require 'open-uri'
    open(url).read
  end

  def with_vm_file(source,&b)
    ext = source.split(".").last
    body = File.read(source)
    scratch = File.expand_path(File.dirname(__FILE__) + "/../../local/scratch")
    target_base = "#{rand(100000000000)}.#{ext}"
    target = "#{scratch}/#{target_base}"
    vm_target = "/vagrant/scratch/#{target_base}"
    File.create target, body
    yield(vm_target)
  ensure 
    FileUtils.rm target
  end

  Tests.run! :all, self  
end