# EmbyServer

## Usage

```sh
docker run -d \
  --name=embyserver \
  --restart=unless-stopped \
  --network=host \
  --device=/dev/dri:/dev/dri \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e UID=99 \
  -e GID=100 \
  -e GIDLIST='100,18' \
  #-p 8096:8096 \
  #-p 8920:8920 \
  #-p 1900:1900/udp \
  #-p 7359:7359/udp \
  -v /etc/localtime:/etc/localtime:ro \
  -v /mnt/user/appdata/embyserver/embyserver-data:/config \
  -v /mnt/user/medias/moive:/data/movies \
  -v /mnt/user/medias/series/:/data/series \
  -v /mnt/user/medias/tv:/data/tv \
  -v /mnt/user/medias/acg/:/data/acg \  
  haeho7/docker-images:embyserver-4.7.14.0
```

## FAQs

### Browser play video error: No compatible streams are currently available. Please try again later or contact your system administrator for more information

Most browsers do not support decoding of HEVC videos, so you need enable transcoding on emby.Select Advanced for transcoding type, and it is recommended to use only the Intel QuickSync decoder.

### cannot be scraped Metadata and posters

Modify the Media Library Movie Metadata Downloader to TheMovieDb, Movie Image Fetchers to TheMovieDb and FanArt.

See more: <https://emby.media/community/>
