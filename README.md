Welcome Home - Hue Panel
====

A lightweight Meteor.JS Phillips Hue lights control panel.
![](http://magneticore.com/wp-content/uploads/2015/03/WelcomHomeDemo.gif)

###App Status

Alpha version: Alpha software can be unstable and could cause crashes.

###Quick App Install

If you have NodeJS and Meteor already installed, setup is as simple as running `meteor` from the app directory.

Otherwise:

* Install Node: [http://nodejs.org](http://nodejs.org)
* Install Meteor: `curl https://install.meteor.com | /bin/sh`
* Open the control panel in your browser: `http://your_local_ip:3000`

![](http://magneticore.com/wp-content/uploads/2015/03/welcome-home.gif)

###Requirement - Hue Bridge

After lauch, the application will perform a initial test to connect to the Hue's bride. Touch the mid button on the bridge and within 30 seconds click on the test button on your browser. After these steps the App will have permission to use your Hue bridge.


###Options for Deploying

Now that you've tested the app, you may want to set it up to run all the time. There are a couple of options for this.

First thing's first. The app needs to live on the same LAN as the lights it will be controlling.

Next, you could [do a proper production deployment](https://www.digitalocean.com/community/tutorials/how-to-deploy-a-meteor-js-application-on-ubuntu-14-04-with-nginx).

Or (much easier) since it will only ever be accessed over the local network, just run it in the background, using the dev server: `meteor &`


### Providers/source

Special thanks to [Kelli Shaver](https://github.com/kellishaver/hue-panel) for the initial implementation.

### License

See the [LICENSE](LICENSE.md) file for license rights and limitations (MIT).