# LSI-SAS

## Usage

```sh
docker run -itd \
  --name=lsi-sas \
  --restart=unless-stopped \
  --network=host \
  --privileged=true \
  --log-opt max-file=1 \
  --log-opt max-size=20m \
  -e TZ=Asia/Taipei \
  haeho7/docker-images:lsi-sas
```

```sh
# storcli64
storcli64 show
storcli64 /c0 show all

# sas3ircu
sas3ircu LIST
sas3ircu 0 DISPLAY
```
