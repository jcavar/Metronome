//
//  ContentView.swift
//  Metronome
//
//  Created by Josip Cavar on 13.09.2024..
//

import SwiftUI
import AVFAudio

struct ContentView: View {
    @State private var isPlaying: Bool = false
    let engine = AVAudioEngine()
    let metronome = Metronome()

    var body: some View {
        Text("Metronome")
            .onAppear {
                engine.attach(metronome)
                engine.connect(metronome, to: engine.mainMixerNode, format: nil)
            }
        Button(isPlaying ? "Stop" : "Start" ) {
            if isPlaying {
                engine.pause()
            } else {
                try! engine.start()
            }
            isPlaying.toggle()
        }
    }
}

#Preview {
    ContentView()
}
