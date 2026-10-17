class Snapclip < Formula
  desc "Menu-bar app: screenshots auto-copy to clipboard and auto-clean after 5 minutes"
  homepage "https://github.com/0xnicholasy/snapclip"
  url "https://github.com/0xnicholasy/snapclip/archive/refs/tags/v0.1.5.tar.gz"
  sha256 "68ba0de2779de506746416463ec67eaf1522bb3e85ce063fe333c8773c035d2d"
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
