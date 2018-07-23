module Actions
  case RUBY_PLATFORM
  when /darwin/
    module MacOSActions
      module_function

      # Add path helper
      def pathhelper(args)
        label = args.delete('label')
        args.each { |t, p| MacOS.path_helper label, p, t }
      end

      # Remove path helper
      def rmpathhelper(args)
        label = args.delete('label')
        args.keys.each { |t| MacOS.rm_path_helper label, t}
      end

      # Run AppleScript
      def applescript(args)
        MacOS.run_applescript args
      end
    end
  end
end
