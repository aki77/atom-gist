# gist package

create and insert Gists.
[![Build Status](https://travis-ci.org/aki77/atom-gist.svg)](https://travis-ci.org/aki77/atom-gist)

![](http://g.recordit.co/5ZqgyxgjdB.gif)

Inspired by [condemil/Gist](https://github.com/condemil/Gist)

## Features

* Create Gists
* Insert Gists
* Edit existing Gists
* Delete existing Gists
* Open browser existing Gists

## Commands

* `gist:create-public`
* `gist:create-private`
* `gist:list`

## Keymap

edit `~/.atom/keymap.cson`

```coffeescript
# default
'.select-list.with-action':
  'tab': 'select-list:select-action'
```

## Settings

* `token` (default: '')
* `tokenFile` (default: '~/.atom/gist.token')
* `environmentName` (default: 'GIST_ACCESS_TOKEN')

[![Gyazo](http://i.gyazo.com/b68171e09b21dc06a1d50b4635b655fe.png)](http://gyazo.com/b68171e09b21dc06a1d50b4635b655fe)

[Personal Access Tokens](https://github.com/settings/tokens)

## Usage

### Create Gists

1. Use the `gist:create-private` or `gist:create-public` commands.

 If you don't have anything selected, a Gist will be created with contents of current file, URL of that Gist will be copied to the clipboard.

### Insert Gists

1. Use the `gist:list` commands.
2. Select gist.
3. Press the `enter` key.

### Edit Gists

1. Use the `gist:list` commands.
2. Select gist.
3. Press the `tab` key.
4. Select `Edit` action.

### Delete Gists

1. Use the `gist:list` commands.
2. Select gist.
3. Press the `tab` key.
4. Select `Delete` action.

## TODO

- [x] Editing existing Gists
- [ ] Adding new files to existing Gists
- [ ] Caching Gists
