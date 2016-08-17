Hi there!

Sorry you're having trouble with our CLI, and thanks for taking the time to
report the issue to us.

There are a few reasons _not_ to open an issue here. Please consider the
following:

- Is this an issue with codeclimate.com?

  If you're having trouble with our hosted analysis available on
  codeclimate.com, please use our [Help & Support](https://codeclimate.com/help)
  form.

- Is this an issue with a specific engine?

  Please report issues about a specific engine to that engine's repository. It
  can usually be found at `codeclimate/codeclimate-<engine>`. If you can't find
  the engine's repository (or Issues aren't enabled there), please do report
  your issue here.

- Is this an issue with your Docker installation in general?

  While we try hard to smooth over some of this, there will always be
  system-specific issues and edge-cases that we can't work around. If you're
  unable to use Docker at all (i.e. commands like `docker version`, `docker ps`,
  or `docker run hello-world` fail), please try other channels (Stack Overflow,
  IRC, etc) before reporting the issue here.

- Are you invoking `docker run codeclimate/codeclimate` without other options?

  Invoking the CLI directly via `docker run` requires additional options to work
  correctly. That's why we ship the `codeclimate` wrapper script. Please take a
  look at the README for a working `docker run` example.

- Are you having trouble using this project as a gem or not via Docker?

  While this project is currently available as a gem, that is not a supported
  use-case. It is more an accident of history due to the way our own
  infrastructure is currently designed. Once we address this, we will stop
  releasing this project as a gem.

  We may accept Pull Requests that fix issues with using the project as a gem
  (e.g. correcting version bounds), but we will not ourselves address any Issues
  in this area.

## Guidelines

If you'd still like to report this issue, please follow these guidelines:

- Make sure your problem exists in the latest version of the CLI and any engines
  you're using, the following commands will update everything:

  ```
  docker pull codeclimate/codeclimate
  codeclimate engines:install
  ```

- Include the exact command you're running and its complete output

  Please enable debug for these invocations:

  ```
  CODECLIMATE_DEBUG=1 codeclimate analyze
  ```

  If this output is large, consider using a service like gist.github.com.

- Indicate what you expected to happen and what happened instead
- Include your operating system, how you run Docker (e.g. Docker Machine) and
  the version of Docker you're using.

  Include the output of the following commands:

  ```
  uname -a
  docker version
  env | grep "^DOCKER_"
  ```

- If your project is open source, please provide a URL to the source
- If your project is closed source, but you'd be willing to share a copy with us
  (for example, by emailing an archive), please say so
