#  Defender

A MacOS app that allows the user to change the settings on a connected Fender Mustang guitar amplifier.

The workspace contains two applications:

- The MacOS app, which communicates with the amplifier
- An iOS app, which communicates with the Mac App. Convenient if your amplifier is not near your Mac, and you can sit your iPhone or iPad on your music stand or amplifier
- An Apple Watch application that allows presets to be selected.

Note that the MacOS app communicates with the amplifier, the iOS app cannot do this. A technical limitation of iOS is that it cannot talk to arbitrary USB devices. This may be one of the reasons why Fender have moved away from this approach for their modelling amplifiers. Newer Mustang models have bluetooth capability built in, so they can talk directly to an iOS app.

I experimented with a metronome in the watch app, however keeping the watch running permanently proved difficult - the watch goes to sleep unless you keep your hand facing up - hard while playing guitar at the same time. This would be worth revisiting, because something that buzzes on your wrist with each strum would really help new players keep the beat.

Fender have an app - FUSE, which Defender is based on. Fender have stoped development of their app, and they did this before upgrading their app to 64-bit, so FUSE doesn't runs on new versions of MacOS

The app is written in Swift. It's migrated up to Swift 5. It has been built with Xcode 11.5 on MacOS 10.15 (Catalina) as well as 10.14 (Mojave). There is a Jenkins file which has been used for continuous integration.

The app uses 3 external libraries - loaded using Swift Package Manager:
- AFNetworking - The app can load third-party presets from the Fender FUSE site (see below)
- BluetoothKit - The iOS app uses Bluetooth to communicate with the MacOS App
- ObjectMapper - The iOS app and the Apple Watch app use Object Mapper to transfer their data

The graphics are largely home grown, with the knob graphics being photographed by myself. The pedal graphics were an exercise in AutoLayout and are mostly successful.

Fender used to have a web-site that supported FUSE. This had many hundreds of presets, and Defender was able to download those presets. However when Fender discontinued supporting FUSE, they also shut down the web-site. I have left the web interface code in place for the time when someone stands up a site for sharing presets. Maybe such a site would have a different web service interface, but the principle should remain the same.

A few notes about the user interface:
- On the Mac, use the left and right arrows to get the previous and next preset, or drag up and down on the wheel image. Knobs are changed by dragging up and down. If the controls on the amplifier itself are changed, these are reflected in the MacOS app (and then in the iOS app if that is running)
- If the knobs on the apps are changed (by up and down dragging), the amplifier settings are changed, but the amplifier knobs themselves are not rotated - there is then a disconnect between the amplifier's knob positions and the app's knob positions
- Start the MacOS app before starting the iOS app and the iOS app will pair with the MacOS app through Bluetooth. You can start the iOS app first however, then after you've started the MacOS app just tap the bluetooth logo on iOS app and it will pair with the MacOS app.

I have tested the app with a Fender Mustang 3, connected to a Mac Mini through a 5m USB cable. I have tested the iOS app on an iPad Air 2 and an iPhone 10. I haven't used the Watch app for a long time.

I would like to acknowledge work done by snirsch [Mustang MIDI bridge](https://github.com/snhirsch/mustang-midi-bridge). The Mustang amplifier uses its own data transfer protocol and this site described that protocol very well. I copied the file fender_mustang_protocol.txt into the DefenderMacOS/Mustang folder.

Finally, FUSE was a free app from Fender. Please don't take the Defender code and make your own App Store app then charge for it.
