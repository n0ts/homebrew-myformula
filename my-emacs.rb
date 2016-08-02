class MyEmacs < Formula
  homepage "https://github.com/n0ts/homebrew-myformula"
  url "http://ftp.gnu.org/pub/gnu/emacs/emacs-24.5.tar.xz"
  mirror "https://ftp.gnu.org/gnu/emacs/emacs-24.5.tar.xz"
  sha256 "dd47d71dd2a526cf6b47cb49af793ec2e26af69a0951cc40e43ae290eacfc34e"

  conflicts_with "emacs"

  depends_on "autoconf"
  depends_on "automake"

  patch :p1 do
    url "https://gist.githubusercontent.com/takaxp/1d91107b311b63b57529/raw/afcdd809e138a08c45a469e30aed9db0685aef3c/emacs-24.5-inline.patch"
    sha256 "5ab4cca25ab4d12c802b400a4eb0edcc182bbe97f5d203f7a3e69992be7622db"
  end

  # Follow MacPorts and don't install ctags from Emacs. This allows Vim
  # and Emacs and ctags to play together without violence.
  def do_not_install_ctags
    unless build.include? "keep-ctags"
      (bin/"ctags").unlink
      (man1/"ctags.1.gz").unlink
    end
  end

  def install
    args = ["--prefix=#{prefix}",
            "--without-dbus",
            "--enable-locallisppath=#{HOMEBREW_PREFIX}/share/emacs/site-lisp",
            "--infodir=#{info}/emacs"]
    args << "--with-ns" << "--disable-ns-self-contained" << "--without-x"
    system "./configure", *args
    system "make bootstrap"
    system "make install"
    prefix.install "nextstep/Emacs.app"

    # Don't cause ctags clash.
    do_not_install_ctags

    # Replace the symlink with one that avoids starting Cocoa.
    (bin/"emacs").unlink # Kill the existing symlink
    (bin/"emacs").write <<-EOS.undent
      #!/bin/bash
      #{prefix}/Emacs.app/Contents/MacOS/Emacs -nw  "$@"
    EOS

    system "ln -sf Emacs.app ~/Applications"
  end

  test do
    false
  end
end
