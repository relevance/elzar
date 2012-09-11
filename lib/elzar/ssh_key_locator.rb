module Elzar
  class SshKeyLocator

    def self.default_key_file_paths
      %w[id_dsa.pub id_ecdsa.pub id_rsa.pub].map do |base_filename|
        File.expand_path("~/.ssh/#{base_filename}")
      end
    end

    def self.find_local_keys(candidate_key_file_paths = default_key_file_paths)
      first_existing_file = candidate_key_file_paths.find { |p| File.exist?(p) }
      return [] unless first_existing_file

      file_content = File.read(first_existing_file)
      split_keys(file_content)
    end

    def self.split_keys(s)
      s.split("\n").reject { |k| k.strip.empty? }
    end

  end
end
