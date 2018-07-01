module Actions
  module Homebrew
    module_function

    # Install homebrew formula/tap
    def install(args)
      Bootstrap::Homebrew.update
      args.each do |k, v|
        case k
        when 'tools'
          v.each { |t| Bootstrap::Homebrew.install t }
        when 'taps'
          v.each do |t|
            parts = t.split('/')
            Bootstrap::Homebrew.tap(t)
            Bootstrap::Homebrew.install(parts[1], '--HEAD')
          end
        when 'overrides'
          v.each { |o| Bootstrap.usr_bin_ln(Bootstrap::Homebrew.bin_path(o), o) }
        end
      end
    end

    # Uninstall homebrew formula/tap
    def uninstall(args)
      args.each do |k, v|
        case k
        when 'tools'
          v.each { |t| Bootstrap::Homebrew.uninstall t }
        when 'taps'
          v.each { |t| Bootstrap::Homebrew.untap t }
        when 'overrides'
          v.each { |o| Bootstrap.usr_bin_rm o }
        end
      end
    end
  end
end
