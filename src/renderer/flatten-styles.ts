import type { StyleProp } from 'react-native'

type FlatStyleProp<T> = T extends (infer U)[] ? FlatStyleProp<U> : T

// Adapted from React Native's StyleSheet.flatten
export const flattenStyle = <T extends StyleProp<unknown>>(style: T | null | undefined): FlatStyleProp<T> | null => {
  if (!style) {
    return null
  }

  if (!Array.isArray(style)) {
    return style as FlatStyleProp<T>
  }

  const result: Record<string, unknown> = {}
  for (let i = 0, styleLength = style.length; i < styleLength; ++i) {
    const computedStyle = flattenStyle(style[i])
    if (computedStyle) {
      for (const key in computedStyle) {
        result[key] = computedStyle[key]
      }
    }
  }
  return result as FlatStyleProp<T>
}
