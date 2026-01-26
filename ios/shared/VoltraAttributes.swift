import ActivityKit
import Foundation

public struct VoltraAttributes: ActivityAttributes, VoltraActivityAttributes {
  public typealias ContentState = VoltraContentState

  public var name: String
  public var deepLinkUrl: String?
}
