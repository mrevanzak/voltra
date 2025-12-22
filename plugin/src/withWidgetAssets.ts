import { ConfigPlugin, withDangerousMod } from '@expo/config-plugins'
import * as fs from 'fs'
import * as path from 'path'

import { copyUserImages, DEFAULT_USER_IMAGES_PATH } from './lib/copyUserImages'
import { generateAssetsCatalog } from './lib/generateAssetsCatalog'
import { generateInfoPlist } from './lib/generateInfoPlist'

/**
 * Plugin step that generates the widget extension's asset files.
 *
 * This creates:
 * - Info.plist (required extension manifest)
 * - Assets.xcassets/ (asset catalog with user images)
 *
 * This should run before withXcode so the files exist when Xcode project is configured.
 */
export const withWidgetAssets: ConfigPlugin<{
  targetName: string
  userImagesPath?: string
}> = (config, { targetName, userImagesPath = DEFAULT_USER_IMAGES_PATH }) => {
  return withDangerousMod(config, [
    'ios',
    async (config) => {
      const { platformProjectRoot } = config.modRequest
      const targetPath = path.join(platformProjectRoot, targetName)

      // Ensure target directory exists
      if (!fs.existsSync(targetPath)) {
        fs.mkdirSync(targetPath, { recursive: true })
      }

      // Generate Info.plist
      const infoPlistPath = path.join(targetPath, 'Info.plist')
      fs.writeFileSync(infoPlistPath, generateInfoPlist())
      console.log('[Voltra] Generated Info.plist')

      // Generate Assets.xcassets structure
      generateAssetsCatalog(targetPath)
      console.log('[Voltra] Generated Assets.xcassets')

      // Copy user images to asset catalog
      const assetsPath = path.join(targetPath, 'Assets.xcassets')
      copyUserImages(userImagesPath, assetsPath)

      return config
    },
  ])
}
