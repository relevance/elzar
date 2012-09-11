require 'spec_helper'
require 'tempfile'
require 'elzar/ssh_key_locator'

describe Elzar::SshKeyLocator do

  describe "#find_local_keys" do

    def create_key_file(seed, content)
      Tempfile.open(seed) do |f|
        f.write(content)
        f
      end
    end

    it "returns an array of keys from the first existing key file" do
      key_file_1 = create_key_file 'foo.pub', "foo\nbar"
      key_file_2 = create_key_file 'baz.pub', "baz"

      keys = Elzar::SshKeyLocator.find_local_keys(["/tmp/bogus.pub", key_file_1.path, key_file_2.path])
      keys.should == ['foo', 'bar']
    end

    it "returns an empty array when no key files are found" do
      keys = Elzar::SshKeyLocator.find_local_keys(["/tmp/bogus.pub"])
      keys.should == []
    end

    it "ignores blank lines in key files" do
      key_file = create_key_file 'foo.pub', "\nfoo\n\nbar"
      keys = Elzar::SshKeyLocator.find_local_keys([key_file.path])
      keys.should == ['foo', 'bar']
    end

  end

  describe "#find_keys" do
    it "returns the local keys when they exist" do
      Elzar::SshKeyLocator.should_receive(:find_local_keys).and_return ['some-local-key']
      Elzar::SshKeyLocator.find_keys.should == ['some-local-key']
    end

    it "returns the ssh-agent keys when no local keys exist" do
      Elzar::SshKeyLocator.stub(:find_local_keys).and_return []
      Elzar::SshKeyLocator.should_receive(:find_agent_keys).and_return ['some-agent-key']
      Elzar::SshKeyLocator.find_keys.should == ['some-agent-key']
    end
  end

end

