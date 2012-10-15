#!/usr/bin/python

# pip install pycrypto

from Crypto.Cipher import PKCS1_OAEP
from Crypto.PublicKey import RSA
import base64
import struct
import sys

_START_TAG = (0xD0, 0x1F)
_END_TAG = (0x10, 0xAA)

_START_TAG_FORMAT = '<BB'
_START_TAG_TYPE_SIZE = 2
_VERSION_FORMAT = '<H'
_VERSION_TRPE_SIZE = 2
_CONTENT_LENGTH_FORMAT = '<H'
_CONTENT_LENGTH_TYPE_SIZE = 2
_END_TAG_FORMAT = '<BB'
_END_TAG_TYPE_SIZE = 2

def encrypt(publicKey, plainText):
    content = []
    content.append(struct.pack(_START_TAG_FORMAT, *_START_TAG)) #Start Tag
    content.append(struct.pack(_VERSION_FORMAT, 1))    #Version
    content.append(struct.pack(_CONTENT_LENGTH_FORMAT, len(plainText))) #Content Size
    content.append(plainText)
    content.append(struct.pack(_END_TAG_FORMAT, *_END_TAG))

    textToBeEncrypt = ''.join(content)
    cipher = PKCS1_OAEP.new(publicKey)
    return cipher.encrypt(textToBeEncrypt)

def decrypt(privateKey, cipherText):
    cipher = PKCS1_OAEP.new(privateKey)
    decryptedText = cipher.decrypt(cipherText)
    print "Decrypt: ", decryptedText

    position = 0
    startTag = struct.unpack_from(_START_TAG_FORMAT, decryptedText, position)
    if startTag != _START_TAG:
        raise "Invalid start tag"
    
    position += _START_TAG_TYPE_SIZE
    version = struct.unpack_from(_VERSION_FORMAT, decryptedText, position)
    if version[0] != 1:
        raise "Invalid version"

    position += _VERSION_TRPE_SIZE
    contentLength = struct.unpack_from(_CONTENT_LENGTH_FORMAT, decryptedText, position)[0]
    
    position += _CONTENT_LENGTH_TYPE_SIZE
    plainText = decryptedText[position : (position + contentLength)]

    endTag = struct.unpack_from(_END_TAG_FORMAT, decryptedText, position + contentLength)

    if endTag != _END_TAG:
        raise "Invalid end tag"

    return plainText

if __name__ == "__main__":
    publicKeyPath = sys.argv[1]
    privateKeyPath = sys.argv[2]
    text = sys.argv[3]

    publicKey = RSA.importKey(open(publicKeyPath).read())
    privateKey = RSA.importKey(open(privateKeyPath).read())

    cipherText = encrypt(publicKey, text)
    base64encoded = base64.urlsafe_b64encode(cipherText)
    print base64encoded
    plainText = decrypt(privateKey, cipherText)

    
    print text
#    print cipherText
    print plainText

    assert text == plainText
