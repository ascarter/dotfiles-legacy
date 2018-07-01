module Actions
  case RUBY_PLATFORM
  when /darwin/
    module MacOS
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
    end
  end
end
