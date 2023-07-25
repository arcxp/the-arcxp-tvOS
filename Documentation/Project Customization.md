# Project Customization

Arc XP has provided the Arc XP TV application project for quickly developing original TV applications with Arc XP services. Below, you'll find a list of items worth updating to make the project your own.

Arc XP will continue to update the TV project. You will have continued access to the TV project, and are allowed to merge in new updates to your original project, but be aware that if your project deviates too far from the original Arc XP TV project, merging in new developments from the original Arc XP TV project may become difficult. 

Some of the detail found here can also be found in Arc XP TV's Getting Started documentation. Some additional detail can be found in this document, and updates for customizing the TV project further will be added to this document in the future.

## Configuration

To make your own content available for viewing in the TV project, you'll need the following configuration details. If you don't have these details ready, contact your Arc XP contact, who will be able to provide or find them for you. 

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

## Bundle Identifier and Display Name
To make the project your own, in a way that you'll be able to build and upload the project to the App Store, you'll need to update the "Bundle Identifier". 
1. Navigate to the project in the Project Inspector, which will originally be named `TheArcXPtv`
2. Under targets, select `TheArcXPtv`, and make sure the "General" tab is selected near the top
3. Under the "Identity" section, update the "Bundle Identifier" to something that is unique for your own application. This will allow you to upload the project to the App Store and build on devices with the appropriate permissions
4. While you're in this area of the project, you can also go ahead and update the "Display Name" of the project

## Privacy Policy and Terms of Service
To display our Privacy Policy and Terms of service, we make them available remotely through their own Content story, with ID constants that we store in our `Constants.swift` file. Depending on how your Arc XP Content backend is managed, these may or may not be available to you. If they are, simply update the ANS ID constants in the constants file and ensure that your Privacy Policy and Terms of Service are being fetched and displayed correctly. If these items are not available through the same setup with your Arc XP Content backend, use any means of fetching and populating the necessary text. You can even hard code each into the project. When you've set up the appropriate text for your Privacy Policy and Terms of Service, launch the app and make sure your text is being displayed as expected. Note that while it may appear that the text is cut off, using the Apple TV remote, you can scroll to see the entire text of each. 

## Look and Feel

### App Icon
To update your App Icon, navigate to the `Assets.xcassets` file. There you will find the current App Icons for the application, as well as for the App Store. Update these, and make sure to keep in mind Apple's guidelines for App Icons. You can find more information about App Icons [here](https://developer.apple.com/design/human-interface-guidelines/foundations/app-icons). 

### Launch Screen
To update the Launch Screen, navigate to the `LaunchScreen.storyboard` file, and simply add a new image to the existing `UIImageView` contained in that storyboard view. You can also update the background color to match in any way that you like. Note that **any changes that occur on this page should also be mirrored in the `LoadingScreenViewController`**, as that is where the app transitions to after displaying the launch screen briefly.

### Loading Screen
The loading screen can be customized from the `Main.storyboard` file. There, you'll see that the loading screen is a near exact match to the launch screen, only adding an activity indicator to show that content is being loaded. We recommend that any changes made to the launch screen be made here as well. 

### Tint Colors

We've included an option to set tint colors, which are available to use throughout the app, and are currently used in the buttons of the video detail screen, and link indicators in the Privacy Policy and Terms of Service screens. These tint colors are also available to be used anywhere else you feel is appropriate, by simply referring to the `ThemeManager.tintColor`. To customize your project's tint color, take a look at the `AppDelegate.customizeTheme()` function. There you can define light mode and dark mode tint colors, which will automatically be referenced wherever tint colors are used. With consideration for the potential visibility issues of colors over images, we've also included a parameter to provide a unique tint color for those situations (such as in the video detail screen buttons).

```
ThemeManager.setTintColor(lightMode:darkMode:overImage:)
```

### Fonts
Fonts can be updated in two different ways. First, you can update fonts through the interface builder, by viewing the relevant view controllers and cells under the "Views" directory, and editing the relevant labels in the Inspector, under the "Font" option. Or if you'd prefer to update fonts programmatically, navigate to the relevant label in code, and simply update the `UILabel.font` property to any `UIFont()` value. For more details on how to work with `UIFont`, check out the official documentation [here](https://developer.apple.com/documentation/uikit/uifont/1619041-init). Or if you'd like to import your own custom font to use, we recommend following [this guide](https://sarunw.com/posts/how-to-add-custom-fonts-to-ios-app/).

```
myLabel.font = UIFont(name:size:)
```

### Light Mode and Dark Mode
tvOS allows the ability to choose either a dark or light mode in the system settings. tvOS initially defaults to dark mode, but if you go into the tvOS Settings app, this can be changed under "General > Appearance". In the `ThemeManager`, we've specified text colors that should be used for either case. We've also included a value that you can use to set specific colors throughout the app. Simply reference `ThemeManager.lightModeEnabled` to determine how to set your colors.