/**
 * Generates the Info.plist content for a WidgetKit extension.
 *
 * This is the minimal required Info.plist - it only declares the extension point.
 * Build settings (GENERATE_INFOPLIST_FILE=YES) handles the rest.
 */
export function generateInfoPlist(): string {
  return `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSExtension</key>
	<dict>
		<key>NSExtensionPointIdentifier</key>
		<string>com.apple.widgetkit-extension</string>
	</dict>
</dict>
</plist>
`
}
