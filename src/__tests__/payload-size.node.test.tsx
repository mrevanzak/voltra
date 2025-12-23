import React from 'react'

import { BasicLiveActivityUI } from '../../example/components/live-activities/BasicLiveActivityUI.js'
import { MusicPlayerLiveActivityUI } from '../../example/components/live-activities/MusicPlayerLiveActivityUI.js'
import { renderLiveActivityToString } from '../server.js'

/**
 * Payload Size Regression Tests
 *
 * These tests track payload sizes for real example components.
 * Any size change will fail the test and require updating the snapshot.
 *
 * - Size decreased? Great! Run `pnpm test -u` to lock in the improvement.
 * - Size increased? Investigate before updating - is the increase justified?
 */

const getPayloadSize = async (variants: Parameters<typeof renderLiveActivityToString>[0]): Promise<number> => {
  const compressedPayload = await renderLiveActivityToString(variants)
  return compressedPayload.length
}

// Sample data for examples
const sampleSong = {
  title: 'Midnight Dreams',
  artist: 'The Voltra Collective',
  image: 'voltra-icon',
}

describe('Payload size regression tests', () => {
  it('BasicLiveActivityUI', async () => {
    const size = await getPayloadSize({
      lockScreen: <BasicLiveActivityUI />,
    })

    expect(size).toMatchSnapshot()
  })

  it('MusicPlayerLiveActivityUI', async () => {
    const size = await getPayloadSize({
      lockScreen: <MusicPlayerLiveActivityUI currentSong={sampleSong} isPlaying={true} />,
    })

    expect(size).toMatchSnapshot()
  })
})
