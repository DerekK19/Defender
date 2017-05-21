fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

## Choose your installation method:

<table width="100%" >
<tr>
<th width="33%"><a href="http://brew.sh">Homebrew</a></td>
<th width="33%">Installer Script</td>
<th width="33%">Rubygems</td>
</tr>
<tr>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS</td>
<td width="33%" align="center">macOS or Linux with Ruby 2.0.0 or above</td>
</tr>
<tr>
<td width="33%"><code>brew cask install fastlane</code></td>
<td width="33%"><a href="https://download.fastlane.tools">Download the zip file</a>. Then double click on the <code>install</code> script (or run it in a terminal window).</td>
<td width="33%"><code>sudo gem install fastlane -NV</code></td>
</tr>
</table>

# Available Actions
## iOS
### ios diagnostics
```
fastlane ios diagnostics
```
Diagnostics only
### ios test
```
fastlane ios test
```
Runs all the tests
### ios home
```
fastlane ios home
```
Copy a new Build to home App Store
### ios beta
```
fastlane ios beta
```
Submit a new Beta Build to Apple TestFlight
### ios apple
```
fastlane ios apple
```
Deploy a new version to the App Store

----

## Mac
### mac diagnostics
```
fastlane mac diagnostics
```
Diagnostics only
### mac test
```
fastlane mac test
```
Runs all the tests
### mac home
```
fastlane mac home
```
Copy a new Build to home App Store
### mac beta
```
fastlane mac beta
```
Submit a new Beta Build to Apple TestFlight
### mac apple
```
fastlane mac apple
```
Deploy a new version to the App Store

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
