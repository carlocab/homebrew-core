class Mapserver < Formula
  desc "Publish spatial data and interactive mapping apps to the web"
  homepage "https://mapserver.org/"
  url "https://download.osgeo.org/mapserver/mapserver-8.0.1.tar.gz"
  sha256 "79d23595ef95d61d3d728ae5e60850a3dbfbf58a46953b4fdc8e6e0ffe5748ba"
  license "MIT"

  livecheck do
    url "https://mapserver.org/download.html"
    regex(/href=.*?mapserver[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 cellar: :any,                 arm64_ventura:  "bd6e36e5dd27044bb6bb76fa10b44bd43e43f48193d1820b34362ae7de4d3bdb"
    sha256 cellar: :any,                 arm64_monterey: "4d1d4906bb6cb9bd484b6c2c38a2ed7433105bf6d4df916f79621fdf1c205d18"
    sha256 cellar: :any,                 arm64_big_sur:  "0f785bee9e338033415641d5e44bf454335d03b114858096d073a110504d8578"
    sha256 cellar: :any,                 ventura:        "16a86032b66c2614905ff6d18ea3744cdba9d0383976cf1734f8aa200aaa3384"
    sha256 cellar: :any,                 monterey:       "90ad05f462d0c0116a3795a78602ebcec5091009277048c0fd0a5d5f479236f0"
    sha256 cellar: :any,                 big_sur:        "fb9ffdcd5bf3dfeb32944aff13f5dc4b88c38aada6e880fa819524d4d860cf27"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "a8b66c3644b17c553f6c3018654301a590979da0114d54857be99df1364cef1b"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "swig" => :build
  depends_on "cairo"
  depends_on "fcgi"
  depends_on "freetype"
  depends_on "gd"
  depends_on "gdal"
  depends_on "geos"
  depends_on "giflib"
  depends_on "libpng"
  depends_on "libpq"
  depends_on "proj"
  depends_on "protobuf-c"
  depends_on "python@3.11"

  uses_from_macos "curl"

  fails_with gcc: "5"

  def python3
    "python3.11"
  end

  # Respect configuration of `CMAKE_INSTALL_RPATH`
  # https://github.com/MapServer/MapServer/pull/6902
  patch do
    url "https://github.com/MapServer/MapServer/commit/6fbfecc81d4eaca193edad97c4c0b64baf308554.patch?full_index=1"
    sha256 "be4e0c35a29210b08d99adb662c6a72a39e969ec5dfdb122bfda1736df777f0b"
  end

  # Fix mapscript Python bindings RPATH
  patch :DATA

  def install
    # Install within our sandbox
    inreplace "mapscript/python/CMakeLists.txt", "${Python_LIBRARIES}", "-Wl,-undefined,dynamic_lookup" if OS.mac?

    mapscript_site_packages = prefix/Language::Python.site_packages(python3)/"mapscript"
    system "cmake", "-S", ".", "-B", "build",
                    "-DCMAKE_INSTALL_RPATH=#{rpath}",
                    "-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=OFF",
                    "-DMAPSCRIPT_INSTALL_RPATH=#{rpath(source: mapscript_site_packages)}",
                    "-DWITH_CLIENT_WFS=ON",
                    "-DWITH_CLIENT_WMS=ON",
                    "-DWITH_CURL=ON",
                    "-DWITH_FCGI=ON",
                    "-DWITH_FRIBIDI=OFF",
                    "-DWITH_GDAL=ON",
                    "-DWITH_GEOS=ON",
                    "-DWITH_HARFBUZZ=OFF",
                    "-DWITH_KML=ON",
                    "-DWITH_OGR=ON",
                    "-DWITH_POSTGIS=ON",
                    "-DWITH_PYTHON=ON",
                    "-DWITH_SOS=ON",
                    "-DWITH_WFS=ON",
                    "-DPYTHON_EXECUTABLE=#{which(python3)}",
                    "-DPHP_EXTENSION_DIR=#{lib}/php/extensions",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    cd "build/mapscript/python" do
      system python3, *Language::Python.setup_install_args(prefix, python3)
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mapserv -v")
    system python3, "-c", "import mapscript"
  end
end

__END__
diff --git a/CMakeLists.txt b/CMakeLists.txt
index 25b66be47..7d404f721 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -250,6 +250,7 @@ if(LINK_STATIC_LIBMAPSERVER)
 else(LINK_STATIC_LIBMAPSERVER)
   set(BUILD_DYNAMIC 1)
   set(MAPSERVER_LIBMAPSERVER mapserver)
+  set(MAPSCRIPT_INSTALL_RPATH "${CMAKE_INSTALL_RPATH}" CACHE STRING "INSTALL_RPATH for mapscript support")
 endif(LINK_STATIC_LIBMAPSERVER)
 
 set(agg_SOURCES
diff --git a/mapscript/python/CMakeLists.txt b/mapscript/python/CMakeLists.txt
index 9770cdd1c..2016538b1 100644
--- a/mapscript/python/CMakeLists.txt
+++ b/mapscript/python/CMakeLists.txt
@@ -27,6 +27,7 @@ else ()
 endif ()
 
 swig_link_libraries(pythonmapscript ${Python_LIBRARIES} ${MAPSERVER_LIBMAPSERVER})
+set_target_properties(pythonmapscript PROPERTIES INSTALL_RPATH ${MAPSCRIPT_INSTALL_RPATH})
 
 set_target_properties(${SWIG_MODULE_pythonmapscript_REAL_NAME} PROPERTIES PREFIX "")
 set_target_properties(${SWIG_MODULE_pythonmapscript_REAL_NAME} PROPERTIES OUTPUT_NAME _mapscript)
