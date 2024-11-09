import AVFAudio

public let sampleRate: Double = 44100

class Metronome: AVAudioUnitSampler {
    private var token: Int!

    override init(audioComponentDescription description: AudioComponentDescription) {
        super.init(audioComponentDescription: description)
    }

    override init() {
        super.init()
        let preset = Bundle.main.url(forResource: "Metronome", withExtension: "aupreset")!
        try! loadPreset(at: preset)
        overallGain = 12

        let message = UnsafeMutablePointer<UInt8>.allocate(capacity: 3)
        message[0] = 0x90
        message[1] = 12
        message[2] = 127

        let midiBlock = auAudioUnit.scheduleMIDIEventBlock!
        token = auAudioUnit.token { flags, timeStamp, frameCount, bus in
            guard flags == .unitRenderAction_PreRender else { return }
            processOptimised(
                timeStamp: timeStamp.pointee,
                frameCount: frameCount,
                scheduleMIDI: { midiBlock($0, 0, 3, message) }
            )
        }
    }

    deinit {
        auAudioUnit.removeRenderObserver(token)
    }
}

private func process(
    timeStamp: AudioTimeStamp,
    frameCount: AUAudioFrameCount,
    scheduleMIDI: (AUEventSampleTime) -> Void
) {
    let bufferStart = Int64(timeStamp.mSampleTime)
    let bufferEnd = bufferStart + Int64(frameCount)

    for sampleTime in bufferStart...bufferEnd {
        if sampleTime.isMultiple(of: Int64(sampleRate)) {
            let position = sampleTime - bufferStart
            scheduleMIDI(AUEventSampleTimeImmediate + position)
        }
    }
}

var previous: Int64 = -1

private func processOptimised(
    timeStamp: AudioTimeStamp,
    frameCount: AUAudioFrameCount,
    scheduleMIDI: (AUEventSampleTime) -> Void
) {
    let bufferStart = Int64(timeStamp.mSampleTime)
    let bufferEnd = bufferStart + Int64(frameCount)

    let (quotientEnd, remainderEnd) = bufferEnd.quotientAndRemainder(dividingBy: Int64(sampleRate))

    guard quotientEnd > previous else { return }
    let position = Int64(frameCount) - remainderEnd
    scheduleMIDI(AUEventSampleTimeImmediate + position)
    previous = quotientEnd
}
