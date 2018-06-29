module Actions
  module MacOS
    # Add path helper
    def pathhelper(args)
      check_macos
      label = args.delete('label')
      args.each { |t, p| Bootstrap::MacOSX.path_helper label, p, t }
    end
    module_function :pathhelper

    # Remove path helper
    def rmpathhelper(args)
      check_macos
      label = args.delete('label')
      args.keys.each { |t| Bootstrap::MacOSX.rm_path_helper label, t}
    end
    module_function :rmpathhelper

    def check_macos()
      raise 'macOS required' unless RUBY_PLATFORM =~ /darwin/
    end
  end
end
