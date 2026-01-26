import ActivityKit
import Foundation

/// Activity attributes for Live Activities that support Watch and CarPlay
///
/// This type is used when you want a Live Activity to be displayed on
/// Apple Watch, CarPlay, and other supplemental activity family destinations
/// in addition to the iPhone lock screen and Dynamic Island.
///
/// Use this type instead of `VoltraAttributes` when creating a Live Activity
/// that should support Watch/CarPlay display.
public struct VoltraAttributesWithSupplementalFamilies: ActivityAttributes, VoltraActivityAttributes {
  public typealias ContentState = VoltraContentState

  public var name: String
  public var deepLinkUrl: String?
}
