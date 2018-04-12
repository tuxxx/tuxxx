<p align="center">
  <img src=".resources/logo.png" alt="" width=100>

  <h3 align="center">TUXXX</h3>

  <p align="center">
    Live Linux distribution based around <a href="https://www.mixxx.org/">Mixxx</a> DJ mixing software.
  </p>
</p>

<br>

Requirements for build
----------------------
 * [Docker](https://www.docker.com/)


Instructions
------------
Build the docker image:
```bash
$ docker build -t tuxxx .
```

Start the `tuxxx` container to generate the ISO file:
```bash
$ docker run --privileged tuxxx -v "$PWD"/build:/build
    [--arch=amd64 --debian_mirror=http://ftp.us.debian.org/debian]
```


Contributing
------------
If you wish to contribute, please use GitHub issue tracker
or fork and create an pull-request.


Similar distributions
---------------------
 * [DidJiX](http://easy.open.and.free.fr/didjix/)
 * [MixxxOS](http://mixxx.org/forums/viewtopic.php?t=1493)
