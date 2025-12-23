export type VoltraPropValue = string | number | boolean | null | VoltraNodeJson // Allow component trees in props

export type VoltraElementJson = {
  t: number
  i?: string
  c?: VoltraNodeJson
  p?: Record<string, VoltraPropValue>
}

/**
 * Reference to a shared element by index.
 * Used for element deduplication - when the same JSX element (by reference)
 * appears multiple times in the tree.
 */
export type VoltraElementRef = {
  $r: number
}

export type VoltraNodeJson = VoltraElementJson | VoltraElementJson[] | VoltraElementRef | string
