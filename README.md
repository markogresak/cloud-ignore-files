## Cloud sync ignore files

> Make Cloud sync ignore certain project files

### Why?

I am using iCloud to share data between my macs, including my project files. I noticed that `node_modules` and similar project dependencies caused iCloud to take awfully long to sync thousands upon thousands of files, despite fast internet connection.

I was searching for a solution to prevent `node_modules` from uploading, but iCloud doesn't seem to offer ignoring files. So I started to put together this solution/hack. It's not iCloud specific so it can be used with any service which doesn't provide selective sync and/or ignoring certain files.

### How it works?

It's really dumb solution and I tried my best to avoid this solution, but it was the only thing that worked.

The script expects a local project directory, which is not included in cloud synced folders. This directory is kept in sync with duplicate project folder inside the cloud drive, but this clone doesn't contain project dependencies. This makes the size of clone a bit smaller and most importantly, faster to sync, thanks to a lot less files.


Syncing works both ways, so when new files are downloaded from the cloud, they will be copied over to local project directory.

The syncing is done with [unison](https://www.cis.upenn.edu/~bcpierce/unison/index.html) CLI tool. Initially, I tried with rsync, but it doesn't support bidirectional sync.

The sync script will ignore:
 - `node_modules` folder
 - `bower_components` folder
 - `*.log` files (rails apps can produce large logs and those are stored directly inside the project directory)
 - `.DS_Store` files

These files can be customized by modifying `ignore_files` variable in `install.sh`. With current version, this is based off personal project types (mostly rails and node), but it's open to suggestions.

### Installing

*Note*: This currently works only on MacOS because the use of `launchctl`. 

1. Install [unison](https://www.cis.upenn.edu/~bcpierce/unison/download.html) CLI tool. The easiest way is `brew install unison`.
2. Clone or download this repository and `cd` into the folder.
3. Check `install.sh` script and edit paths to match your system setup. Check variables `local_path`, `cloud_path` and `ignore_files`, which can be found at the top of the script.
4. Run `./install.sh`.

By default, the script is configured to add log files in `/var/log`. To create log files, the requires `sudo` access, so it will ask for password during installation. You can disable logging by running install script as `./install.sh --no-logs`.

### Updating config

If you make changes to `install.sh` or templates and want to update your config, just run `./install.sh` again and it will re-generate and reload config. The updated config should start working immediately. But it might take `unison` a moment to sync stuff, depending on your project size

### Uninstalling

Running `./install.sh --uninstall` will unload config, remove it, remove the syncing script and log files.


### Performance

As far as software goes, all comes down to `unison` performance, which seems to be quite fast. On my MacBook Pro (13" retina, late 2013: 2.4 GHz CPU, 8gb RAM, 256gb SSD) with projects folder size of 2.5GB with ~125k files or 62k without counting `node_modules`, it took about 75s to init, i.e. clone the whole project folder. Real cases will probably see only a few files changed here and there, which should be synced instantaneously.


### Credits

Thanks you @tatums for the [rsyc-icloud-hack](https://github.com/tatums/rsyc-icloud-hack) project, it helped me a lot to shape this project!
