require "language/node"

class Cdk8s < Formula
  desc "Define k8s native apps and abstractions using object-oriented programming"
  homepage "https://cdk8s.io/"
  url "https://registry.npmjs.org/cdk8s-cli/-/cdk8s-cli-2.2.2.tgz"
  sha256 "139ac83a5df691b9faddd1fc15c62ad5376ea8d5363f34ce99324dc686ab6651"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "823a6ca8465d88242199209d6e9ae517bda0ec6ed761a3c1603289cd04179af7"
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match "Cannot initialize a project in a non-empty directory",
      shell_output("#{bin}/cdk8s init python-app 2>&1", 1)
  end
end
