//
//  VoltraLiveActivityService.swift
//  Voltra
//
//  Service for managing Voltra Live Activities
//

import ActivityKit
import Foundation

// MARK: - Request Types

/// Parameters for creating a Live Activity
public struct CreateActivityRequest {
  /// Unique identifier for the activity (will be generated if nil)
  public let activityId: String?

  /// URL to open when the Live Activity is tapped
  public let deepLinkUrl: String?

  /// UI JSON data
  public let jsonString: String

  /// Optional date when content becomes stale
  public let staleDate: Date?

  /// Score between 0.0 and 1.0 for prioritization (defaults to 0.0)
  public let relevanceScore: Double

  /// Whether to request push token
  public let pushType: PushType?

  /// If true, ends any existing activities with the same name (defaults to true)
  public let endExistingWithSameName: Bool

  /// Activity type: "standard" (iPhone-only) or "supplemental-families" (Watch/CarPlay)
  /// Defaults to "standard" for backward compatibility
  public let activityType: String

  public init(
    activityId: String? = nil,
    deepLinkUrl: String? = nil,
    jsonString: String,
    staleDate: Date? = nil,
    relevanceScore: Double = 0.0,
    pushType: PushType? = nil,
    endExistingWithSameName: Bool = true,
    activityType: String = "standard"
  ) {
    self.activityId = activityId
    self.deepLinkUrl = deepLinkUrl
    self.jsonString = jsonString
    self.staleDate = staleDate
    self.relevanceScore = relevanceScore
    self.pushType = pushType
    self.endExistingWithSameName = endExistingWithSameName
    self.activityType = activityType
  }
}

/// Parameters for updating a Live Activity
public struct UpdateActivityRequest {
  /// New UI JSON data
  public let jsonString: String

  /// Optional date when content becomes stale
  public let staleDate: Date?

  /// Score between 0.0 and 1.0 for prioritization (defaults to 0.0)
  public let relevanceScore: Double

  public init(
    jsonString: String,
    staleDate: Date? = nil,
    relevanceScore: Double = 0.0
  ) {
    self.jsonString = jsonString
    self.staleDate = staleDate
    self.relevanceScore = relevanceScore
  }
}

// MARK: - Service

/// Service for managing Voltra Live Activities
public class VoltraLiveActivityService {
  // MARK: - Availability Checks

  /// Check if Live Activities are supported on this OS version
  public static func isSupported() -> Bool {
    guard #available(iOS 16.2, *) else { return false }
    return true
  }

  /// Check if Live Activities are enabled for this app
  public static func areActivitiesEnabled() -> Bool {
    guard #available(iOS 16.2, *) else { return false }
    return ActivityAuthorizationInfo().areActivitiesEnabled
  }

  // MARK: - Query Operations

  /// Find an activity by its name across both activity types
  /// Searches standard activities first for backward compatibility
  public func findActivity(byName name: String) -> VoltraActivity? {
    guard Self.isSupported() else { return nil }
    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

    // Check standard activities first for backward compatibility
    if let activity = Activity<VoltraAttributes>.activities.first(where: { $0.attributes.name == trimmedName }) {
      return .standard(activity)
    }

    // Check supplemental families activities
    if let activity = Activity<VoltraAttributesWithSupplementalFamilies>.activities.first(where: { $0.attributes.name == trimmedName }) {
      return .withSupplementalFamilies(activity)
    }

    return nil
  }

  /// Find all activities with the same name across both activity types
  public func findActivities(byName name: String) -> [VoltraActivity] {
    guard Self.isSupported() else { return [] }
    var results: [VoltraActivity] = []

    // Collect standard activities
    results.append(contentsOf: Activity<VoltraAttributes>.activities
      .filter { $0.attributes.name == name }
      .map { .standard($0) }
    )

    // Collect supplemental families activities
    results.append(contentsOf: Activity<VoltraAttributesWithSupplementalFamilies>.activities
      .filter { $0.attributes.name == name }
      .map { .withSupplementalFamilies($0) }
    )

    return results
  }

  /// Get all active Voltra activities across both types
  public func getAllActivities() -> [VoltraActivity] {
    guard Self.isSupported() else { return [] }
    var results: [VoltraActivity] = []

    results.append(contentsOf: Activity<VoltraAttributes>.activities.map { .standard($0) })
    results.append(contentsOf: Activity<VoltraAttributesWithSupplementalFamilies>.activities.map { .withSupplementalFamilies($0) })

    return results
  }

  /// Get the latest (most recently created) activity across both types
  public func getLatestActivity() -> VoltraActivity? {
    guard Self.isSupported() else { return nil }
    let allActivities = getAllActivities()
    return allActivities.last
  }

  /// Check if an activity with the given name exists across both types
  public func isActivityActive(name: String) -> Bool {
    findActivity(byName: name) != nil
  }

  // MARK: - Create Operations

  /// Create a new Live Activity
  /// - Parameter request: Parameters for creating the activity
  /// - Returns: The created activity's name (activityId)
  /// - Throws: Error if creation fails
  public func createActivity(_ request: CreateActivityRequest) async throws -> String {
    guard Self.isSupported() else {
      throw VoltraLiveActivityError.unsupportedOS
    }
    guard Self.areActivitiesEnabled() else {
      throw VoltraLiveActivityError.liveActivitiesNotEnabled
    }

    // Generate activityId if not provided
    let finalActivityId = request.activityId?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
      ? request.activityId!.trimmingCharacters(in: .whitespacesAndNewlines)
      : UUID().uuidString

    // End existing activities with the same name if requested
    if request.endExistingWithSameName {
      try await endActivities(byName: finalActivityId)
    }

    // Create initial state (shared between both types)
    let initialState = try VoltraContentState(uiJsonData: request.jsonString)

    // Create activity of the requested type
    switch request.activityType {
    case "supplemental-families":
      let attributes = VoltraAttributesWithSupplementalFamilies(name: finalActivityId, deepLinkUrl: request.deepLinkUrl)
      _ = try Activity.request(
        attributes: attributes,
        content: .init(
          state: initialState,
          staleDate: request.staleDate,
          relevanceScore: request.relevanceScore
        ),
        pushType: request.pushType
      )

    default: // "standard" or any unrecognized value defaults to standard
      let attributes = VoltraAttributes(name: finalActivityId, deepLinkUrl: request.deepLinkUrl)
      _ = try Activity.request(
        attributes: attributes,
        content: .init(
          state: initialState,
          staleDate: request.staleDate,
          relevanceScore: request.relevanceScore
        ),
        pushType: request.pushType
      )
    }

    return finalActivityId
  }

  // MARK: - Update Operations

  /// Update an existing Live Activity
  /// - Parameters:
  ///   - activity: The activity to update
  ///   - request: Parameters for updating the activity
  /// - Throws: Error if update fails
  public func updateActivity(
    _ activity: VoltraActivity,
    request: UpdateActivityRequest
  ) async throws {
    guard Self.isSupported() else {
      throw VoltraLiveActivityError.unsupportedOS
    }

    let newState = try VoltraContentState(uiJsonData: request.jsonString)
    await activity.update(
      ActivityContent(
        state: newState,
        staleDate: request.staleDate,
        relevanceScore: request.relevanceScore
      )
    )
  }

  /// Update an activity by name
  /// - Parameters:
  ///   - name: The activity name (activityId)
  ///   - request: Parameters for updating the activity
  /// - Throws: Error if activity not found or update fails
  public func updateActivity(
    byName name: String,
    request: UpdateActivityRequest
  ) async throws {
    guard let activity = findActivity(byName: name) else {
      throw VoltraLiveActivityError.notFound
    }
    try await updateActivity(activity, request: request)
  }

  // MARK: - End Operations

  /// End a specific activity
  /// - Parameter activity: The activity to end
  /// - Parameter dismissalPolicy: How the activity should be dismissed
  public func endActivity(
    _ activity: VoltraActivity,
    dismissalPolicy: ActivityUIDismissalPolicy = .immediate
  ) async {
    guard Self.isSupported() else { return }
    await activity.end(dismissalPolicy)
  }

  /// End an activity by name
  /// - Parameter name: The activity name (activityId)
  /// - Parameter dismissalPolicy: How the activity should be dismissed
  /// - Throws: Error if activity not found
  public func endActivity(
    byName name: String,
    dismissalPolicy: ActivityUIDismissalPolicy = .immediate
  ) async throws {
    guard let activity = findActivity(byName: name) else {
      throw VoltraLiveActivityError.notFound
    }
    await endActivity(activity, dismissalPolicy: dismissalPolicy)
  }

  /// End all activities with the same name
  /// - Parameter name: The activity name (activityId)
  public func endActivities(byName name: String) async throws {
    guard Self.isSupported() else { return }
    let activities = findActivities(byName: name)
    for activity in activities {
      await endActivity(activity)
    }
  }

  /// End all Voltra Live Activities
  public func endAllActivities() async {
    guard Self.isSupported() else { return }
    let activities = getAllActivities()
    for activity in activities {
      await endActivity(activity)
    }
  }

  // MARK: - Monitoring

  private var monitoredActivityIds: Set<String> = []
  private var monitoringTasks: [Task<Void, Never>] = []

  /// Start monitoring all Live Activities and Push Tokens
  public func startMonitoring(enablePush: Bool) {
    guard Self.isSupported() else { return }

    // 1. Monitor Push-to-Start Tokens
    if enablePush {
      if #available(iOS 17.2, *) {
        startPushToStartTokenObservation()
      }
    }

    // 2. Monitor Live Activity Updates (Creation & Lifecycle)
    startActivityUpdatesObservation(enablePush: enablePush)
  }

  /// Stop all monitoring tasks
  public func stopMonitoring() {
    monitoredActivityIds.removeAll()
    monitoringTasks.forEach { $0.cancel() }
    monitoringTasks.removeAll()
  }

  @available(iOS 17.2, *)
  private func startPushToStartTokenObservation() {
    // Standard Activities
    if let initialTokenData = Activity<VoltraAttributes>.pushToStartToken {
      let token = initialTokenData.hexString
      VoltraEventBus.shared.send(.pushToStartTokenReceived(token: token))
    }
    let standardTask = Task {
      for await tokenData in Activity<VoltraAttributes>.pushToStartTokenUpdates {
        let token = tokenData.hexString
        VoltraEventBus.shared.send(.pushToStartTokenReceived(token: token))
      }
    }
    monitoringTasks.append(standardTask)

    // Supplemental Activities
    if let initialTokenData = Activity<VoltraAttributesWithSupplementalFamilies>.pushToStartToken {
      let token = initialTokenData.hexString
      VoltraEventBus.shared.send(.pushToStartTokenReceived(token: token))
    }
    let supplementalTask = Task {
      for await tokenData in Activity<VoltraAttributesWithSupplementalFamilies>.pushToStartTokenUpdates {
        let token = tokenData.hexString
        VoltraEventBus.shared.send(.pushToStartTokenReceived(token: token))
      }
    }
    monitoringTasks.append(supplementalTask)
  }

  private func startActivityUpdatesObservation(enablePush: Bool) {
    // 1. Handle currently existing activities
    for activity in Activity<VoltraAttributes>.activities {
      monitorActivity(activity, enablePush: enablePush)
    }
    for activity in Activity<VoltraAttributesWithSupplementalFamilies>.activities {
      monitorActivity(activity, enablePush: enablePush)
    }

    // 2. Listen for NEW activities
    let standardUpdatesTask = Task {
      for await newActivity in Activity<VoltraAttributes>.activityUpdates {
        monitorActivity(newActivity, enablePush: enablePush)
      }
    }
    monitoringTasks.append(standardUpdatesTask)

    let supplementalUpdatesTask = Task {
      for await newActivity in Activity<VoltraAttributesWithSupplementalFamilies>.activityUpdates {
        monitorActivity(newActivity, enablePush: enablePush)
      }
    }
    monitoringTasks.append(supplementalUpdatesTask)
  }

  /// Set up observers for an activity's lifecycle
  private func monitorActivity<Attributes: VoltraActivityAttributes>(_ activity: Activity<Attributes>, enablePush: Bool) {
    let activityId = activity.id

    // Avoid duplicate monitoring
    guard !monitoredActivityIds.contains(activityId) else { return }
    monitoredActivityIds.insert(activityId)

    // Lifecycle state changes
    let stateTask = Task {
      for await state in activity.activityStateUpdates {
        VoltraEventBus.shared.send(
          .stateChange(
            activityName: activity.attributes.name,
            state: String(describing: state)
          )
        )
      }
    }
    monitoringTasks.append(stateTask)

    // Push token updates
    if enablePush {
      let tokenTask = Task {
        for await pushTokenData in activity.pushTokenUpdates {
          let pushTokenString = pushTokenData.hexString
          VoltraEventBus.shared.send(
            .tokenReceived(
              activityName: activity.attributes.name,
              pushToken: pushTokenString
            )
          )
        }
      }
      monitoringTasks.append(tokenTask)
    }
  }
}

// MARK: - Errors

public enum VoltraLiveActivityError: Error {
  case unsupportedOS
  case notFound
  case liveActivitiesNotEnabled
}
