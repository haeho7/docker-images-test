# Jellyfin

## Usage

```sh
docker run -d \
  --name=jellyfin \
  --restart=unless-stopped \
  --network=host \
  --user=99:100 \
  --device=/dev/dri:/dev/dri \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  -e JELLYFIN_PublishedServerUrl=192.168.1.31 \
  #-p 18096:8096 \
  #-p 18920:8920 \
  #-p 11900:1900/udp \
  #-p 17359:7359/udp \
  -v /mnt/user/appdata/jellyfin/jellyfin-data:/config \
  -v /mnt/user/medias/moives:/data/movies:ro \
  -v /mnt/user/medias/series:/data/series:ro \
  -v /mnt/user/medias/tv:/data/tv:ro \
  -v /mnt/user/medias/acg:/data/acg:ro \
  nyanmisaka/jellyfin:250217-amd64
```

## Transcoding

```sh
# Hardware acceleration
Hardware acceleration: Inter QuickSync (QSV)
Enable hardware decoding for: All
Prefer OS native DXVA or VA-API hardware decoders: No

# Hardware encoding options
Enable hardware encoding: Yes

# Encoding format options
# need to confirm whether the GPU supports HEVC or AV1 encoding
Allow encoding in HEVC format: Yes
Allow encoding in AV1 format: No

Enable Tone mapping: Yes
Select the Tone mapping algorithm to use: BT.2390
Allow subtitle extraction on the fly: Yes
```

## NFO

`Dashboard` -> `Libraries` -> `NFO Settings`

```sh
Save image paths within NFO files: No
Enable path substitution: No
Copy extrafanart to extrathumbs field: No
```

## Plugins

### Fanart

When jellyfin adds a new media library, `Image fetchers Settings` can only select cover images and logos by default. need to install the `Fanart` plugin in the plug-in list to display the art images, banner images, banner images and other options.

|       Emby      |      Jellyfin    |
| :---------------| ---------------: |
| poster.jpg      | folder.jpg       |
| clearlogo.png   | logo.png         |
| landscape.jpg   | landscape.jpg    |
| banner.jpg      | banner.jpg       |
| discart.png     | discart.png      |
| clearart.png    | clearart.png     |
| fanart.jpg      | backdrop.jpg     |

## Reference

- [@chiphell.com/Misaka_9993](https://www.chiphell.com/thread-2375777-1-1.html)
- [@ithub.com/Brainiarc7](https://gist.github.com/Brainiarc7/aa43570f512906e882ad6cdd835efe57)
- [@jellyfin.org/docs/hardware-acceleration/intel](https://jellyfin.org/docs/general/administration/hardware-acceleration/intel/#configure-and-verify-lp-mode-on-linux)
