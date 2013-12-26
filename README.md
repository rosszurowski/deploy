**_Note: This tool is still in development and likely will not work in many cases._**

# Deploy

**Deploy is an rsync deployment tool built using Ruby**  
Essentially acts as a wrapper for the rsync utility, providing a simple YAML based configuration file.


## Install

To install just run:

```
gem install rsync-deploy
```


## Commands

#### deploy install

Will create an template `deploy.yml` file in the current directory.

#### deploy [env...]

Will deploy to the environment(s) listed in the command. This can be used to deploy to a single server, like this:

```
deploy production
```

Or to multiple servers, like this:

```
deploy dev staging production
```

All environments called (eg. **dev**, **staging**, and **production**) are expected to be listed in your `deploy.yml` file.

# Basic example

Set up your server in the `deploy.yml` file

```
production:
    host: "server.com"
    user: "username"
    path:
        local: "deploy/"
        remote: "public_html/"
```

And then use the following command to deploy:

```
deploy production
```

# Mentions

Deploy is almost identical to [DPLOY](https://github.com/LeanMeanFightingMachine/dploy), which was in turn inspired by [dandelion](https://github.com/scttnlsn/dandelion). However, Deploy separates version control from deployment, which helps avoid messy version control history with commits like _bug fix_, _typo_, and so on.


## Uninstall

To uninstall Deploy, download the [project files](https://github.com/rosszurowski/deploy/archive/master.zip), navigate to the unzipped directory, and run:

```
gem uninstall rsync-deploy
```