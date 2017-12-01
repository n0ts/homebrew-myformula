class Anyenv < Formula
  desc "All in one for **env"
  homepage "https://github.com/riywo/anyenv"
  url "https://github.com/riywo/anyenv.git", :branch => "master"
  version "latest"

  def install
    prefix.install ["bin", "completions", "libexec", "share"]
  end

  test do
    system "#{bin}/anyenv", "--help"
  end
end
