## Cloud sync ignore files

> Make Cloud sync ignore certain project files

### Why?

I am using iCloud to share data between my macs, including my project files. I noticed that `node_modules` and similar project dependencies caused iCloud to take awfully long to sync thousands upon thousands of files, despite a fast internet connection.

I was looking for a solution to prevent `node_modules` from uploading, but iCloud doesn't seem to offer ignoring files. So I started to put together this solution/hack. It's not iCloud-specific; you can use it with any service which doesn't provide selective sync or ignoring files.

### How it works?

The script expects a local project directory, which outside the cloud synced folders. The project directory is in sync with a duplicate project folder inside the cloud drive, but this clone doesn't contain project dependencies. This setup makes the size of the clone smaller and more importantly, faster to sync, thanks to a lot fewer files.


Syncing works both ways, so when new files are downloaded from the cloud, they are copied over to the local project directory.

The syncing works via [unison](https://www.cis.upenn.edu/~bcpierce/unison/index.html) CLI tool. Initially, I tried with `rsync`, but it doesn't support a simple bidirectional sync setup.

The sync script will ignore:
 - `node_modules` folder
 - `bower_components` folder
 - `*.log` files (rails apps can produce large logs and those are stored directly inside the project directory)
 - `.DS_Store` files

You can change the ignored files by modifying the `ignore_files` variable in `install.sh`. With the current version, the setup is based on personal project types (mostly rails and node), but it's open to suggestions.

### Installing

*Note*: This currently works only on macOS because of the use of `launchctl`, but the rest is platform-agnostic (limited by [`unison` support](https://github.com/bcpierce00/unison/wiki/Downloading-Unison)). It should not be a lot of work to swap in a platform-specific service manager (e.g. `systemctl`). But I am not an active Linux or Windows user, so I did not test the install script on other platforms. PRs welcome :smile:

Due to stricter macOS security policy, you must ensure `bash` has the Full Disk Access permission
<img src="https://user-images.githubusercontent.com/1595871/106532234-a6c0cf00-64a4-11eb-9821-a7b5b34ce69d.png" height="300"><br/>
_Thanks to @chrisblossom for pointing it out (see [#5](https://github.com/markogresak/cloud-ignore-files/issues/5#issuecomment-771240855))._

1. Install [unison](https://www.cis.upenn.edu/~bcpierce/unison/download.html) CLI tool. The easiest way is `brew install unison`.
2. Clone or download this repository and `cd` into the folder.
3. Check `install.sh` script and edit paths to match your system setup. Check variables `local_path`, `cloud_path` and `ignore_files`, which can be found at the top of the script.
4. Run `./install.sh`.

By default, the script is configured to add log files in `/var/log`. To do this, the script requires `sudo` access, so the script will ask for the password during installation. You can disable logging by running the install script as `./install.sh --no-logs`, which also skips the password prompt.

### Updating config

If you make changes to `install.sh` or templates and want to update your config, just run `./install.sh` again and it will re-generate and reload config. The updated config should start working immediately. But `unison` might take a moment to sync, depending on the size of the synced folder.

### Uninstalling

Run `./install.sh --uninstall` to unload and remove the config, remove the syncing script and log files.


### Performance

As far as software goes, it all comes down to `unison` performance, which seems to be quite fast. On my MacBook Pro (13" retina, late 2013: 2.4 GHz CPU, 8gb RAM, 256gb SSD) with projects folder size of 2.5GB with ~125k files or 62k without counting `node_modules`, it took about 75s to init, i.e. clone the whole project folder. Real cases will probably see only a few files changed here and there, which should sync instantaneously.


### Related solutions

- [iCloud-NoSync](https://github.com/tsdexter/iCloud-NoSync): An Automator utility to have iCloud Sync ignore an entire folder without losing access to the folder path

### Credits

Thank you @tatums for the [rsyc-icloud-hack](https://github.com/tatums/rsyc-icloud-hack) project, it helped me a lot to shape this project!
