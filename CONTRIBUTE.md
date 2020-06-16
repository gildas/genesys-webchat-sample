# How to contribute

We use the git flow framework to manage the development cycle of this extension. More precisely, we use the [AVH Edition](https://github.com/petervanderdoes/gitflow-avh) that has some improvements around git hooks and more branches.

You can find the original article that described git flow by Vincent Driessen [here](https://nvie.com/posts/a-successful-git-branching-model). To install git-flow AVH Edition, just follow the [installation procedures](https://github.com/petervanderdoes/gitflow-avh/wiki/Installation) for your Operating System. If you use [sourcetree](https://www.sourcetreeapp.com), git-flow AVH Edition is available in the GUI out of the box since version 2.7.4. As for [GitKraken](https://gitkraken.com), they have git-flow but not sure about AVH Edition.

To contribute, the first think will be to [fork](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/working-with-forks) this repository and work from there.

## New code

New code should be written **ONLY** in the `dev` branch!

We will not accept new code in the `master` branch.

When writing something completely new, like a feature, you should use a feature branch:  
```console
git flow feature start my-cool-feature
```

Then, when the feature is done, your should re-sync your fork and finish the feature:  
```console
git flow feature finish my-cool-feature
```

Then [Create a Pull Request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request) from your `dev` branch.  
If you use Github's [CLI](cli.github.com), that would be:
```console
gh pr create
```

Once you Pull Request is accepted, you should re-sync your fork, see [here](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/syncing-a-fork).

## Hotfixes

This area is under construction. Sorry.
