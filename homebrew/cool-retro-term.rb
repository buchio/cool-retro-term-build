class CoolRetroTerm < Formula
  desc "Terminal emulator which mimics the look and feel of the old cathode screens"
  homepage "https://github.com/Swordfish90/cool-retro-term"
  head "https://github.com/Swordfish90/cool-retro-term.git", recursive: true

  depends_on "qt@5"

  def install
    # Locate build-macos.sh in the same directory as this Formula
    # This works when checking out the repo as a Tap or installing from local file
    script_src = "#{File.dirname(__FILE__)}/build-macos.sh"
    
    unless File.exist?(script_src)
      odie "build-macos.sh not found at #{script_src}"
    end

    # Copy script to build directory
    cp script_src, "build-macos.sh"
    chmod 0755, "build-macos.sh"

    # Set environment variable to skip DMG creation
    ENV["SKIP_DMG"] = "1"

    # Run the build script
    system "./build-macos.sh"

    # Install the app bundle
    prefix.install "cool-retro-term.app"
    
    # Create the binary alias
    bin.write_exec_script "#{prefix}/cool-retro-term.app/Contents/MacOS/cool-retro-term"
  end

  test do
    system "#{bin}/cool-retro-term", "--help"
  end
end
