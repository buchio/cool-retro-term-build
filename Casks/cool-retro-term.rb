cask "cool-retro-term" do
  version "1.2.0-braille-patched" # This should be updated when releasing
  sha256 :no_check # Or specific checksum if automated

  url "https://github.com/buchio/cool-retro-term-build/releases/download/v#{version}/cool-retro-term.dmg"
  name "Cool Retro Term"
  desc "Terminal emulator which mimics the look and feel of the old cathode screens"
  homepage "https://github.com/Swordfish90/cool-retro-term"

  app "cool-retro-term.app"

  zap trash: [
    "~/Library/Application Support/cool-retro-term",
    "~/Library/Preferences/com.cool-retro-term.plist",
    "~/Library/Saved Application State/com.cool-retro-term.savedState",
  ]
end
