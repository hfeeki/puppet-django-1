require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'django' do

  let(:title) { 'django' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) { { :ipaddress => '10.42.42.42' , :operatingsystem => 'Ubuntu' } }

  describe 'Test standard installation' do
    it { should contain_package('django').with_ensure('present') }
    it { should contain_file('django.conf').with_ensure('present') }
  end

  describe 'Test standard installation with monitoring' do
    let(:params) { {:monitor => true , :url_check => 'http://django.example42.com' } }
    let(:facts) { { :ipaddress => '10.42.42.42' , :operatingsystem => 'Ubuntu' } }

    it { should contain_file('django.conf').with_ensure('present') }
    it 'should monitor the url' do
      content = catalogue.resource('monitor::url', 'django_url').send(:parameters)[:enable]
      content.should == true
    end
  end

  describe 'Test source installation' do
    let(:params) { {:install => 'source' , :web_server => 'apache' } }
    let(:facts) { { :ipaddress => '10.42.42.42' , :operatingsystem => 'Ubuntu' } }

    it 'should contain a netinstall resource with valid destination_dir' do
      content = catalogue.resource('puppi::netinstall', 'netinstall_django').send(:parameters)[:destination_dir]
      content.should == '/var/www'
    end
  end

  describe 'Test puppi installation' do
    let(:params) { {:install => 'puppi' , :web_server => 'apache' } }
    let(:facts) { { :ipaddress => '10.42.42.42' , :operatingsystem => 'Ubuntu' } }

    it 'should contain a puppi  project resource with valid destination_dir' do
      content = catalogue.resource('puppi::project::archive', 'django').send(:parameters)[:deploy_root]
      content.should == '/var/www'
    end
  end

  describe 'Test decommissioning - absent' do
    let(:params) { {:absent => true, :monitor => true } }
    let(:facts) { { :ipaddress => '10.42.42.42' , :operatingsystem => 'Ubuntu' } }

    it 'should remove Package[django]' do should contain_package('django').with_ensure('absent') end 
    it 'should remove django configuration file' do should contain_file('django.conf').with_ensure('absent') end
  end

  describe 'Test customizations - template' do
    let(:params) { {:template => "django/spec.erb" , :options => { 'opt_a' => 'value_a' } } }
    let(:facts) { { :ipaddress => '10.42.42.42' , :operatingsystem => 'Ubuntu' } }

    it 'should generate a valid template' do
      content = catalogue.resource('file', 'django.conf').send(:parameters)[:content]
      content.should match "fqdn: rspec.example42.com"
    end
    it 'should generate a template that uses custom options' do
      content = catalogue.resource('file', 'django.conf').send(:parameters)[:content]
      content.should match "value_a"
    end

  end

  describe 'Test customizations - source' do
    let(:params) { {:source => "puppet://modules/django/spec" , :source_dir => "puppet://modules/django/dir/spec" , :source_dir_purge => true } }
    let(:facts) { { :ipaddress => '10.42.42.42' , :operatingsystem => 'Ubuntu' } }

    it 'should request a valid source ' do
      content = catalogue.resource('file', 'django.conf').send(:parameters)[:source]
      content.should == "puppet://modules/django/spec"
    end
    it 'should request a valid source dir' do
      content = catalogue.resource('file', 'django.dir').send(:parameters)[:source]
      content.should == "puppet://modules/django/dir/spec"
    end
    it 'should purge source dir if source_dir_purge is true' do
      content = catalogue.resource('file', 'django.dir').send(:parameters)[:purge]
      content.should == true
    end
  end

  describe 'Test customizations - custom class' do
    let(:params) { {:my_class => "django::spec" } }
    let(:facts) { { :ipaddress => '10.42.42.42' , :operatingsystem => 'Ubuntu' } }

    it 'should automatically include a custom class' do
      content = catalogue.resource('file', 'django.conf').send(:parameters)[:content]
      content.should match "fqdn: rspec.example42.com"
    end
  end

  describe 'Test Puppi Integration' do
    let(:params) { {:puppi => true, :puppi_helper => "myhelper"} }
    let(:facts) { { :ipaddress => '10.42.42.42' , :operatingsystem => 'Ubuntu' } }

    it 'should generate a puppi::ze define' do
      content = catalogue.resource('puppi::ze', 'django').send(:parameters)[:helper]
      content.should == "myhelper"
    end
  end

  describe 'Test params lookup' do
    let(:facts) { { :monitor => true , :ipaddress => '10.42.42.42' , :operatingsystem => 'Ubuntu'} }
    let(:params) { { :url_check => 'http://django.example42.com' } }

    it 'should honour top scope global vars' do
      content = catalogue.resource('monitor::url', 'django_url').send(:parameters)[:enable]
      content.should == true
    end
  end

  describe 'Test params lookup' do
    let(:facts) { { :django_monitor => true , :ipaddress => '10.42.42.42' , :operatingsystem => 'Ubuntu' } }
    let(:params) { { :url_check => 'http://django.example42.com' } }

    it 'should honour module specific vars' do
      content = catalogue.resource('monitor::url', 'django_url').send(:parameters)[:enable]
      content.should == true
    end
  end

  describe 'Test params lookup' do
    let(:facts) { { :monitor => false , :django_monitor => true , :ipaddress => '10.42.42.42' , :operatingsystem => 'Ubuntu' } }
    let(:params) { { :url_check => 'http://django.example42.com' } }

    it 'should honour top scope module specific over global vars' do
      content = catalogue.resource('monitor::url', 'django_url').send(:parameters)[:enable]
      content.should == true
    end
  end

  describe 'Test params lookup' do
    let(:facts) { { :monitor => false , :ipaddress => '10.42.42.42' , :operatingsystem => 'Ubuntu' } }
    let(:params) { { :monitor => true , :url_check => 'http://django.example42.com' } }

    it 'should honour passed params over global vars' do
      content = catalogue.resource('monitor::url', 'django_url').send(:parameters)[:enable]
      content.should == true
    end
  end

end

