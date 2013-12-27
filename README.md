# Deploy

**Deploy is an rsync deployment tool built using Ruby**  
Essentially acts as a wrapper for the rsync utility, providing a simple YAML based configuration file.


## Install

To install just run:

```
gem install rsync-deploy
```

Once you've installed the gem, just navigate to your project directory and run:

```
deploy install
```

This will create a `deploy.yml` file that controls how the deployment should take place.

Fill in your server details. For example:

```
server_name:
    host: "server.com"
    user: "user"
    sync: true
    path:
        local: "deploy/"
        remote: "www/"
    exclude: 
        - ".DS_Store"
        - "resources/"
```

Once your `deploy.yml` is set up, simply deploy by running:

```
deploy
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

#### deploy download [env...]

Will download from the environment(s) listed. This works in reverse, so files from `path.remote` will go into `path.local`

This command is also aliased as `down` and `d`, so it can be run like:

```
deploy down staging
```

#### deploy list

Will list all configured environments.

#### deploy config NAME

Will change the name of deployment configuration files. By default they are named `deploy.yml`, but this can be changed to names such as `.deploy` which makes them hidden files. Keep in mind that **this is a global setting** and will be applied to all deployments.


#### deploy help

Will output a list of all commands.


## Config

Configuration options are specified in a YAML file called `deploy.yml` created by running `deploy install` in your project directory.

Example:

```
server_name:
  host: "example.com"
  user: "username"
  sync: true
  verbose: false
  path:
    local: "/"
    remote: "www/
  excludes:
    - ".DS_Store"
    - "resources/"
    - "deploy.yml"

```

Below is a list of all available configuration options.

### host

- Type: `String`
- Default: `none`
- Required: `Yes`

The server that the files should be deployed to.

### port

- Type: `Number`
- Default: `22`
- Required: `Yes`

The port that the connection should happen over

### user

- Type: `String`
- Default: `none`

The username to login to the server. If no username is set, your computer account username will be used.

### pass

- Type: `String`
- Default: `none`

The password to login to the server. If SSH keys aren't available, then the `pass` option will be used. If neither SSH keys nor `pass` are set, a prompt will be given.

### privateKey

- Type: `String`
- Default: `none`

The path to an alternative SSH key. This only needs to be set if your key **isn't** one of the following:

```
~/.ssh/id_rsa
~/.ssh/id_dsa
```

### sync

- Type: `Boolean`
- Default: `true`

Whether or not to delete files on the server that aren't present locally.

### verbose

- Type: `Boolean`
- Default: `false`

Whether or not to run the uploads verbosely.

### path.local

- Type: `String`
- Default: `none`

The local folder that you want to upload to the server. If you don't set anything, the entire folder of your project will be uploaded.

### path.remote

- Type: `String`
- Default: `none`

The remote folder where your files will be uploaded. If you don't set anything, your files will be uploaded to the user root of your server. Setting this is **highly recommended!**

### exclude

- Type: `Array`
- Default: `none`

Exclude files that you don't want on your server. You can target files, directories and file types.

Individual files: `exclude: ["README.md", "package.json", "path/to/file.js"]`  
Directories: `exclude: ["resources/", "test/", "path/to/dir/"]`  
File types: `exclude: ["*.yml", "*.json", "path/to/*.txt"]`

## Deploying to multiple servers/locations

You can create as many different deploy locations as you'd like by adding them to the `deploy.yml` file. For example:

```
# Development server
staging:
    host: "staging.example.com"
    user: "staging-username"
    path:
        local: "build/"
        remote: "www/staging.server.com/"

# Production server
production:
    host: "example.com"
    user: "prod-username"
    path:
        local: "build/"
        remote: "www/server.com"
```

You can deploy them by setting the environment(s) that you want to upload to:

```
deploy staging production
```

If you don't specify an environment, it's assumed that the first environment in `deploy.yml` should be used. So, with the above configuration, running `deploy` would upload to `staging` by default.


## Mentions

Deploy is almost identical to [DPLOY](https://github.com/LeanMeanFightingMachine/dploy), which was in turn inspired by [dandelion](https://github.com/scttnlsn/dandelion). However, Deploy doesn't require that you use git (or any version control for that matter). Separating deployments and version control helps avoid littering your commit history with messages like `bug fix` and `dang, forgot to adjust the config` and `another typo` and so on.


## Uninstall

To uninstall Deploy, download the [project files](https://github.com/rosszurowski/deploy/archive/master.zip), navigate to the unzipped directory, and run:

```
gem uninstall rsync-deploy
```