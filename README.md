# emacs.d

Since beginning to use Emacs, I used [Purcell's emacs.d](https://github.com/purcell/emacs.d). It is the setup I am most used to, but after a recent system refresh I decided to try and go from the ground up, inspired by [emacs-starter-kit](https://github.com/technomancy/emacs-starter-kit).

I took the approach of explicitly making each dependency a `git subtree`. This avoids having to go through `package.el` (even though I had no issues, once in awhile Melpa would fight me and I felt like all roads had to go through Melpa). It also does not use what I understand was once the more familiar practice of using git submodules. Subtrees made sense to me for this use case.

I'm being slightly inelegant with the subtrees: in the repo proper you'll see commits where I've jammed in symlinks to unnest `*.el` files for autoloading. And, I don't believe that I'm presently taking advantage of what autoloading can do for me with respect to the tree of subtrees. But, the point of this repo is to get there.

And, maybe, just maybe, I'll actually have some idea of how my Emacs actually works for once!

## Some weirds

* `libegit2` has `libgit2` as a submodule. That's not workable for us in a repo where `libegit2` is itself a subtree; but, we need the `libgit.so` to be built for `libegit2` to be of any use. Long story short, I cheated, built it elsewhere, then added the folder over. I attempted to include `libgit2` as a nested subtree but besides this being wonky git-wise it also causes an issue in the built itself.
* Not weird necessarily, but `magit` has all its `*.el` files symlinked one level above its `lisp` dir. Other projects have symlinks but this is the most notable because it includes dozens of them.
* The `magit` build process and the `libegit2` build process (the latter of which cannot occur in the context of this project) wouldn't be triggered for any reason if you pulled this project as is. While that's not exactly high maintenance, it's not as automatic as it should be.
* The client for `lsp-mode` for Elixir -- [elixir-ls](git@github.com:JakeBecker/elixir-ls.git). -- needs to be compiled, have a release built, and for that release path to be added to the `$PATH`
* I didn't do a `--squash` when I went through all of the `git subtree add` bits and so this repo has an unhealthy number of commits.
