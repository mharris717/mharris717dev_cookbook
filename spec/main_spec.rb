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

def mit(name,&b)
  Tests.mit(name,&b)
end

mit 'smoke' do
  2.should == 2
  vm_dir.should =~ /local/
end

mit 'cmd' do
  ec_guest("cat /vagrant/share/abc.txt").should == 'abc'
end

mit 'ruby' do
  ec_guest("ruby -v").should =~ /^ruby 1\.9\.3/
end

mit 'nginx base page' do
  `curl http://localhost:5150/basic/ 2>junk.txt`.strip.should == 'index {}'
end

mit 'ps' do
  ps.select { |x| x[:cmd] == "ruby main.rb -p 8080" }.size.should == 1
end

mit 'unicorn site running' do
  ps.select { |x| x[:cmd] =~ /unicorn/ }.should_not be_empty
end

mit 'unicorn page' do
  `curl http://localhost:5150/empty/pages 2>junk.txt`.strip.should == 'Index'
end

mit 'unicorn page 2' do
  `curl http://localhost:5150/empty_site2/pages 2>junk.txt`.strip.should == 'Index'
end

describe "basic tests" do
  before(:all) do
    if false
      puts "vagrant provision"
      puts `cd #{vm_dir} && vagrant provision`
      raise "bad provision" unless $?.success?
    end

    #ec_guest("sudo /etc/init.d/unicorn_empty_site start && sudo /etc/init.d/unicorn_empty_site2 start && sudo nginx -s stop && sudo nginx")
  end

  def vm_dir
    File.expand_path(File.dirname(__FILE__) + "/../../local")
  end

  def ec_guest(cmd)
    cmd = "cd #{vm_dir} && vagrant ssh -c '#{cmd}'"
    res = `#{cmd}`
    #puts res
    res
  end

  def ps
    ec_guest("ps ax").split("\n")[1..-1].map do |line|
      parts = line.split(/\s/).select { |x| x.present? }.map { |x| x.strip }
      {:pid => parts[0].to_i, :cmd => parts[4..-1].join(" ")}
    end
  end

  Tests.run! :all, self  
end