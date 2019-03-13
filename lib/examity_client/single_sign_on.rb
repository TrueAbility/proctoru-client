require "digest"
class ExamityClient::SingleSignOn
  # iv and secret key are the same
  ALG = "AES-128-CBC"

  # this token is used FOR SSO
  def self.token(encryption_key, email)
    digest = Digest::SHA1.new
    digest.update(encryption_key)
    key = digest.digest

    key = key.byteslice(0, 16) # must be 16 bytes


    key64 = [key].pack("m")
    aes = OpenSSL::Cipher.new(ALG)
    aes.encrypt
    aes.key = key
    aes.iv = key # key and iv are the same at Examity

    cipher = aes.update(email)
    cipher << aes.final
    cipher64 = [cipher].pack('m')
    cipher64
  end
end
