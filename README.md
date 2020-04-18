```shell
# start folding@home container
# will create config.xml automatically if it doesn't exist
# extra args are passed through to the `docker run` command
./start.sh -d --name foldingathome

# check logs to make sure FAHClient is ok
docker logs -f foldingathome
```
