```shell
$ docker build -t drew6017/stable-diffusion -f stable-diffusion.Dockerfile .
$ docker run --gpus all -p 8080:8080 -v C:\host\pathtomodelsdir:/sd/models/ --rm -it drew6017/stable-diffusion bash
$ python launch.py --listen --port 8080
```

`C:\host\pathtomodelsdir` should be a directory containing the stable-diffusion weights [downloadable here][1]

[1]: https://huggingface.co/CompVis/stable-diffusion-v-1-4-original