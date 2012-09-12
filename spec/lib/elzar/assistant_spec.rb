require 'spec_helper'
require 'tempfile'

describe Elzar::Assistant do

  context '.validate_dna!' do

    def tempfile(content)
      Tempfile.open('dna-tmp') do |f|
        f.write(content)
        f
      end
    end

    it 'raises an error if the dna contains a TODO item' do
      dna_file = tempfile %Q[{\n"foo": "bar",\n"baz": "TODO - Fill out your baz"\n}]
      expect do
        Elzar::Assistant.validate_dna! dna_file.path
      end.to raise_error(Elzar::Assistant::InvalidDnaError, /dna\.json:3/)
    end

    it 'does not raise an error if the dna does not contain a TODO item' do
      dna_file = tempfile %Q[{\n"foo": "bar",\n"baz": "filled-out"\n}]
      expect do
        Elzar::Assistant.validate_dna! dna_file.path
      end.to_not raise_error(Elzar::Assistant::InvalidDnaError)
    end
  end

end
