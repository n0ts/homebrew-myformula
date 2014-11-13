require 'formula'

class MyEmacs < Formula
  homepage 'https://github.com/n0ts/homebrew-myformula'
  url 'http://ftp.gnu.org/pub/gnu/emacs/emacs-24.3.tar.gz'
  sha256 '0098ca3204813d69cd8412045ba33e8701fa2062f4bff56bedafc064979eef41'

  conflicts_with "emacs"

  depends_on :autoconf
  depends_on :automake


  patch :p1 do
    url "https://gist.github.com/anonymous/8553178/raw/c0ddb67b6e92da35a815d3465c633e036df1a105/emacs.memory.leak.aka.distnoted.patch.diff"
    sha1 "173ce253e0d8920e0aa7b1464d5635f6902c98e7"
  end

  patch :p0 do
    url "http://sourceforge.jp/projects/macemacsjp/svn/view/inline_patch/trunk/emacs-inline.patch?view=co&revision=583&root=macemacsjp"
    sha1 "61a6f41f3ddc9ecc3d7f57379b3dc195d7b9b5e2"
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
