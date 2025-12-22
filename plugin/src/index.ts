import { IOSConfig, withPlugins } from 'expo/config-plugins'

import type { VoltraConfigPlugin } from './types'
import { withConfig } from './withConfig'
import withPlist from './withPlist'
import { withPodfile } from './withPodfile'
import { withPushNotifications } from './withPushNotifications'
import { withWidgetAssets } from './withWidgetAssets'
import { withWidgetExtensionEntitlements } from './withWidgetExtensionEntitlements'
import { withWidgets } from './withWidgets'
import { withXcode } from './withXcode'

const withVoltra: VoltraConfigPlugin = (config, props) => {
  const deploymentTarget = '17.0'
  const targetName = `${IOSConfig.XcodeUtils.sanitizedName(config.name)}LiveActivity`
  const bundleIdentifier = `${config.ios?.bundleIdentifier}.${targetName}`

  config.ios = {
    ...config.ios,
    infoPlist: {
      ...config.ios?.infoPlist,
      NSSupportsLiveActivities: true,
      NSSupportsLiveActivitiesFrequentUpdates: false,
      ...(props?.groupIdentifier ? { Voltra_AppGroupIdentifier: props.groupIdentifier } : {}),
      // Store widget IDs in Info.plist for native module to access
      ...(props?.widgets && props.widgets.length > 0 ? { Voltra_WidgetIds: props.widgets.map((w) => w.id) } : {}),
      // Ensure the main app has a URL scheme set so widgetURL can open it (optional feature)
      ...(function ensureURLScheme(existing: Record<string, any>) {
        const scheme =
          typeof (config as any).scheme === 'string' ? (config as any).scheme : config.ios?.bundleIdentifier
        if (!scheme) return {}
        const existingTypes = (existing.CFBundleURLTypes as any[]) || []
        const hasScheme = existingTypes.some(
          (t) => Array.isArray(t?.CFBundleURLSchemes) && t.CFBundleURLSchemes.includes(scheme)
        )
        if (hasScheme) return {}
        return {
          CFBundleURLTypes: [
            ...existingTypes,
            {
              CFBundleURLSchemes: [scheme],
            },
          ],
        }
      })(config.ios?.infoPlist || {}),
    },
  }

  config = withPlugins(config, [
    // Generate widget extension files (Info.plist, Assets.xcassets, user images)
    [withWidgetAssets, { targetName }],
    // Generate Swift files (VoltraWidgetBundle.swift, VoltraWidgetInitialStates.swift)
    [withWidgets, { targetName, widgets: props?.widgets }],
    // Generate entitlements file
    [withWidgetExtensionEntitlements, { targetName, groupIdentifier: props?.groupIdentifier }],
    // Configure Xcode project (must run after files are generated)
    [
      withXcode,
      {
        targetName,
        bundleIdentifier,
        deploymentTarget,
      },
    ],
    // Update Info.plist with URL schemes
    [withPlist, { targetName, groupIdentifier: props?.groupIdentifier }],
    // Configure EAS build settings
    [withConfig, { targetName, bundleIdentifier, groupIdentifier: props?.groupIdentifier }],
    // Add Podfile target for widget extension
    [withPodfile, { targetName }],
  ])

  if (props?.enablePushNotifications) {
    config = withPushNotifications(config)
  }

  return config
}

export default withVoltra
