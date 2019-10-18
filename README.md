# FliPho-iOS
FliPho: just another iOS client for Flickr

If you're cloning this project, make sure you get your own key at: https://www.flickr.com/services/apps/create/

The app is under development: there can be various bugs and unexpected crashes.

Use the "Develop" branch for latest additions.

UI: there are no custom cells or custom views yet. The UI contains the minimum elements for showing images.

Functionalities:

- At this moment, users can login into their acccounts and see recent pictures of Explore collection (on Flickr).
- Users can also see their own pictures in a grid-like view. At this moment, only the first 250 images are being shown.
- The app contains a map view, which asks for user location, so it can retrieve and display images taken around user location.
- When map annotation are tapped, a small accessory view is shown. Tapping the accessory view will pass the image to another screen.
- When tapped, images from MyFeeds & MyPhotos are being passed into a different view, so that images can be zoomed in / out.
- Users can also deauthenticate from their accounts.

Features under development:

- MyFeeds tab: 
  - cells will have a different size and customization such as shapes and animations
  - cells shown in MyFeeds, will also show a small rounded profile picture of the owner + owner name
  - when a cell is tapped, the image is passed into another screen (Detailed View) which will fetch & display comments for that image
  - users will be able to add an image to Favorites
  - users will be able to see / retrieve more than 250 pictures from Flickr


- MyPhotos tab:
  - users will be able to see all of their pictures, not just the first 250
  - users will be able to upload images to Flickr
  
- AroundMe tab (mapView):
  - retain cycles that crash the app will be fixed
  - users will be able to search for an address
  - the app will contain a button which, when tapped, will show another view containing a collection of all images shown on map
  
- MyAccount tab:
  - current deauthentication does not work as it should.
  - users will be able to see thier activity on Flickr
  
 
  
