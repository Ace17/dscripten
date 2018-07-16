# dscripten
An example of D to asmjs using Emscripten

Authors
=======

- Ace17 (Sebastien Alaiwan: sebastien.alaiwan@gmail.com)

Purpose
=======

  This is a demonstration on how D code can be compiled to Javascript using
  a combination of existing tools.

Demo
====

  You can try an online demo here: http://code.alaiwan.org/dscripten/full.html

Usage
-----

* Fetch and build the toolchains

  ```
  $ ./fetch_toolchain
  ```

  This will take some time, as it will build LLVM-fastcomp and a patched ldc2.
  The result will be in the /tmp/toolchains directory.
  Alternatively, it's possible to specify another installation prefix using
  the 'PREFIX' environment variable.

  It's also possible to specify another temporary directory using the 'tmpDir'
  environment variable. Using a tmpfs (in-RAM directory) is recommended, as it
  greatly speeds up the build.

* Add some directories to your PATH

  First, add the JSBackend LLVM toolchain. This one provides ldc2, clang, llc.
  ```
  $ export PATH=/tmp/toolchains/llvm-js/bin:$PATH
  ```

  Then, add Emscripten itself, i.e the python 'emcc' tool family. This relies on the JSBackend LLVM toolchain.
  ```
  $ export PATH=/tmp/toolchains/emscripten:$PATH
  ```

* Check your PATH:

  Here's what you should get:

  ```
  $ which -a llvm-config
  /tmp/toolchains/llvm-js/bin/llvm-config
  ```

  If you have more than one llvm-config appearing in this list, you're asking
  for trouble and the build might not work.

* Now configure emscripten.
  This will create a '.emscripten' configuration file in your home,
  containing the path to LLVM 3.9svn (aka 'fastcomp', which implements the JSBackend).
  "emcc" will use this path to find its Javascript-enabled clang and llc.

  ```
  rm -f ~/.emscripten
  EMMAKEN_JUST_CONFIGURE=1 PATH=/tmp/toolchains/llvm-js/bin:$PATH /tmp/toolchains/emscripten/emcc
  ```

* Run the build script (it just sets some variables before calling the makefile)

  ```
  $ ./build_asmjs
  ```

  (If it fails, try removing ~/.emscripten, or setting EM_CONFIG to anything else)

* Enjoy the result:

  ```
  $ firefox bin/asmjs/full.html
  ```

* You can also play the native version:

  ```
  $ ./build_native
  $ ./bin/native/full.exe
  ```

License
=======

* The build scripts and demo game source files are licensed under the GNU Affero GPL.
  In short: you're free to run them for whatever purpose, but if you put them
  on a server and provide them as a service, you must ensure your users have
  access to the source code, under the same license.

* Everything under the '/rt' directory is licensed under the permissive Boost
  software license.
  Indeed, some parts of 'rt' get integrated to the produced asm.js binaries,
  for which I don't want to impose any restriction.

