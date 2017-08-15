# pip install ecdsa
# pip install pysha3

import sys
import ecdsa
import sha3
import codecs

def sha512(s):
    hash = sha3.sha3_512()
    hash.update(s)
    return hash.hexdigest()

def get_node_id(name):
    priv = ecdsa.SigningKey.from_string(sha512(name)[:32], curve=ecdsa.SECP256k1)
    pub = priv.get_verifying_key()
    return codecs.encode(pub.to_string(), 'hex')

def get_addr_pk(name):
    priv = ecdsa.SigningKey.from_string(sha512(name)[:32], curve=ecdsa.SECP256k1)
    return priv

def get_addr_pub(name):
    priv = get_addr_pk(name)
    pub = priv.get_verifying_key().to_string()
    hash = sha3.keccak_256()
    hash.update(pub)
    return hash.hexdigest()[24:]

if __name__ == '__main__':
    type = sys.argv[1]
    if type == 'node-id':
        print get_node_id(sys.argv[2])
    elif type == 'addr':
        print "".join(["0x", get_addr_pub(sys.argv[2])])
    elif type == 'pk':
        print codecs.encode(get_addr_pk(sys.argv[2]).to_string(), 'hex')
    else:
        print "Unknown command"
