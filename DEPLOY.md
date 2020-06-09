# How to deploy

This guide is intended for the administrators of this extension.

## Make a release

We use the git flow framework to manage releases of this extension.

You can find the original article that described git flow by Vincent Driessen [here](https://nvie.com/posts/a-successful-git-branching-model). To install git-flow in the CLI, just follow the [installation procedure](https://github.com/nvie/gitflow/wiki/Installation). If you use [sourcetree](https://www.sourcetreeapp.com), git-flow is available in the GUI out of the box.  

Using the command line is quite simple:

1. Create a new release (please use the [semver](https://semver.org) paradigm and the `golang` notation):  
```
VERSION=1.2.3
git flow release start v${VERSION}
```

2. Finalize the code, typically this means update the version number in the source and the documentation:  
```
sed -Ei "/var version =/s/[0-9]+\.[0-9]+\.[0-9]+/${VERSION}/" genesys-webchat-sample.js
```  
  On MacOS:  
```
sed -Ei "/var version =/s/[0-9]+\.[0-9]+\.[0-9]+/${VERSION}/" genesys-webchat-sample.js
```  
  On Windows:  
```
```

Then commit the changes:
```
git add .
git commit -m "Bumped version to ${VERSION}"
git flow release finish v${VERSION}
```

Once the `git flow release finish` completed, push everything to bitbucket:  
```
git push origin dev master
git push --tags
```

Using the Sourcetree GUI is easy as well (TODO: get screen caps...):

## Deploy

The repository that sits on bitbucket uses [bitbucket's pipelines](https://bitbucket.org/product/features/pipelines)

Whenever you push a new version tag (e.g., v1.0.0), the pipeline will deploy that version automatically to [bintray](https://bintray.com).

**Disclaimer:** the build script is a work in progress. I don't expect it to work 100% all the time. So, please bear with me and report issues!