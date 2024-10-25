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
            process(
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

// @_noLocks
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
            scheduleMIDI(position)
        }
    }
}
