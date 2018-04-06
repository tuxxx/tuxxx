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

Run `tuxxx` image to build the system inside the container and generate ISO files:
```bash
$ docker run --privileged tuxxx
```

You can also use it to "burn" the system onto a USB device:
```bash
$ docker run --privileged tuxxx --usb-device=sdX
```

**WARNING**: Replace sdX with the correct device name. Device will be erased and rewritten!


Similar distributions
---------------------
 * [DidJiX](http://easy.open.and.free.fr/didjix/)
 * [MixxxOS](http://mixxx.org/forums/viewtopic.php?t=1493)
