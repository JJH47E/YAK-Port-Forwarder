//
//  PortForwardList.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 09/07/2025.
//

import SwiftUI

struct PortForwardList: View {
    @Binding var portForwards: [KubePortForwardResource]
    
    var body: some View {
        Grid {
            ForEach(batchForGrid(n: portForwards.count), id: \.self) { portForwardIdx in
                GridRow {
                    PortForwardItem(portForward: $portForwards[portForwardIdx[0]])
                    
                    if (portForwardIdx.count > 1) {
                        PortForwardItem(portForward: $portForwards[portForwardIdx[1]])
                    }
                }
                Divider()
            }
        }
    }
    
    func batchForGrid(n: Int) -> [[Int]] {
        let range = 0..<n
        return stride(from: 0, to: n, by: 2).map {
            Array(range[$0 ..< Swift.min($0 + 2, n)])
        }
    }
}

#Preview {
    @Previewable @State var viewModel = PreviewKubeDataProvider()
    PortForwardList(portForwards: $viewModel.portForwards)
}
