import SwiftUI

struct Bucket: Identifiable {
    let index: Int
    let max: Float

    var id: Int { index }
}

struct WaveformView: View {
    let buckets: [Bucket]
    let absMax: Float
    let height: CGFloat

    init(buckets: [Bucket], absMax: Float, height: CGFloat) {
        self.buckets = buckets
        self.absMax = absMax
        self.height = height
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(buckets) { bucket in
                let sampleHeight = absMax > 0 ? (CGFloat(abs(bucket.max)) / CGFloat(absMax)) * height : 0
                Color.red.frame(width: 1, height: sampleHeight)
            }
        }
        .background(Color.black)
    }
}

struct TimelineView: View {
    let count: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<count, id: \.self) { index in
                Color.green.frame(width: 5, height: 100)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
        }
    }
}
