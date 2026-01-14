import type { ActivityFamily, LiveActivityConfig } from '../types'

const VALID_ACTIVITY_FAMILIES: Set<ActivityFamily> = new Set(['small'])

/**
 * Validates a Live Activity configuration.
 * Throws an error if validation fails.
 */
export function validateLiveActivityConfig(config: LiveActivityConfig | undefined): void {
  if (!config) return

  // Validate supplemental families if provided
  if (config.supplementalFamilies) {
    if (!Array.isArray(config.supplementalFamilies)) {
      throw new Error('liveActivity.supplementalFamilies must be an array')
    }

    if (config.supplementalFamilies.length === 0) {
      throw new Error(
        'liveActivity.supplementalFamilies cannot be empty. ' +
          'Either provide families or remove the property to disable supplemental families.'
      )
    }

    for (const family of config.supplementalFamilies) {
      if (!VALID_ACTIVITY_FAMILIES.has(family)) {
        throw new Error(
          `Invalid activity family '${family}'. ` +
            `Valid families are: ${Array.from(VALID_ACTIVITY_FAMILIES).join(', ')}`
        )
      }
    }
  }
}
