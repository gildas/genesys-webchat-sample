# GENESYS Widget Extension: Sample

[ ![Download](https://api.bintray.com/packages/genesys/widgets/genesys-webchat-sample/images/download.svg?version=1.0.0) ](https://bintray.com/genesys/widgets/genesys-webchat-sample/1.0.0/link)

## Purpose

This repository is a tutorial to show how easy it is to write an extension for [GENESYS Widget](https://docs.genesys.com/Documentation/GWC).

It contains information not only on writing the actual code, but also on managing the repository's life (contributions, release deployments, etc).

The Sample Widget Extension is a very simple extension. It sends a [Unix Fortune (6) cookie](https://en.wikipedia.org/wiki/Fortune_(Unix)) message to the transcript when the guest clicks on the fortune button in the Widget.

## Usage

First, we will describe what needs to be done to use this extension, provided it has been deployed already.

We chose [bintray.com](https://bintray.com) to host the deployed extension.

In the webpage (typically `index.html`), when adding GENESYS Widget, simply add these lines:  
```html
</html>
<head>
  <!-- {{{ Genesys Cloud -->
    <link id="genesys-widget-styles" href="https://apps.mypurecloud.com/widgets/9.0/widgets.min.css">
  <!-- Genesys Cloud }}} -->
</head>
<body>
  <p>The body of the web page</p>

  <!-- {{{ Genesys Cloud -->
  <script id="widget-configuration"   src="/chat-widget-config.js"></script>
  <script id="genesys-webchat-sample" src="https://dl.bintray.com/genesys/widgets/1.0.0/genesys-webchat-sample.min.js"></script>
  <script id="genesys-widget"         src="https://apps.mypurecloud.com/widgets/9.0/widgets.min.js"></script>
  <!-- Genesys Cloud }}} -->
</body>
</html>
```

Several important notes:
- It is better to load your javascript at the end of the `body` rather than the `head`, the page will display something faster,
- **Always** load the widget configuration (here `/chat/widget-config.js`) before the widget and its extensions,
- It is better also to load the widget extensions after the widget, especially if they depend on standard components of the widget.

## Version

While this is not mandatory, it is highly beneficial for any software component to tell its version. We will show in the code how to add a `version` command to your widget extension.

To get the version of this `sample` extension, in the Javascript console of your browser, after the webpage is loaded, simply type:

```js
await CXBus.command('Sample.version')
```

## Under the hood

Now, let's pop the hood and see what is in there, shall we?

An extension always starts with the same entrypoint: filling in the `extensions` map with its _install_ function:  
```js
window._genesys.widgets.extensions['Sample'] = function($, CXBus, Common) {
    let plugin = CXBux.registerPlugin('Sample')

    // ...

    plugin.republish('ready')
    plugin.ready()
}
```
As mentioned in the [Extension Manual](https://docs.genesys.com/Documentation/GWC/Current/CXWBusAPI/GWCGWCCXBusExtensions), the function receives 3 parameters: `jQuery`, a [CXBus](https://docs.genesys.com/Documentation/GWC/Current/CXWBusAPI/WidgetBusAPIOverview), and a [Common](https://docs.genesys.com/Documentation/GWC/Current/WidgetsAPI/Common) instance of the Common UI utilities.

Of course, before adding the extension to the `extensions` map, make sure the properties exists in `window` (see the first 3 lines of [genesys-webchat-sample.js](genesys-webchat-sample.js#L1-L3)).

At the end of the function, the plugin tells the CXBus and the Widget Framework it is ready for consumption.

Check the code for more details. This widget subscribes to various events that allow it to initialize itself and adds a command that can be used by other extensions.

## Contributions

To contribute to this repository, please check [CONTRIBUTE.md](CONTRIBUTE.md)

## Deploy

If this repository is hosted on [bitbucket.org](https://bitbucket.org), please check  [bitbucket-pipelines.yml](bitbucket-pipelines.yml). Do not forget to set the secrets `BT_USER` and `BT_APIKEY` in the Settings.

If this repository is hosted on [github.com](https://github.com), please check [.github/workflows/deploy.yml](.github/workflows/deploy.yml). Do not forget to set the secrets `BT_USER` and `BT_APIKEY` in the [Settings](https://github.com/gildas/genesys-webchat-sample/settings/secrets).

Basically, whenever the code is tagged with a version number, the code is deployed to [bintray.com](https://bintray.com) when that tag is pushed.

Please check [DEPLOY.md](DEPLOY.md) for detailed instruction on how to deploy.