import AVFAudio

class CountIn: AVAudioUnitSampler {
    private var token: Int!

    override init(audioComponentDescription description: AudioComponentDescription) {
        super.init(audioComponentDescription: description)
    }

    override init() {
        super.init()
        let preset = Bundle.main.url(forResource: "CountIn", withExtension: "aupreset")!
        try! loadPreset(at: preset)
        overallGain = 12

        let message = UnsafeMutablePointer<UInt8>.allocate(capacity: 3)
        message[0] = 0x90
        message[1] = 12
        message[2] = 127

        let midiBlock = auAudioUnit.scheduleMIDIEventBlock!
        token = auAudioUnit.token(
            byAddingRenderObserver: { flags, timeStamp, frameCount, bus in
                guard flags == .unitRenderAction_PreRender else { return }
                process(
                    timeStamp: timeStamp.pointee,
                    frameCount: frameCount,
                    scheduleMIDI: {
                        message[1] = $1
                        midiBlock($0, 0, 3, message)
                    }
                )
            }
        )
    }

    deinit {
        auAudioUnit.removeRenderObserver(token)
    }
}

private func process(
    timeStamp: AudioTimeStamp,
    frameCount: AUAudioFrameCount,
    scheduleMIDI: (AUEventSampleTime, UInt8) -> Void
) {
    let bufferStart = Int64(timeStamp.mSampleTime)
    let bufferEnd = bufferStart + Int64(frameCount)

    for sampleTime in bufferStart...bufferEnd {
        let position = sampleTime - bufferStart
        if sampleTime == 0 {
            scheduleMIDI(AUEventSampleTimeImmediate + position, 12)
        } else if sampleTime == 44100 {
            scheduleMIDI(AUEventSampleTimeImmediate + position, 24)
        } else if sampleTime == 88200 {
            scheduleMIDI(AUEventSampleTimeImmediate + position, 36)
        }
    }
}
