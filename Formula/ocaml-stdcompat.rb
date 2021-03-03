class OcamlStdcompat < Formula
  desc "compatibility module for OCaml standard library"
  homepage "https://github.com/thierry-martinez/stdcompat"
  url "https://github.com/thierry-martinez/stdcompat/releases/download/v15/stdcompat-15.tar.gz"
  sha256 "5e746f68ffe451e7dabe9d961efeef36516b451f35a96e174b8f929a44599cf5"
  license "BSD-2-Clause"
  revision 1

  depends_on "automake" => :build
  depends_on "ocaml-findlib" => :build
  depends_on "ocaml"

  def install
    system "./configure"
    system "make -j1"
    system "make", "install"
  end

  test do
    system "make", "test"
  end
end
