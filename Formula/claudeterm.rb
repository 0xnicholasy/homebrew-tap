class Claudeterm < Formula
  desc "Native macOS terminal for Claude Code sessions, with the ccgovd memory daemon"
  homepage "https://github.com/0xnicholasy/claude-code-terminal"
  # Private repository: cloned over SSH, so your GitHub SSH key must be loaded.
  url "ssh://git@github.com/0xnicholasy/claude-code-terminal.git",
      using:    :git,
      tag:      "v0.1.7",
      revision: "5cb9fca0fc598b1b80151789f14e1be98d635786"
  head "ssh://git@github.com/0xnicholasy/claude-code-terminal.git", branch: "main", using: :git

  depends_on xcode: ["16.0", :build]
  depends_on "xcodegen" => :build
  depends_on macos: :sonoma

  def install
    ENV["CLAUDETERM_NO_SPM_SANDBOX"] = "1"
    system "scripts/build-app.sh"
    prefix.install "build/ClaudeTerm.app"

    cd "ccgovd" do
      args = ["--disable-sandbox", "-c", "release", "--scratch-path", buildpath/"build/ccgovd"]
      system "swift", "build", *args
      bin.install "#{Utils.safe_popen_read("swift", "build", *args, "--show-bin-path").chomp}/ccgovd"
    end
    pkgshare.install "ccgovd/hooks"
  end

  # Read-only by default: indexes sessions and measures memory, never signals them.
  service do
    run [opt_bin/"ccgovd", "run"]
    keep_alive successful_exit: false
    throttle_interval 30
    log_path var/"log/ccgovd.log"
    error_log_path var/"log/ccgovd.log"
  end

  def caveats
    <<~EOS
      Link ClaudeTerm into /Applications and launch it:
        ln -sf "#{opt_prefix}/ClaudeTerm.app" /Applications/ClaudeTerm.app
        open /Applications/ClaudeTerm.app

      Start the ccgovd daemon (read-only: lists and measures sessions):
        brew services start claudeterm

      To let it demote and hibernate idle sessions, run it with --govern instead:
        ccgovd run --govern

      Optional Claude Code hook: #{opt_pkgshare}/hooks/README.md
    EOS
  end

  test do
    assert_predicate prefix/"ClaudeTerm.app/Contents/MacOS/ClaudeTerm", :executable?
    system "codesign", "--verify", prefix/"ClaudeTerm.app"
    assert_match "usage: ccgovd run", shell_output("#{bin}/ccgovd 2>&1")
  end
end
