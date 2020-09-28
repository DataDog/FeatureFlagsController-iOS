# FeatureFlagsController

![pod](https://img.shields.io/cocoapods/v/FeatureFlagsController.svg)


FeatureFlagsController is a micro-library to automatically build a SwiftUI Form View from all registered feature flags in a project, leveraging power of functional reactive programming using Combine.


## Requirements
- iOS 13.0+
- Xcode 12.0+
- Swift 5.2+


## Installation

### CocoaPods

Add the following to your `Podfile`:

`pod "FeatureFlagsController"`
 

### Swift Package Manager

`https://github.com/DataDog/FeatureFlagsController` using Xcode 12 SPM integration


## Usage

### FeatureFlagsView

All registered feature flags appear in a `FeatureFlagsView` which is a `SwiftUI.View` composed of a `NavigationView` and a sectionned `Form`.
You can display this view anywhere in your application. In a hidden "debug" menu for example. 

This form keeps track of registered feature flags and display the right UI to modify them at runtime. A `ToggleFeatureFlag` will display a simple `Toggle` (`UISwitch`) while a `PickerFeatureFlag` will display a segmented control or a sub-menu depending the picker style it is given.

### Declaration

Here is how you declare a new Feature Flag:

```swift
let roundedCornersFeatureFlag = ToggleFeatureFlag(
    title: "Rounded Corners", defaultValue: true, group: "Home Screen"
)
```

Declaring a feature flag doesn't do anything on its own, but you still can access its value using the `value` property. Some feature flags types have an alias to the `value` property to make the call-site more clear. For example, the `ToggleFeatureFlag` has the `isEnabled` alias.

### Registration

In order to display a feature flag in the `FeatureFlagsView`, a feature flag must be registered. The `register()` methods return a Combine `AnyPublisher<Value, Never>` emitting immediately the current value, then all value updates. 

Once the Combine subscription is cancelled (for example, when the owning view controller is popped or dismissed), the feature flag disappears from the `FeatureFlagsView`.

```swift
roundedCornersFeatureFlag
    .register() // Adds the feature flag to the `FeatureFlagsView` and returns an AnyPublisher<Bool, Never>
    .map { $0 ? 16 : 0 } // Use all Combine operators you want to
    .assign(to: \.cornerRadius, on: squareView.layer) 
    .store(in: &cancellables) // On cancellation, the feature flag is removed from the `FeatureFlagsView`
```


## License

This framework is provided under the MIT license.
