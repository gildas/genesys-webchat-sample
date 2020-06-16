# How to deploy

This guide is intended for the administrators of this repository.

## Make a release

We use the git flow framework to manage the development cycle of this extension. More precisely, we use the [AVH Edition](https://github.com/petervanderdoes/gitflow-avh) that has some improvements around git hooks and more branches.

You can find the original article that described git flow by Vincent Driessen [here](https://nvie.com/posts/a-successful-git-branching-model). To install git-flow AVH Edition, just follow the [installation procedures](https://github.com/petervanderdoes/gitflow-avh/wiki/Installation) for your Operating System. If you use [sourcetree](https://www.sourcetreeapp.com), git-flow AVH Edition is available in the GUI out of the box since version 2.7.4. As for [GitKraken](https://gitkraken.com), they have git-flow but not sure about AVH Edition.

You should use [gildas/genesys-webchat-gitflow](https://github.com/gildas/genesys-webchat-gitflow) to easily manage the versions within your extension.

Using the command line is quite simple:

1. Create a new release:  
   ```console
   git flow release start
   ```  
   Here we let the git flow hooks decide the release number (see [there](https://github.com/gildas/genesys-webchat-gitflow#usage) for more details)
2. Run your last-chance unit/integration tests, typo checks and commit them in the release branch.
3. Finally, finish the release:  
   ```console
   git flow release finish --push
   ```  
   If you do not want to push right away, you should push manually the tags, the branches `dev` and `master` later on:  
   ```console
   git push origin dev master
   git push --tags
   ```

Using the Sourcetree GUI is easy as well (TODO: get screen caps...):

## Deploy

If your repository is hosted on [Github](https://github.com), the Github workflow will be used automatically.

If your repository is hosted on [Bitbucket](https://bitbucket.org), the [Bitbucket's Pipelines](https://bitbucket.org/product/features/pipelines)  will be used automatically.

Whenever you push a new version tag (e.g., v1.0.0), the pipeline will deploy that version automatically to [bintray](https://bintray.com).

**Note:** Do **NOT** forget to configure the Github workflow or the Bitbucket's Pipelines.
- Github workflow: Set the repository's [secrets](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets) `BT_USER` and `BT_APIKEY` to you bintray user and [API key](https://www.jfrog.com/confluence/display/BT/Bintray+Security#BintraySecurity-APIKeys),
- Bitbucket pipeline: Set the repository's [Pipelines variable](https://confluence.atlassian.com/bitbucket/variables-in-pipelines-794502608.html#Variablesinpipelines-Repositoryvariables) `BT_USER` and `BT_APIKEY` to you bintray user and [API key](https://www.jfrog.com/confluence/display/BT/Bintray+Security#BintraySecurity-APIKeys).

**Disclaimer:** the build script is a work in progress. I don't expect it to work 100% all the time. So, please bear with me and report issues!
