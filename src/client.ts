// Helpers API
export { isGlassSupported, isHeadless } from './helpers.js'

// Events API
export * from './events.js'

// Preview API
export {
  VoltraLiveActivityPreview,
  type VoltraLiveActivityPreviewProps,
} from './components/VoltraLiveActivityPreview.js'
export { VoltraView, type VoltraViewProps } from './components/VoltraView.js'
export { VoltraWidgetPreview, type VoltraWidgetPreviewProps } from './components/VoltraWidgetPreview.js'

// Renderer API
export type { VoltraVariants } from './renderer/index.js'
export type { VoltraElementJson, VoltraJson, VoltraNodeJson, VoltraVariantsJson } from './types.js'

// Preload API
export {
  clearPreloadedImages,
  type PreloadImageOptions,
  preloadImages,
  type PreloadImagesResult,
  reloadLiveActivities,
} from './preload.js'

// Live Activity API
export {
  endAllLiveActivities,
  type EndLiveActivityOptions,
  isLiveActivityActive,
  type SharedLiveActivityOptions,
  startLiveActivity,
  type StartLiveActivityOptions,
  stopLiveActivity,
  updateLiveActivity,
  type UpdateLiveActivityOptions,
  useLiveActivity,
  type UseLiveActivityOptions,
  type UseLiveActivityResult,
} from './liveactivity-api.js'

// Widget API
export {
  clearAllWidgets,
  clearWidget,
  reloadWidgets,
  updateWidget,
  type UpdateWidgetOptions,
  type WidgetFamily,
  type WidgetVariants,
} from './widget-api.js'
