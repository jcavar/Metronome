import SwiftUI

struct Bucket: Identifiable {
    let index: Int
    let max: Float

    var id: Int { index }
}

struct WaveformView: View {
    let buckets: [Bucket]
    let absMax: Float

    init(buckets: [Bucket], absMax: Float) {
        self.buckets = buckets
        self.absMax = absMax
    }

    var body: some View {
        HStack(spacing: 1) {
            ForEach(buckets) { bucket in
                let height = absMax > 0 ? (CGFloat(abs(bucket.max)) / CGFloat(absMax)) * 500 : 0
                Color.red.frame(width: 1, height: height)
            }
        }
        .background(Color.black)
    }
}
