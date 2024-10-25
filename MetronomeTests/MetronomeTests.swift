import Testing
@_spi(Experimental) import SnapshotTesting
@testable import Metronome
import AVFAudio
import SwiftUI

struct MetronomeTests {
    let engine = AVAudioEngine()
    let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!

    init() throws {
        try engine.enableManualRenderingMode(
            .offline,
            format: format,
            maximumFrameCount: UInt32(10 * sampleRate)
        )
    }

    @Test(.snapshots(record: false, diffTool: .ksdiff))
    @MainActor
    func metronomeEverySecond() async throws {
        let node = Metronome()
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: nil)

        try engine.start()
        let bufferSize: AVAudioFrameCount = 2048
        let time = 10
        let allData = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(time) * UInt32(sampleRate))!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: bufferSize)!
        while allData.frameLength < allData.frameCapacity {
            let length = min(bufferSize, allData.frameCapacity - allData.frameLength)
            try engine.renderOffline(length, to: buffer)
            allData.append(buffer, frameCount: length)
        }
        assertSnapshot(of: allData, as: .bufferImage(width: 10000, height: 4000, overlay: TimelineView(count: time)))
        assertSnapshot(of: allData, as: .bufferText(width: 60, height: 15))
    }
}
