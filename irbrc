require 'irb/completion'
require 'irb/ext/save-history'
require 'pp'

alias q exit

IRB.conf[:AUTO_INDENT] = true
IRB.conf[:USE_READLINE] = true
IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_PATH] = File.expand_path("~/.irb_history")

# Show methods that are only available for given object
class Object
  def local_methods
    self.methods.sort - self.class.superclass.methods
  end
end

# Show schema
def show_schema(obj)
  y(obj.send("column_names"))
end

# BBEdit helper
def bbedit(*args)
  flattened_args = args.map { |arg| "\"#{arg.to_s}\"" }.join(' ')
  `bbedit #{flattened_args}`
  nil
end

# Vim helper
def vim(*args)
  flattened_args = args.map { |arg| "\"#{arg.to_s}\""}.join ' '
  `vim #{flattened_args}`
  nil
end
  
