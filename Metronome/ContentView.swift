//
//  ContentView.swift
//  Metronome
//
//  Created by Josip Cavar on 13.09.2024..
//

import SwiftUI
import AVFAudio

struct ContentView: View {
    let engine = AVAudioEngine()
    let metronome = Metronome()

    var body: some View {
        Text("Metronome")
            .onAppear {
                engine.attach(metronome)
                engine.connect(metronome, to: engine.mainMixerNode, format: nil)
                try! engine.start()
            }
    }
}

#Preview {
    ContentView()
}
