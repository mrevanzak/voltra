import ActivityKit

/// Protocol shared by all Voltra activity attribute types
public protocol VoltraActivityAttributes: ActivityAttributes where ContentState == VoltraContentState {
  /// Unique identifier for the activity
  var name: String { get }

  /// Optional URL to open when the activity is tapped
  var deepLinkUrl: String? { get }
}
