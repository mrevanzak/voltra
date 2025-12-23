import type { ReactNode } from 'react'

/**
 * Widget size families supported by iOS
 */
export type WidgetFamily =
  | 'systemSmall'
  | 'systemMedium'
  | 'systemLarge'
  | 'systemExtraLarge'
  | 'accessoryCircular'
  | 'accessoryRectangular'
  | 'accessoryInline'

/**
 * Widget variants following the same pattern as LiveActivityVariants.
 * Each key corresponds to a widget family.
 */
export type WidgetVariants = Partial<Record<WidgetFamily, ReactNode>>
