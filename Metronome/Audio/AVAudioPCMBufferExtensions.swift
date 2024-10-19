import AVFAudio

extension AVAudioPCMBuffer {
    func reduce(bucketCount: Int) -> ([Float], Float) {
        let frameCount = Int(self.frameLength)
        guard let channelData = self.floatChannelData, frameCount > 0 else { return ([], 0) }
        // TODO: Assuming mono
        let samples = Array(UnsafeBufferPointer(start: channelData[0], count: frameCount))
        let samplesPerBucket = max(1, frameCount / bucketCount)

        var buckets = [Float](repeating: 0, count: bucketCount)
        var maxBucket: Float = 0
        for i in 0..<bucketCount {
            let bucketStart = i * samplesPerBucket
            let bucketEnd = min((i + 1) * samplesPerBucket, frameCount)
            let bucketSamples = samples[bucketStart..<bucketEnd]
            let avgSample = bucketSamples.reduce(into: Float(0)) { partialResult, value in
                if abs(value) > abs(partialResult) {
                    partialResult = value
                }
            }
            buckets[i] = avgSample
            if abs(avgSample) > maxBucket {
                maxBucket = abs(avgSample)
            }
        }
        return (buckets, maxBucket)
    }
}

extension AVAudioPCMBuffer {
    func append(_ buffer: AVAudioPCMBuffer, frameCount: AVAudioFrameCount) {
        precondition(format == buffer.format, "Format mismatch")
        precondition(frameCount <= buffer.frameLength, "Insufficient audio in buffer")
        precondition(frameLength + frameCount <= frameCapacity, "Insufficient space in buffer")

        for channel in 0..<Int(format.channelCount) {
            let dst = self.floatChannelData![channel]
            let src = buffer.floatChannelData![channel]

            memcpy(
                dst.advanced(by: stride * Int(frameLength)),
                src,
                Int(frameCount) * stride * MemoryLayout<Float>.size
            )
        }
        frameLength += frameCount
    }
}

extension AVAudioPCMBuffer {
    func visualDescription(width: Int = 60, height: Int = 15) -> String {
        assert((height - 1).isMultiple(of: 2))
        let rows = [
            "Format \(self.format)",
            "Frame count \(self.frameLength)",
            "Frame capacity \(self.frameCapacity)"
        ]
        let frameCount = Int(self.frameLength)
        guard let channelData = self.floatChannelData, frameCount > 0 else {
            return rows.joined(separator: "\n")
        }
        let (buckets, maxBucket) = reduce(bucketCount: width)
        let scaleFactor = maxBucket > 0 ? Float((height - 1) / 2) / maxBucket : 1.0
        let half = Int((Double(height) / 2).rounded(.up))
        let waveformRows = (0..<height).map { rowIndex in
            let row = height - rowIndex
            return "\(abs(row - half))│ " + String(
                buckets.map { value in
                    let scaled = value * scaleFactor
                    let max = Int(half) + Int(scaled)
                    if row > Int(half) {
                        return (max == row && scaled > 0) ? "*" : " "
                    } else if row < Int(half) {
                        return (row == max && scaled < 0) ? "*" : " "
                    } else {
                        return (row == max) ? "*" : " "
                    }
                }
            )
        }
        return (rows + waveformRows).joined(separator: "\n")
    }

    @objc func debugQuickLookObject() -> Any? {
        visualDescription()
    }
}