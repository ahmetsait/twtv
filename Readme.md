<div align="center">

Twtv  
[![Platforms](https://img.shields.io/badge/platforms-windows%20%7C%20linux-blue)](https://github.com/ahmetsait/twtv/releases) [![Latest Release](https://img.shields.io/github/v/release/ahmetsait/twtv)](https://github.com/ahmetsait/twtv/releases/latest) [![Downloads](https://img.shields.io/github/downloads/ahmetsait/twtv/total)](https://github.com/ahmetsait/twtv/releases) [![License](https://img.shields.io/github/license/ahmetsait/twtv)](LICENSE_1_0.txt)
========
</div>

Twtv is a command line program for using Twitch GraphQL API. Currently only supports a few commands related to following channels.

Downloads
---------
Prebuilt binaries can be found in [Releases](https://github.com/ahmetsait/twtv/releases) section.

Getting Started
---------------
- Log into your Twitch account
- Open browser dev tools (F12) -> Network
- Refresh the page
- Copy the headers of one of the gql requests (Right Click → Copy Value → Copy Request Headers)
  ![devtools](devtools-light.png#gh-light-mode-only)
  ![devtools](devtools-dark.png#gh-dark-mode-only)
- Paste the clipboard content to a file named `headers.txt` alongside the executable.
- You should be able to use Twitch GraphQL API through command line now.

Documentation
-------------

### Usage

`twtv [options] get-user-id <name>`  
Get user id from user name.

`twtv [options] follow <id> [notifications]`  
Follow user. Seems highly rate limited, wait 4 second between requests to be safe.

`twtv [options] unfollow <id>`  
Unfollow user.

`twtv [options] get-followed-channels`  
Get a list of followed channel IDs and names. You can pipe the output through `cut -f1` or `cut -f2` to get IDs or names respectively.

`twtv [options] unfollow-all`  
Unfollow all followed channels.

### Options

- `--user-agent=STRING`  
  Set `User-Agent` header.
- `-h`, `--headers=FILE`  
  Read headers from FILE. (Default: `headers.txt`)
- `-v`, `--verbose`  
  Print diagnostic messages.
- `--version`  
  Output version information and exit.
- `--help`  
  Show this help information and exit.

Known Issues
------------
See [Issues](https://github.com/ahmetsait/twtv/issues) for bug reports.

Building
--------
You don't strictly need a specific compiler but those listed in Prerequisites are the ones used in build scripts.
Check out the `build.sh` & `build.ps1` files to learn more and tweak as you like.

### Windows
Prerequisites:
- Digital Mars D Compiler `dmd`

From command line:
```
build.cmd
```
If you're getting "running scripts is disabled on this system" errors, run the following command in PowerShell:
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force
```
See [About Execution Policies](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies) for more information.

### Linux
Prerequisites:
- Digital Mars D Compiler `dmd`

From Bash:
```bash
./build.sh
```

License
-------
Twtv is licensed under the [Boost Software License 1.0](LICENSE_1_0.txt).
