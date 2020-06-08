# How to contribute

We use the git flow framework to manage the development cycle of this extension.

You can find the original article that described git flow by Vincent Driessen [here](https://nvie.com/posts/a-successful-git-branching-model). To install git-flow in the CLI, just follow the [installation procedure](https://github.com/nvie/gitflow/wiki/Installation). If you use [sourcetree](https://www.sourcetreeapp.com), git-flow is available in the GUI out of the box.  

## New code

New code should be written **ONLY** in the `dev` branch!

We will not accept new code in the `master` branch.

When writing something completely new, like a feature, you should use a feature branch.

```
git flow feature start my-cool-feature
```

## Hotfixes
