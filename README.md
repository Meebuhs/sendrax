# sendrax

Easily log climbs and track progress indoors and out.

<p align="center">
  <img src="docs/sendrax-climb.jpg" width="30%">
</p>

This app aims to be a middle-ground between simple options like a spreadsheet or a journal
(which get difficult to manage when your log gets large and are frustrating to deal with between 
climb) and other software solutions like vertical life (which requires your gym's support) or one 
of many outdoor focused trackers which don't really work indoors.

With this app it's simple to create a location, fill it with climbs and track your attempts over any
timeframe. It works equally well outdoors where climbs are named and permanent and indoors where you
can archive a climb when it's taken down and replaced with something new.

This app was developed for my own personal use and as a learning experience in exploring flutter.
It has only been tested on android API levels 29 & 30 and has a feature set dictated by what I've found
I want/need in my own climbing sessions.

## Download

I have only made an apk available. If you are looking to install on ios you will have to build it
yourself. I may in future look at releasing an ipa.

[Download the latest release](https://github.com/Meebuhs/sendrax/releases)

Releases for web are pending support from 
[flutter's firebase plugins](https://github.com/FirebaseExtended/flutterfire) and desktop is pending
 [flutter support](https://flutter.dev/desktop)

## Build

The app has been developed on `flutter channel stable`, which as of the latest release was `2.2.3`.

Ensure that you have [flutter installed](https://flutter.dev/docs/get-started/install).

The android build process requires a `android/keystore.properties` file with the following entries:
```
storeFile=~/path/to/keystore
storePassword=
keyAlias=
keyPassword=
```

You will also have to set up a firebase project and add `google-services.json` for android and 
`GoogleService-Info.plist` for ios. Instructions for adding firebase to flutter can be 
[found here](https://firebase.google.com/docs/flutter/setup).

Then
```
git clone https://github.com/Meebuhs/sendrax
cd sendrax
flutter run
```

<p align="center">
  <img src="docs/sendrax-george.jpg" width="50%"></br>
  <i>They've got some new kind of technique for televising opera </i>
</p>
