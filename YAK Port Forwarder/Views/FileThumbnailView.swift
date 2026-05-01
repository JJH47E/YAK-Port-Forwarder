//
//  FileThumbnailView.swift
//  YAK Port Forwarder
//

import SwiftUI

struct FileThumbnailView: View {
    let url: URL

    private let thumbnailColors: [Color] = [
        .red, .orange, .yellow, .green, .teal, .blue, .purple, .pink
    ]

    private var colorIndex: Int {
        url.lastPathComponent.unicodeScalars.reduce(0) { $0 + Int($1.value) } % thumbnailColors.count
    }

    private var initial: String {
        guard let first = url.lastPathComponent.first else { return "?" }
        return first.uppercased()
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(thumbnailColors[colorIndex])
                .frame(width: 36, height: 36)
            Text(initial)
                .font(.title2.bold())
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        FileThumbnailView(url: URL(fileURLWithPath: "/tmp/kube-port-forward.yak"))
        FileThumbnailView(url: URL(fileURLWithPath: "/tmp/staging.yak"))
        FileThumbnailView(url: URL(fileURLWithPath: "/tmp/production.yak"))
    }
    .padding()
}
