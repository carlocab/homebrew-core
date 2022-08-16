class Liboqs < Formula
  desc "Library for quantum-safe cryptography"
  homepage "https://openquantumsafe.org/"
  url "https://github.com/open-quantum-safe/liboqs/archive/0.7.1.tar.gz"
  sha256 "c8a1ffcfd4facc90916557c0efae9a28c46e803b088d0cb32ee7b0b010555d3a"
  license "MIT"
  head "https://github.com/open-quantum-safe/liboqs.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any,                 arm64_monterey: "ae18883dbc2f1a7cef2be0fa53639b3d3622d20989865050372fe5facaced6ee"
    sha256 cellar: :any,                 arm64_big_sur:  "19c321ef0d8849fd71bf1f559cab3eab9ddb312ef15de2af5eeb40b6d07b8dd6"
    sha256 cellar: :any,                 monterey:       "413c2c6b86b61989e040d7c3652863ccf37552d9479cecdf4ded3f7b787768f2"
    sha256 cellar: :any,                 big_sur:        "7ae518ce5f8519e009182f88f6365b306ef6940c892c938312ff82f0dcd4bef4"
    sha256 cellar: :any,                 catalina:       "c304ee2212e895d3a5e0622aeb0dd9c4ee182a4042463b43ef71270ba369e5ca"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "3bbefa0b3f582716421ea7eac2a11426252edc323d2e3fbb5e3eb40a24f53ffd"
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "openssl@1.1"

  on_linux do
    depends_on "gcc"
  end

  fails_with gcc: "5"

  def install
    # FIXME: The runtime_cpu_detection audit fails on Catalina, even if we don't use it there.
    optflags = if MacOS.version >= :big_sur || OS.linux?
      ENV.runtime_cpu_detection
      ["-DOQS_DIST_BUILD=ON"] # enable runtime cpu detection
    else
      # Setting `OQS_DIST_BUILD=ON` fails on Catalina.
      ["-DOQS_DIST_BUILD=OFF", "-DOQS_OPT_TARGET=#{Hardware.oldest_cpu}"]
    end

    system "cmake", "-S", ".", "-B", "build",
                    "-G", "Ninja",
                    "-DBUILD_SHARED_LIBS=ON",
                    "-DOQS_USE_OPENSSL=ON",
                    "-DOPENSSL_ROOT_DIR=#{Formula["openssl@1.1"].opt_prefix}",
                    "-DCMAKE_INSTALL_RPATH=#{rpath}", # Make sure test executables have the right RPATHs
                    "-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON", # Avoid including build directory in RPATHs
                    *optflags, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    libexec.install (buildpath/"build/tests").children.select(&:executable?)
  end

  test do
    assert_match "operations completed", shell_output(libexec/"example_kem")
  end
end
