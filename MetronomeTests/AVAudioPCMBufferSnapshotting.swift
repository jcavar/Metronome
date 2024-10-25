//
//  AVAudioPCMBufferSnapshotting.swift
//  Metronome
//
//  Created by Josip Cavar on 25.10.2024..
//

import SnapshotTesting
import AVFAudio
import AppKit
@testable import Metronome
import SwiftUI

extension Snapshotting where Format == String, Value == AVAudioPCMBuffer {
    static func bufferText(width: Int, height: Int) -> Snapshotting {
        Snapshotting(
            pathExtension: "txt",
            diffing: .lines,
            snapshot: { $0.visualDescription(width: width, height: height) }
        )
    }
}

extension Snapshotting where Format == NSImage, Value == AVAudioPCMBuffer {
    static func bufferImage<Overlay: View>(width: Int, height: Int, overlay: Overlay?) -> Snapshotting {
        Snapshotting<NSView, NSImage>.image(size: .init(width: width, height: height))
            .pullback { buffer in
                let (buckets, max) = buffer.reduce(bucketCount: width)
                let data = buckets.enumerated().map(Bucket.init)
                let waveform = WaveformView(buckets: data, absMax: max, height: CGFloat(height))
                if let overlay {
                    return NSHostingView(rootView: waveform.overlay(overlay))
                } else {
                    return NSHostingView(rootView: waveform)
                }
            }
    }

    static func bufferImage(width: Int, height: Int) -> Snapshotting {
        .bufferImage(width: width, height: height, overlay: Optional<EmptyView>.none)
    }
}
