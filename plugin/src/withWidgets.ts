import { ConfigPlugin, withDangerousMod } from '@expo/config-plugins'
import * as fs from 'fs'
import * as path from 'path'

import { generateInitialStatesSwift } from './lib/generateInitialStatesSwift'
import { generateDefaultWidgetBundleSwift, generateWidgetBundleSwift } from './lib/generateWidgetBundle'
import { prerenderWidgetState } from './lib/prerenderWidgetState'
import type { WidgetConfig } from './types'

/**
 * Plugin step that generates the VoltraWidgetBundle.swift file
 * based on the widget configuration
 */
export const withWidgets: ConfigPlugin<{
  targetName: string
  widgets?: WidgetConfig[]
}> = (config, { targetName, widgets }) => {
  return withDangerousMod(config, [
    'ios',
    async (config) => {
      const { platformProjectRoot, projectRoot } = config.modRequest
      const targetPath = path.join(platformProjectRoot, targetName)

      // Ensure target directory exists
      if (!fs.existsSync(targetPath)) {
        fs.mkdirSync(targetPath, { recursive: true })
      }

      // Prerender widget initial states if any widgets have initialStatePath configured
      const prerenderedStates = await prerenderWidgetState(widgets || [], projectRoot)

      // Generate the initial states Swift file
      const initialStatesContent = generateInitialStatesSwift(prerenderedStates)
      const initialStatesPath = path.join(targetPath, 'VoltraWidgetInitialStates.swift')
      fs.writeFileSync(initialStatesPath, initialStatesContent)

      console.log(
        `[Voltra] Generated VoltraWidgetInitialStates.swift with ${prerenderedStates.size} pre-rendered widget states`
      )

      // Generate the widget bundle Swift file
      const widgetBundleContent =
        widgets && widgets.length > 0 ? generateWidgetBundleSwift(widgets) : generateDefaultWidgetBundleSwift()

      const widgetBundlePath = path.join(targetPath, 'VoltraWidgetBundle.swift')
      fs.writeFileSync(widgetBundlePath, widgetBundleContent)

      console.log(`[Voltra] Generated VoltraWidgetBundle.swift with ${widgets?.length ?? 0} home screen widgets`)

      return config
    },
  ])
}
