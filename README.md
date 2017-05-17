vim-reason-loader
================

## Currently deprecated. Please use [vim-reason](https://github.com/reasonml/vim-reason) instead!

Vim plugin that loads the *real* [Reason](https://github.com/facebook/reason)
and Merlin plugins from the `PATH`.


**Installation**

- install using `Vundle` or `NeoBundle`.

        " Or if using NeoBundle(recommended)
        NeoBundle 'reasonml/vim-reason-loader'

        " Using Vundle
        Bundle 'reasonml/vim-reason-loader'

        " Using Vim Plug
        Plug 'reasonml/vim-reason-loader'

**Usage**

It's really simple: when you start `vim`, make sure that the `PATH` environment
variable has any and all `Merlin`, `ocaml`, and
[`Reason`](https://github.com/facebook/reason) tooling available in the path.

You can test this by trying `which ocamlmerlin`, and `which refmt`.

If that doesn't print the path, then you haven't used your package manager to
correctly setup your `PATH` with those tools globally available.

Details:

This is a tiny Vim plugin whose only job is to load the *real* Vim Reason /
Merlin plugins when you start Vim. In general, if you've already installed
`Reason`, `Merlin`, or `OCaml` those installations have the *real* Vim plugins
sitting next to the `ocamlmerlin`, and `refmt` binaries respectively. Depending
on how you installed the packages, the real plugin code is likely sitting
somewhere next to those binaries, and this plugin loads them from that
location.

Why would you want to do this? Because you may have two separate projects, that
have different versions of `refmt`, or `ocamlmerlin`, or `Reason` syntax
highlighting, and you change your `PATH` environment variable to reflect your
specific project. You want to make sure that when you start Vim, you're loading
the Vim plugins for the specific versions of `Reason` / `Merlin` that you are
working on. This scripts wraps that short, but messy logic into one Vim plugin
that you can depend on easily like any other Vim plugin.


**Troubleshooting**

- Colors Aren't Appearing
  - If you're using a combination of zsh and nvim, you may run into an issue where
the correct shell will load, but colors won't display correctly.
  - You can try to fix this by setting `set shell=/bin/sh` in your Neovim config.
