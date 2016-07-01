Genome Test App
===========

The higher level purpose of this app is to demonstrate an understanding of various parts of mobile app development. Some of these include:

1. Asynchronous tasks
2. Image caching
3. Storyboards
4. Location management and maps
5. Error handling
6. Facebook integration
7. Unit testing
8. Table views=

More specifically, the app first provides the user with the ability to login with Facebook. If logged in, the user is presented with a map view displaying their current location on the map and a button to zoom in closer to their position. The app uses the user's location to query the Google Maps API and display 25 Google "Places" nearby. These places are populated in a scrolling table view with their name and image. Once clicked, the table view presents a more detailed representation of the place, incluing the Place's website, phone number and address if available. The user can refresh the table view to query a new 25 places if their location has changed. 

Requirements
============

This project requires Cocoapods. To install cocoapods run sudo gem install cocoapods or refer to the document below

https://guides.cocoapods.org/using/getting-started.html


Installation
==========

To access the project:

1. git clone or unzip the app to desktop

1. If you have not installed cocoapods yet, run sudo gem install cocoapods

3. cd into the Genome folder from Terminal

4. Run pod install. The .gitignore of the app contains the Pods directory, so only the Podfile will be available. I recommend keeping it this way, as the GoogleMaps frame work is larger than the 100 MB max file size that Github allows. Future developers can decide the merits of checking in the Pods directory or not.

5. open the newly created Genome.xcworkspace


Testing
=======
Tests are handled by the HingeExerciseTests target. Run CMD + U to run tests.
