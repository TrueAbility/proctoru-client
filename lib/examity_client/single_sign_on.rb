require "digest"
require "base64"

class ExamityClient::SingleSignOn
  # iv and secret key are the same
  ALG = "AES-128-CBC"

  # this token is used FOR SSO
  def self.token(key, email)
    digest = Digest::SHA1.new
    digest.update(key)

    key = key.byteslice(0, 16) # must be 16 bytes
    key64 = Base64.strict_encode64(key)

    aes = OpenSSL::Cipher.new(ALG)
    aes.encrypt
    aes.key = key
    aes.iv = key # key and iv are the same at Examity

    cipher = aes.update(email)
    cipher << aes.final
    cipher64 = Base64.strict_encode64(cipher)

    cipher64
  end
end
