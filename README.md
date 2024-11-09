# Snapshot Testing for Audio DSP

> A picture’s worth a 1000 tests

A presentation given at ADC 2024 conference

## Presentation

[snapshot-testing-audio-dsp.pdf](https://github.com/user-attachments/files/17688832/snapshot-testing-audio-dsp.pdf)

## General

- [Testing Patience](https://www.youtube.com/watch?v=vH7vVAbSE1M) - A great talk by Michael Feathers that challenges mainstream ideas about testing
- [Approval Tests with Llewellyn Falco](http://www.hanselminutes.com/360/approval-tests-with-llewellyn-falco)
- [Audio Sparklines](https://melatonin.dev/blog/audio-sparklines/)
- [Using ASCII waveforms to test real-time audio code](https://goq2q.net/blog/tech/using-ascii-waveforms-to-test-real-time-audio-code)
- [Characterization test](https://en.wikipedia.org/wiki/Characterization_test)
- [Surviving Legacy Code with Golden Master and Sampling](https://blog.thecodewhisperer.com/permalink/surviving-legacy-code-with-golden-master-and-sampling)
- [My blog](https://infinum.com/blog/author/josipcavar/)

### Libraries

- [Swift Snapshot Testing](https://github.com/pointfreeco/swift-snapshot-testing) - A library I've been using in my work (and in the presentation)
- [Approval Tests](https://approvaltests.com) - A project dedicated to approval testing. You can find a link to implementation in for many programming languages

### Previous ADC talks

The idea of snapshot testing has already been covered to some extend in (at least) these talks:

-  [Unit Testing Audio Processors](https://www.youtube.com/watch?v=DIcqoDQxoPI&list=WL)
-  [How to Write Bug-Free, Real-Time Audio C++ Code?](https://www.youtube.com/watch?v=Tvf7VVH53-4)
-  [Test-driven development for audio plugins](https://www.youtube.com/watch?v=aLOlRSu6p00)

## Metronome App

This is a simple metroneome written in Swift. It is associated source code for the presentation.

You can download this source code and explore snapshot tests.

Here are two PRs that were covered in the presentation:

- [Fix incorrectly timed MIDI event](https://github.com/jcavar/Metronome/pull/1)
- [Implement count in along with metronome](https://github.com/jcavar/Metronome/pull/3)

And here is one additional PR that hasn't been covered:

- [Optimise metronome DSP](https://github.com/jcavar/Metronome/pull/2)
