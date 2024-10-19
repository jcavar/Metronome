import AVFAudio

public let sampleRate: Double = 44100

class Metronome: AVAudioUnitSampler {
    private var token: Int!

    override init(audioComponentDescription description: AudioComponentDescription) {
        super.init(audioComponentDescription: description)
    }

    override init() {
        super.init()
        // TODO: Extract
        auAudioUnit.maximumFramesToRender = UInt32(10 * sampleRate)
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
                midiBlock: midiBlock,
                message: message
            )
        }
    }

    deinit {
        auAudioUnit.removeRenderObserver(token)
    }
}

// @_noLocks
func process(
    timeStamp: AudioTimeStamp,
    frameCount: AUAudioFrameCount,
    midiBlock: AUScheduleMIDIEventBlock,
    message: UnsafePointer<UInt8>
) {
    let start = Int64(timeStamp.mSampleTime)
    let end = start + Int64(frameCount)
    let tickStart = Int(Double(start) / sampleRate)
    let tickEnd = Int(Double(end) / sampleRate)
    guard tickEnd > tickStart else { return }
    for tick in tickStart...tickEnd {
        let position = (Int64(Double(tick) * Double(sampleRate))) - start
        midiBlock(position, 0, 3, message)
    }
}
