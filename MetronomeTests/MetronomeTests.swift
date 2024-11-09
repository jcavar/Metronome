import Testing
@_spi(Experimental) import SnapshotTesting
@testable import Metronome
import AVFAudio
import SwiftUI

class MetronomeTests {
    let bufferSize: AVAudioFrameCount = 2048
    let duration = 10
    let engine = AVAudioEngine()
    let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
    lazy var allData = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(duration) * UInt32(sampleRate))!

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
        try engine.render(bufferSize: bufferSize, format: format, to: allData)

        assertSnapshot(of: allData, as: .bufferImage(width: 10000, height: 4000, overlay: TimelineView(count: duration)))
        assertSnapshot(of: allData, as: .bufferText(width: 60, height: 15))
    }

    @Test(.snapshots(record: false, diffTool: .ksdiff))
    @MainActor
    func metronomeAndCountIn() async throws {
        let node = Metronome()
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: nil)

        let node1 = CountIn()
        engine.attach(node1)
        engine.connect(node1, to: engine.mainMixerNode, format: nil)

        try engine.start()
        try engine.render(bufferSize: bufferSize, format: format, to: allData)

        assertSnapshot(of: allData, as: .bufferImage(width: 10000, height: 4000))
    }
}

private extension AVAudioEngine {
    func render(bufferSize: AVAudioFrameCount, format: AVAudioFormat, to allData: AVAudioPCMBuffer) throws {
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: bufferSize)!
        while allData.frameLength < allData.frameCapacity {
            let length = min(bufferSize, allData.frameCapacity - allData.frameLength)
            try renderOffline(length, to: buffer)
            allData.append(buffer, frameCount: length)
        }
    }
}
