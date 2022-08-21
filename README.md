# README

## Download from GitHub

```bash
git clone https://github.com/itsziget/fix-docker-containers.git
```

## Links ad recommendations for debugging and learning

- Links to the documentation
  - https://docs.docker.com/config/daemon/#troubleshoot-the-daemon
  - https://docs.docker.com/config/daemon/#read-the-logs
  - https://docs.docker.com/desktop/troubleshoot/overview/
- Learn
  - https://container.training/intro-selfpaced.yml.html#1
  - https://learn-docker.it-sziget.hu/
- If you can't find the documentation try to get help in the command line
  - `<command> -h`
  - `<command> --help`
  - `<command> help`
  - `man <command>`
- Keep in mind
  - If you download images from Docker Hub, always read the description
  - List containers to make sure they are running 
  - Always check the logs
  - Use `docker image inspect` to get more information about images
  - Use `docker container inspect` to get more information about containers
  - Use `docker run --rm -it <image> sh` to test installation and configuration interactively
    before you create a Dockerfile
  - Never change anything in the Docker data directory manually, but you can read it
  - Use your favorite search engine to search for error messages
- Ask for help:
  - Some advise for asking help and reporting issues: \
    https://www.slideshare.net/kosTakcs/getting-help-with-docker-reporting-and-fixing-bugs-in-an-opensource-component
  - If you still need help: https://forums.docker.com/

## Using the tutorial

Get help

```bash
./run.sh -h
```

If you just want to run every example and see the output, run the following command:

```bash
./run.sh -a
```

You can also run it step by step:

```bash
./run-steps.sh
# or
# ./run.sh -s
```

Run a specific step (the third in this example)

```bash
./run.sh -S 3 -l 1
```

Run all steps starting with a specific step (the third step in this example)

```bash
./run.sh -S 3
```

Run four steps step by step starting with a specific step (the third step in this example)

```bash
./run.sh -s -S 3 -l 4
```

