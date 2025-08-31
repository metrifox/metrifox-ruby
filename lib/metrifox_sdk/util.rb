module MetrifoxSdk
  module UtilMethods
    def self.load_dotenv
      return if @dotenv_loaded

      env_files = ['.env.local', '.env']
      env_files.each do |file|
        next unless File.exist?(file)

        File.readlines(file).each do |line|
          line = line.strip
          next if line.empty? || line.start_with?('#')

          key, value = line.split('=', 2)
          next unless key && value

          # Remove quotes if present
          value = value.gsub(/\A['"]|['"]\z/, '')

          # Only set if not already set (allows override)
          ENV[key] ||= value
        end
        break # Use first found file
      end

      @dotenv_loaded = true
    end
  end
end