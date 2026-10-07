class Snapclip < Formula
  desc "Menu-bar app: screenshots auto-copy to clipboard and auto-clean after 5 minutes"
  homepage "https://github.com/0xnicholasy/snapclip"
  url "https://github.com/0xnicholasy/snapclip/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "d8ba8b13f36102c592d17512fd59efb5a3b962679ef08544658f3ec521807e19"
  license "MIT"

  depends_on xcode: ["16.0", :build]
  depends_on macos: :sonoma

  def install
    system "scripts/build-app.sh"
    prefix.install "build/SnapClip.app"
  end

  def caveats
    <<~EOS
      Link SnapClip into /Applications and launch it:
        ln -sf "#{opt_prefix}/SnapClip.app" /Applications/SnapClip.app
        open /Applications/SnapClip.app

      Enable "Start at Login" from the menu-bar icon.

      macOS asks for Desktop access on first run and again after each upgrade,
      because the app is ad-hoc signed.
    EOS
  end

  test do
    binary = prefix/"SnapClip.app/Contents/MacOS/SnapClip"
    assert_path_exists binary
    assert_predicate binary, :executable?
    system "codesign", "--verify", prefix/"SnapClip.app"
  end
end
