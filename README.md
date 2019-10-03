# emacs.d

Since beginning to use Emacs, I used [Purcell's emacs.d](https://github.com/purcell/emacs.d). It is the setup I am most used to, but after a recent system refresh I decided to try and go from the ground up, inspired by [emacs-starter-kit](https://github.com/technomancy/emacs-starter-kit).

I took the approach of explicitly making each dependency a `git subtree`. This avoids having to go through `package.el` (even though I had no issues, once in awhile Melpa would fight me and I felt like all roads had to go through Melpa). It also does not use what I understand was once the more familiar practice of using git submodules. Subtrees made sense to me for this use case.

I'm being slightly inelegant with the subtrees: in the repo proper you'll see commits where I've jammed in symlinks to unnest `*.el` files for autoloading. And, I don't believe that I'm presently taking advantage of what autoloading can do for me with respect to the tree of subtrees. But, the point of this repo is to get there.

And, maybe, just maybe, I'll actually have some idea of how my Emacs actually works for once!

## Some weirds

* `libegit2` has `libgit2` as a submodule. That's not workable for us in a repo where `libegit2` is itself a subtree; but, we need the `libgit.so` to be built for `libegit2` to be of any use. Long story short, I cheated, built it elsewhere, then added the folder over. I attempted to include `libgit2` as a nested subtree but besides this being wonky git-wise it also causes an issue in the build itself.
* Not weird necessarily, but `magit` has all its `*.el` files symlinked one level above its `lisp` dir. Other projects have symlinks but this is the most notable because it includes dozens of them. `transient` is an example where we only have to symlink/copy a single `*.el` file.
* The `magit` build process and the `libegit2` build process (the latter of which cannot occur in the context of this project) wouldn't be triggered for any reason if you pulled this project as is. While that's not exactly high maintenance, it's not as automatic as it should be.
* The client for `lsp-mode` for Elixir -- [elixir-ls](git@github.com:JakeBecker/elixir-ls.git). -- needs to be compiled, have a release built, and for that release path to be added to the `$PATH`
* ~~I didn't do a `--squash` when I went through all of the `git subtree add` bits and so this repo has an unhealthy number of commits.~~ **UPDATE**: I replaced this repository with a new one with the help of the `subtree.sh` script. The repo went from ~40,000 commits to ~60 and the size of the `.git` folder alone went from ~110mb to 84mb.

## Steps for addressing weirds

1. Clone `libegit2` somewhere else on your machine and follow [libegit2's README](https://github.com/magit/libegit2) for getting the `libgit2` submodule pulled down and built. Copy the outputs of the `build` folder to an equivalent folder in your `lib/libegit2`.
1. Follow [magit's instructions](https://magit.vc/manual/magit/Installing-from-the-Git-Repository.html#Installing-from-the-Git-Repository) for `make`-ing `magit`. Pay particular attention to the section on `config.mk` and note that you will likely need to add an additional load path to `libegit2`.
1. If you're going to use `elixir-ls` see above for the source repo and follow the instructions to build a release to some output dir that either is already or needs to be added to your `PATH`. You can also see `lsp-mode` configuration options for specifying a path but might as well take advantage of `exec-path-from-shell`.


## Adding more trees
**Always use `subtree.sh` to add subtrees**. It adds remotes for you and saves a `.remote` file in the package's directory for future convenience.

Use the `subtree.sh` script like so: `./subtree.sh add package-name git@github.com:foggy1/package-name`. It optionally takes a fourth arg if you want to link it to something other than `master`. The second arg will be the name of your lib: this _must_ match the primary `*.el` provider name of the package  or the autoload script that comes with this project will not load the package correctly.

Note also that the second arg and the name of the package's repository need not match. In some cases -- such as `better-defaults` -- they will. In others, such as `ido-completing-read+` having a repo named `ido-completing-read-plus`, will not match for obvious reasons. Another common pattern is that repos will end in `.el` which will always need to be thrown out.

## Updating existing trees
Use `subtree.sh` script like so: `./subtree.sh pull package-name`. This short version assumes you've already added locally as it relies on an existing remote named `package-name` that knows the repo already. If this isn't the case, you can simply do `./subtree.sh pull package-name $(cat lib/package-name/.remote)` since any added file automatically includes a `.remote`. This will also _add_ a named remote for you since it wasn't there yet and allow the shorter version.
