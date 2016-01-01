#!/bin/bash
set -xeo pipefail
source build-config.sh
source helpers/build-common.sh

sign_release () {
         sha1sum ${release} > ${1}.sha1
         md5sum ${release} > ${1}.md5
         gpg --sign --armor --detach  ${1}
         gpg --sign --armor --detach  ${1}.md5
         gpg --sign --armor --detach  ${1}.sha1
}
 cd $(pwd)/helpers/release-packages
 for pkg in * ; do 
    rm -rf ../../releases/${pkg}
    mv ${pkg} $(pwd)/releases/
 done
  if [ "${TYPE}" = "SIGNED" ] ; then
    ${DOCKERBIN} push mazaclub/electrum-grs-winbuild:${VERSION}
    ${DOCKERBIN} push mazaclub/electrum-grs-release:${VERSION}
#    ${DOCKERBIN} push mazaclub/electrum-grs32-release:${VERSION}
    ${DOCKERBIN} tag -f ogrisel/python-winbuilder mazaclub/python-winbuilder:${VERSION}
    ${DOCKERBIN} push mazaclub/python-winbuilder:${VERSION}
   fi
  if [ "${TYPE}" = "rc" ]; then export TYPE=SIGNED ; fi 
  if [ "${TYPE}" = "SIGNED" ] ; then
    cd releases
    for release in * 
    do
      if [ ! -d ${release} ]; then
         sign_release ${release}
      else
         cd ${release}
         for i in * 
         do 
           if [ ! -d ${i} ]; then
              sign_release ${i}
	   fi
         done
         cd ..
      fi
    done
  fi
  echo "You can find your Electrum-GRSs $VERSION binaries in the releases folder."
