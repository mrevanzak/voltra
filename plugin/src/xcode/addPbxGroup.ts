import { XcodeProject } from '@expo/config-plugins'

import { WidgetFiles } from '../lib/getWidgetFiles'

export function addPbxGroup(
  xcodeProject: XcodeProject,
  {
    targetName,
    widgetFiles,
  }: {
    targetName: string
    widgetFiles: WidgetFiles
  }
) {
  const { swiftFiles, intentFiles, assetDirectories, entitlementFiles, plistFiles } = widgetFiles

  // Add PBX group with all widget files
  // Note: entitlementFiles already includes {targetName}.entitlements from getWidgetFiles
  const { uuid: pbxGroupUuid } = xcodeProject.addPbxGroup(
    [...swiftFiles, ...intentFiles, ...entitlementFiles, ...plistFiles, ...assetDirectories],
    targetName,
    targetName
  )

  // Add PBXGroup to top level group
  const groups = xcodeProject.hash.project.objects['PBXGroup']
  if (pbxGroupUuid) {
    Object.keys(groups).forEach(function (key) {
      if (groups[key].name === undefined && groups[key].path === undefined) {
        xcodeProject.addToPbxGroup(pbxGroupUuid, key)
      }
    })
  }
}
