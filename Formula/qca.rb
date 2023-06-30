class Qca < Formula
  desc "Qt Cryptographic Architecture (QCA)"
  homepage "https://userbase.kde.org/QCA"
  url "https://download.kde.org/stable/qca/2.3.6/qca-2.3.6.tar.xz"
  sha256 "ee59d531d4b82fb1685f4d8d74c2caa0777f501800f7426eaa372109a4305249"
  license "LGPL-2.1-or-later"
  revision 1
  head "https://invent.kde.org/libraries/qca.git", branch: "master"

  livecheck do
    url "https://download.kde.org/stable/qca/"
    regex(%r{href=["']?v?(\d+(?:\.\d+)+)/?["' >]}i)
  end

  bottle do
    sha256 cellar: :any,                 arm64_ventura:  "1ff65b5d3d3f160e001f1627be59bd075f53decddb467ab3f15ba434c71bbf87"
    sha256 cellar: :any,                 arm64_monterey: "1a6052b3caef256e2263278d89a915f716c6c8f04668e0080013d74112995722"
    sha256 cellar: :any,                 arm64_big_sur:  "2b2a7f272d61f10d263af3e33ac6b2f1c7ee4dba521d21ada0355d3f1416c4c2"
    sha256 cellar: :any,                 ventura:        "f34d1eb8064200969a6e65a4fe91b941b6c856204fdd2df114ae2c5b3abf6609"
    sha256 cellar: :any,                 monterey:       "42840a223240c8319029eb28554ce7b79caa442e76de760b099f777cf978f7f8"
    sha256 cellar: :any,                 big_sur:        "2cba7631886149287044b14e2c38b24a229577c4888d8b1db1fb035e4a363c20"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "35887790df6b8b5f6550dab9a212f5a0395dd04da45187179cd9e7065cc0dc27"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "botan"
  depends_on "ca-certificates"
  depends_on "gnupg"
  depends_on "libgcrypt"
  depends_on "nss"
  depends_on "openssl@3"
  depends_on "pkcs11-helper"
  depends_on "qt"

  fails_with gcc: "5"

  def install
    ENV["QC_CERTSTORE_PATH"] = Formula["ca-certificates"].pkgetc/"cert.pem"
    args = %W[
      -DBUILD_TESTS=OFF
      -DBUILD_WITH_QT6=ON
      -DQCA_PLUGINS_INSTALL_DIR=#{share}/qt/plugins
    ]
    args << "-DQCA_LIBRARY_INSTALL_DIR=#{frameworks}" if OS.mac?

    # Disable some plugins. qca-ossl, qca-cyrus-sasl, qca-logger,
    # qca-softstore are always built.
    %w[botan gcrypt gnupg nss pkcs11].each do |plugin|
      args << "-DWITH_#{plugin}_PLUGIN=ON"
    end

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    return unless OS.mac?

    lib.install_symlink (frameworks/"qca-qt6.framework/qca-qt6") => shared_library("libqca-qt6")
    (include/"Qca-qt6/QtCrypto").install_symlink (frameworks/"qca-qt6.framework/Headers").children
  end

  test do
    ENV["LC_ALL"] = "en_US.UTF-8"
    system bin/"qcatool-qt6", "--noprompt", "--newpass=",
                              "key", "make", "rsa", "2048", "test.key"
  end
end
