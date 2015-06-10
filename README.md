# Code Climate CLI

```
docker run -it \
  -e CODE_PATH=$PWD \
  -v $PWD:/code \
  -v /var/run/docker.sock:/var/run/docker.sock \
  codeclimate/codeclimate \
  COMMAND
```
