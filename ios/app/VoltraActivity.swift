import ActivityKit
import Foundation

/// Type-erased wrapper for both standard and supplemental activity types
///
/// This enum abstracts over the two different ActivityAttributes types,
/// providing a unified interface for activity operations. This hides the
/// complexity of managing two separate Activity<T> types from the rest
/// of the service layer.
public enum VoltraActivity {
  case standard(Activity<VoltraAttributes>)
  case withSupplementalFamilies(Activity<VoltraAttributesWithSupplementalFamilies>)

  // MARK: - Unified Accessors

  /// The activity's unique identifier
  public var id: String {
    switch self {
    case let .standard(activity):
      return String(activity.id)
    case let .withSupplementalFamilies(activity):
      return String(activity.id)
    }
  }

  /// The activity's name (same identifier used at creation)
  public var name: String {
    switch self {
    case let .standard(activity):
      return activity.attributes.name
    case let .withSupplementalFamilies(activity):
      return activity.attributes.name
    }
  }

  /// The activity's current content state
  public var contentState: VoltraContentState {
    switch self {
    case let .standard(activity):
      return activity.content.state
    case let .withSupplementalFamilies(activity):
      return activity.content.state
    }
  }

  /// The activity's deep link URL
  public var deepLinkUrl: String? {
    switch self {
    case let .standard(activity):
      return activity.attributes.deepLinkUrl
    case let .withSupplementalFamilies(activity):
      return activity.attributes.deepLinkUrl
    }
  }

  /// The activity's type
  public var activityType: String {
    switch self {
    case .standard:
      return "standard"
    case .withSupplementalFamilies:
      return "supplemental-families"
    }
  }

  // MARK: - Unified Operations

  /// Update the activity with new content
  public func update(_ content: ActivityContent<VoltraContentState>) async {
    switch self {
    case let .standard(activity):
      await activity.update(content)
    case let .withSupplementalFamilies(activity):
      await activity.update(content)
    }
  }

  /// End the activity
  public func end(_ dismissalPolicy: ActivityUIDismissalPolicy = .immediate) async {
    switch self {
    case let .standard(activity):
      await activity.end(dismissalPolicy: dismissalPolicy)
    case let .withSupplementalFamilies(activity):
      await activity.end(dismissalPolicy: dismissalPolicy)
    }
  }
}
