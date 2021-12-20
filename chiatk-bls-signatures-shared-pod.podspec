#
# To validate podspec run
# pod spec lint chiatk-bls-signatures-shared-pod.podspec --no-clean --verbose --allow-warnings --skip-import-validation
#
# To submit podspec to the CocoaPods trunk:
# pod trunk push --allow-warnings --skip-import-validation
# 
# Requirements: cmake
#

Pod::Spec.new do |s|
  s.name             = 'chiatk-bls-signatures-shared-pod'
  s.version          = '1.0.83'
  s.summary          = 'BLS signatures in C++, using the relic toolkit'

  s.description      = <<-DESC
Implements BLS signatures with aggregation as in Boneh, Drijvers, Neven 2018, using relic toolkit for cryptographic primitives (pairings, EC, hashing). The BLS12-381 curve is used.
                       DESC

  s.homepage         = 'https://github.com/Chia-Network/bls-signatures'
  s.license          = { :type => 'Apache License 2.0' }
  s.author           = { 'Chia Network' => 'hello@chia.net' }
  s.social_media_url = 'https://twitter.com/ChiaNetworkInc'
 
  s.source           = { 
    :git => 'https://github.com/chiatk/bls-signatures.git',
     
    :submodules => false
  }

  # Temporary workaround: don't allow CocoaPods to clone and fetch submodules.
  # Fetch submodules _after_ checking out to the needed commit in prepare command.

  s.prepare_command = <<-CMD
    set -x

    git submodule update --init

    MIN_IOS="12.0"
    MIN_WATCHOS="2.0"
    MIN_TVOS=$MIN_IOS
    MIN_MACOS="10.10"

    IPHONEOS=iphoneos
    IPHONESIMULATOR=iphonesimulator
    WATCHOS=watchos
    WATCHSIMULATOR=watchsimulator
    TVOS=appletvos
    TVSIMULATOR=appletvsimulator
    MACOS=macosx

    LOGICALCPU_MAX=`sysctl -n hw.logicalcpu_max`

    GMP_DIR="`pwd`/gmp"
 
   
        download_gmp()
        {
            GMP_VERSION="6.2.1"
            CURRENT_DIR=`pwd`

            if [ ! -s ${CURRENT_DIR}/gmp-${GMP_VERSION}.tar.bz2 ]; then
                curl -L -o ${CURRENT_DIR}/gmp-${GMP_VERSION}.tar.bz2 https://gmplib.org/download/gmp/gmp-${GMP_VERSION}.tar.bz2
            fi

            rm -rf gmp
            tar xfj "gmp-${GMP_VERSION}.tar.bz2"
            mv gmp-${GMP_VERSION} gmp
            mv contrib/gmp-patch-6.2.1/compat.c gmp/compac.c
            mv contrib/gmp-patch-6.2.1/longlong.h gmp/longlong.h
        }

        download_relic()
        {
             
            CURRENT_DIR=`pwd`

            if [ ! -s ${CURRENT_DIR}/relic.zip ]; then
                curl -L -o ${CURRENT_DIR}/relic.zip https://github.com/Chia-Network/relic/archive/1d98e5abf3ca5b14fd729bd5bcced88ea70ecfd7.zip
            fi

            rm -rf contrib/relic
            unzip  "relic.zip" -d relic_temp
            mv relic_temp/relic-1d98e5abf3ca5b14fd729bd5bcced88ea70ecfd7 contrib/relic
            rm -rf relic_temp
            
        }

        #replace the import of gmp.h becouse Xcode failed with it import type
        find ./src/ -name '*.hpp' -print0 | xargs -0 sed -i '' 's/#include <gmp.h>/#include "gmp.h"/g'
        download_relic
        #download_gmp

        
 
  CMD

  s.ios.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '10.0'
  s.osx.deployment_target = '10.10'

  s.library = 'c++'
  s.pod_target_xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++14',
    'CLANG_WARN_DOCUMENTATION_COMMENTS' => 'NO',
    'GCC_WARN_64_TO_32_BIT_CONVERSION' => 'NO',
    'GCC_WARN_INHIBIT_ALL_WARNINGS' => 'YES'
  }

  s.source_files = 'src/*.hpp', 'gmp/gmp.h', 'contrib/relic/include/*.h', 'contrib/relic/include/low/*.h', 'contrib/relic/relic-iphoneos-arm64/include/*.h'
  s.exclude_files = 'src/test-utils.hpp'
 
end
