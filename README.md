# gist package

create and insert Gists.

[![Gyazo](http://i.gyazo.com/439abb8882115eb5209d67c94c4f6f26.gif)](http://gyazo.com/439abb8882115eb5209d67c94c4f6f26)

Inspired by [condemil/Gist](https://github.com/condemil/Gist)

## Commands

* `gist:create-public`
* `gist:create-private`

If you don't have anything selected, a Gist will be created with contents of current file, URL of that Gist will be copied to the clipboard.

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

[![Gyazo](http://i.gyazo.com/2571230928167c8f01b5a195920009cb.png)](http://gyazo.com/2571230928167c8f01b5a195920009cb)

[Personal Access Tokens](https://github.com/settings/tokens)

## Usage

![](http://g.recordit.co/5ZqgyxgjdB.gif)

## TODO

- [ ] Editing existing Gists
- [ ] Adding new files to existing Gists
