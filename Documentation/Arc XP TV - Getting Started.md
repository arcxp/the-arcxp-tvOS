# Arc XP TV, tvOS

Arc XP TV is an application that allows browsing and viewing a library of video content, built specifically for the TV screen. Some of the features included with Arc XP TV are:

- Browsing categories of videos
- Searching videos
- Watching both VOD and live video
- Resuming unfinished videos
- Viewing how much of a video has already been watched

Arc XP TV was built to demonstrate frameworks provided by Arc XP, currently including Content and Video SDKs. Additionally, Arc XP TV is built so that clients may remix and populate the application with their own content, providing a quick and easy way to get a TV application out the door.

Here, we'll briefly cover steps for downloading and building the tvOS Arc XP TV application. We'll also explore how you can make the application your own by changing a few details.

## Downloading and building the Arc XP TV project

1. Clone the Arc XP TV repo

```
git clone https://github.com/arc-partners/the-arcxp-tvOS.git
```

2. Open `TheArcXPtv.xcodeproj` in Xcode
3. Verify the following Swift packages are included. These can usually be seen below the files listed in the Xcode Project Navigator. Additionally, you can click the Xcode project, and navigate to the Package Dependencies tab to view installed packages. You may need to wait for these to automatically download.
	- **ArcXPContentSDK**: git@github.com:arc-partners/ArcXPContentSDK-iOS-SP.git
	- **ArcXPVideo**: git@github.com:arc-partners/ArcXPVideoSDK-tvOS-SP.git
	- **SDWebImage**: https://github.com/SDWebImage/SDWebImage.git
4. Finally, build and run the project. The application should begin running in the tvOS simulator.

## Making the project your own

### Configuration

To customize the project for your own content, you'll need some configuration details. If you don't have the details below, get in touch with your Arc XP contact. The details you'll need include:

1. **Content SDK configuration**:
	- Organization name
	- Server environment
	- Site
	- Host domain 
2. **Video SDK configuration**:
	- Organization ID
	- Environment
	- Geo-restriction preference (choose `false` if not specified otherwise)

With the gathered details listed above, navigate to the `ContentProvider.swift` file and update the configuration details in the `ContentProvider.configureArcXPSDKs()` function.

After updating the configuration details, run the application and verify that content from your own Arc XP backend is visible in the application. If you're not able to access your content based on the configuration details above, reach out to your Arc XP contact for help with troubleshooting.

### Look and feel

To make the application truly your own, you'll want to update the following:
1. App icon
2. Launch screen
3. Loading screen (should be the same ad the loading screen image)
4. Privacy policy
5. Terms of service

#### App Icon
To update your App Icon, navigate to the `Assets.xcassets` file. There you will find the current App Icons for the application, as well as for the App Store. Update these, and make sure to keep in mind Apple's guidelines for App Icons. You can find more information about App Icons [here](https://developer.apple.com/design/human-interface-guidelines/foundations/app-icons). 

#### Launch Screen
To update the Launch Screen, navigate to the `LaunchScreen.storyboard` file, and simply add a new image to the existing `UIImageView` contained in that storyboard view. You can also update the background color to match in any way that you like. Note that **any changes that occur on this page should also be mirrored in the `LoadingScreenViewController`**, as that is where the app transitions to after displaying the launch screen briefly.

#### Loading Screen
The loading screen can be customized from the `Main.storyboard` file. There, you'll see that the loading screen is a near exact match to the launch screen, only adding an activity indicator to show that content is being loaded. We recommend that any changes made to the launch screen be made here as well. 

#### Privacy Policy and Terms of Service
To display our Privacy Policy and Terms of service, we make them available remotely through their own Content story, with ID constants that we store in our `Constants.swift` file. Depending on how your Arc XP Content backend is managed, these may or may not be available to you. If they are, simply update the ANS ID constants in the constants file and ensure that your Privacy Policy and Terms of Service are being fetched and displayed correctly. If these items are not available through the same setup with your Arc XP Content backend, use any means of fetching and populating the necessary text. You can even hard code each into the project. When you've set up the appropriate text for your Privacy Policy and Terms of Service, launch the app and make sure your text is being displayed as expected. Note that while it may appear that the text is cut off, using the Apple TV remote, you can scroll to see the entire text of each. 

### Additional customization
Along with the visual updates that can be made, you can also change some of the functionality of the TV app, including:
1. Caching preference
2. Only showing labels on focus

#### Cache Preferences
Arc XP's iOS Content SDK uses caching to optimize content fetches. When setting up the Content SDK configuration, you have the option to set some preferences around caching. These preferences include:
- Amount of time before new content should be fetched
- Cache size limit in megabytes
- If content should be preloaded

You can set your own preferences for caching by navigating to `ContentProvider.swift` and creating your own instance of `ArcXPCacheConfig`. In the initialization of that instance, you can provide values for `timeToConsider`, `cacheSizeLimit`, and `shouldPreloadContent`. Here's a peek at the exact structure of that config type, including default values if you don't specify them yourself:

```
/// Represents the configuration for the cache.
public struct ArcXPCacheConfig {

    /// Cache age limit in mins.
    public var timeToConsider: Double

    /// Cache size in MB
    public var cacheSizeLimit: Int

    /// A boolean to determine whether the cache should be preloading.
    public var shouldPreloadCache: Bool

    public init(timeToConsider: Double = 1.0, cacheSizeLimit: Int = 10, shouldPreloadCache: Bool = true)
}
```

After creating the `ArcXPCacheConfig` instance, simply pass it in as a parameter to the `ArcXPContentManager.setUp(with:cacheConfig:)` function.

#### Showing Labels on Focus
It's common for some TV apps to rely on their images to show their titles. For example, Netflix includes all of  their titles in the video images, which makes displaying a label with the same title below the image redundant. We've provided a quick and easy option to hide labels until their cells are focused, which can cut down on visual clutter. If you'd like to hide your video list labels until a cell is focused, navigate to `VideoListCollectionViewCell.swift` and update the `hideTitleUntilFocused` property to be `true`. This will only show titles when the user has focused a specific cell. Note that the same property also exists in `HeroSectionCollectionViewCell`, but is intentionally set to `false` because it inherits the value from `VideoListCollectionViewCell` and hiding the title in the hero section cell is not intended.

## Conclusion

At this point, the application has been updated to showcase your own content! Feel free to change and/or add anything you like to the application, but keep in mind that if you change your application too much, you may not be able to easily merge new updates made to the original Arc XP TV project to your own. With the right maintenance, you can continue to receive updates made to our Arc XP TV project. But now you've got your own TV project, powered by Arc XP, to handle any way you like! 