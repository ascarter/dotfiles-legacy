module Actions
  module MacOS
    module_function

    def check_macos()
      raise 'macOS required' unless RUBY_PLATFORM =~ /darwin/
    end

    # Add path helper
    def pathhelper(args)
      check_macos
      label = args.delete('label')
      args.each { |t, p| Bootstrap::MacOSX.path_helper label, p, t }
    end

    # Remove path helper
    def rmpathhelper(args)
      check_macos
      label = args.delete('label')
      args.keys.each { |t| Bootstrap::MacOSX.rm_path_helper label, t}
    end
  end
end
