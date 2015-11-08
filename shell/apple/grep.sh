find . -name "*.*" | sed "s/ /\\\ /g" | xargs grep ISTAuthenticatorProtocol | grep -v build | grep -v svn
