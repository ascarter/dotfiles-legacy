# Spectacle tasks
# https://www.spectacleapp.com

require 'json'

SPECTACLE_APP_NAME = 'Spectacle'.freeze
SPECTACLE_SOURCE_URL = 'https://s3.amazonaws.com/spectacle/downloads/Spectacle+1.2.zip'.freeze

SPECTACLE_SHORTCUTS_FILE = File.join(Bootstrap.library_dir(), "Application Support", "Spectacle", "Shortcuts.json")
SPECTACLE_SHORTCUTS = [
  {
    shortcut_key_binding: "alt+shift+cmd+z",
    shortcut_name: "RedoLastMove"
  },
  {
    shortcut_key_binding: "ctrl+cmd+pageup",
    shortcut_name: "MakeSmaller"
  },
  {
    shortcut_key_binding: "ctrl+alt+cmd+pagedown",
    shortcut_name: "MoveToLowerRight"
  },
  {
    shortcut_key_binding: "ctrl+alt+cmd+pageup",
    shortcut_name: "MoveToUpperRight"
  },
  {
    shortcut_key_binding: "ctrl+alt+cmd+down",
    shortcut_name: "MoveToBottomHalf"
  },
  {
    shortcut_key_binding: "ctrl+alt+pagedown",
    shortcut_name: "MoveToNextDisplay"
  },
  {
    shortcut_key_binding: "ctrl+alt+cmd+up",
    shortcut_name: "MoveToTopHalf"
  },
  {
    shortcut_key_binding: "ctrl+alt+cmd+end",
    shortcut_name: "MoveToLowerLeft"
  },
  {
    shortcut_key_binding: "ctrl+cmd+pagedown",
    shortcut_name: "MakeLarger"
  },
  {
    shortcut_key_binding: "alt+cmd+z",
    shortcut_name: "UndoLastMove"
  },
  {
    shortcut_key_binding: "ctrl+alt+pageup",
    shortcut_name: "MoveToPreviousDisplay"
  },
  {
    shortcut_key_binding: "alt+cmd+f",
    shortcut_name: "MoveToFullscreen"
  },
  {
    shortcut_key_binding: "ctrl+cmd+end",
    shortcut_name: "MoveToNextThird"
  },
  {
    shortcut_key_binding: "ctrl+alt+cmd+left",
    shortcut_name: "MoveToLeftHalf"
  },
  {
    shortcut_key_binding: "alt+cmd+c",
    shortcut_name: "MoveToCenter"
  },
  {
    shortcut_key_binding: "ctrl+alt+cmd+right",
    shortcut_name: "MoveToRightHalf"
  },
  {
    shortcut_key_binding: "ctrl+alt+cmd+home",
    shortcut_name: "MoveToUpperLeft"
  },
  {
    shortcut_key_binding: "ctrl+cmd+home",
    shortcut_name: "MoveToPreviousThird"
  }
]

namespace 'spectacle' do
  desc 'Install Spectacle'
  task :install do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.install(SPECTACLE_APP_NAME, SPECTACLE_SOURCE_URL)
    end
  end

  desc 'Uninstall Spectacle'
  task :uninstall do
    case RUBY_PLATFORM
    when /darwin/
      Bootstrap::MacOSX::App.uninstall(SPECTACLE_APP_NAME)
    end
  end

  desc 'Set Spectacle hotkeys'
  task :hotkeys do
    case RUBY_PLATFORM
    when /darwin/
      support_dir = File.dirname(SPECTACLE_SHORTCUTS_FILE)
      Bootstrap.backup(SPECTACLE_SHORTCUTS_FILE)
      FileUtils.mkdir_p(support_dir)
      File.open(SPECTACLE_SHORTCUTS_FILE, 'w') do |f|
        f.write(JSON.pretty_generate(SPECTACLE_SHORTCUTS))
      end
    end
  end
end
