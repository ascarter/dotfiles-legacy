require 'digest'

module Verification
  module_function

  # Digest
  def sha1(path)
    if File.exist?(path)
      contents = File.read(path)
      return Digest::SHA1.hexdigest(contents)
    end
  end

  def sha256(path)
    if File.exist?(path)
      contents = File.read(path)
      return Digest::SHA256.hexdigest(contents)
    end
  end

  # GPG
  def gpg(target, sig)
    `gpg --verify #{sig} #{target}`
  end

  # PGP
  def pgp(sig)
    system "keybase pgp verify -m '#{sig}'"
    return $?
  end
end
