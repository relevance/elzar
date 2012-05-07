require 'spec_helper'

describe Elzar::ChefDNA do
  let(:database) { 'mysql' }
  let(:json) {
    {
      "run_list" => ["role[plumbing]", "mysql::server", "role[enterprise_appstack]", "rails_app"],
      'ruby' => {'url' => '', 'version' => '', 'gems_version' => ''},
      'ruby_enterprise' => {'url' => '', 'version' => '', 'gems_version' => ''}
    }
  }
  let(:run_list) { json['run_list'] }

  def splice(database = nil)
    Elzar::ChefDNA.gene_splice(json, database, ruby_version)
  end

  describe '.gene_splice' do
    context 'for mri ruby' do
      let(:ruby_version) { 'ruby-1.9.3-p194' }

      it "updates run_list correctly for mysql" do
        splice 'mysql'
        run_list[1].should == 'mysql::server'
      end

      it "updates run_list correctly for mysql as default" do
        splice nil
        run_list[1].should == 'mysql::server'
      end

      it "updates run_list correctly for postgresql" do
        splice 'postgresql'
        run_list[1].should == 'role[postgres_database]'
      end

      it "updates ruby dna correctly" do
        splice
        json['ruby']['url'].should == "http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p194.tar.gz"
        json['ruby']['version'].should == '1.9.3-p194'
        json['ruby']['gems_version'].should == Gem::VERSION
        run_list[2].should == 'role[ruby_appstack]'
      end
    end

    context 'for ree' do
      let(:ruby_version) { 'ree-1.8.7-2011.03' }

      it "updates ree dna correctly" do
        splice
        json['ruby_enterprise']['url'].should == "http://rubyenterpriseedition.googlecode.com/files/ruby-enterprise-1.8.7-2011.03"
        json['ruby_enterprise']['version'].should == '1.8.7-2011.03'
        json['ruby_enterprise']['gems_version'].should == Gem::VERSION
        run_list[2].should == 'role[enterprise_appstack]'
      end
    end
  end
end
