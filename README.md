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
$ docker build -t tuxxx_maker .
```

Run `tuxxx_maker` in the container to create live USB disc:
```bash
$ docker run --privileged --rm -it tuxxx_maker --usb-device=sdX
```

**WARNING**: `--usb-device` will be erased and rewritten!


Similar distributions
---------------------
 * [DidJiX](http://easy.open.and.free.fr/didjix/)
 * [MixxxOS](http://mixxx.org/forums/viewtopic.php?t=1493)
