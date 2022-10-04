class Makepkg < Formula
  desc "Compile and build packages suitable for installation with pacman"
  homepage "https://wiki.archlinux.org/index.php/makepkg"
  url "https://gitlab.archlinux.org/pacman/pacman.git",
      tag:      "v6.0.1",
      revision: "0a6fecd07271a54d9009ea7204c0e6288a44212b"
  license "GPL-2.0"
  head "https://gitlab.archlinux.org/pacman/pacman.git", branch: "master"

  bottle do
    rebuild 2
    sha256 catalina:    "fb89c76eb6c2a50b14d2380ad1440b37f96e86f39d5bd60378ab5ac85cd02b08"
    sha256 mojave:      "b6606a63e0727072c1016ffa8b60db28de0de67d3b5d3f495aa8d0728b7325c9"
    sha256 high_sierra: "c8f2f6999669c56b5e40e2608ad1e0adfe2c8eb73f8cef959a229856d21da6ed"
  end

  depends_on "asciidoc" => :build
  depends_on "docbook-xsl" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.10" => :build
  depends_on "bash"
  depends_on "fakeroot"
  depends_on "gettext"
  depends_on "libarchive"
  depends_on "openssl@1.1"

  uses_from_macos "m4" => :build
  uses_from_macos "libxslt"

  def install
    ENV["XML_CATALOG_FILES"] = etc/"xml/catalog"

    system "meson", "setup", "build", "-Dmakepkg-template-dir=#{share}/makepkg-template",
                                      "-Dsysconfdir=#{etc}", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    (testpath/"PKGBUILD").write <<~EOS
      source=(https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/androidnetworktester/10kb.txt)
      pkgrel=0
      pkgver=0
    EOS
    assert_match "md5sums=('e232a2683c0", pipe_output("#{bin}/makepkg -dg 2>&1")
  end
end
