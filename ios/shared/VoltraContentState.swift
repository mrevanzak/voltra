import ActivityKit
import Compression
import Foundation

public enum ContentStateParsingError: Error {
  case invalidJsonString
  case jsonDeserializationFailed(Error)
  case invalidRootType
  case componentsParsingFailed(Error)
  case regionParsingFailed(VoltraRegion, Error)
}

/// Shared content state for both standard and supplemental activity types
public struct VoltraContentState: Codable, Hashable {
  public let uiJsonData: String

  /// Parsed payload (computed once, cached)
  public let payload: VoltraLiveActivityPayload

  private enum CodingKeys: String, CodingKey {
    case uiJsonData
  }

  /// Initialize with compressed JSON data
  public init(uiJsonData: String) throws {
    self.uiJsonData = uiJsonData

    // Decompress and parse once
    let decompressedJson = try BrotliCompression.decompress(base64String: uiJsonData)
    payload = try VoltraLiveActivityPayload(jsonString: decompressedJson)
  }

  // MARK: - Convenience Accessors

  public var regions: [VoltraRegion: [VoltraNode]] {
    payload.regions
  }

  public var keylineTint: String? {
    payload.keylineTint
  }

  public var activityBackgroundTint: String? {
    payload.activityBackgroundTint
  }

  // MARK: - Codable

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let compressedJson = try container.decode(String.self, forKey: .uiJsonData)
    try self.init(uiJsonData: compressedJson)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(uiJsonData, forKey: .uiJsonData)
  }
}
