//
//  MainContent.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import Foundation
import SwiftUI

struct MainContent: View {
    var viewModel: any KubeDataProvider
    @State private var showAddPortForwardSheet: Bool = false
    
    var body: some View {
        VStack {
            Grid {
                ForEach(batchForGrid(n: viewModel.portForwards.count), id: \.self) { portForwardIdx in
                    GridRow {
                        PortForwardItem(portForward: viewModel.portForwards[portForwardIdx[0]])
                        
                        if (portForwardIdx.count > 1) {
                            PortForwardItem(portForward: viewModel.portForwards[portForwardIdx[1]])
                        }
                    }
                    Divider()
                }
            }
            
            VStack {
                Text("Current Cluster:")
                    .font(.callout)
                Text(viewModel.cluster)
                    .font(.subheadline)
            }.padding()
        }
        .toolbar {
            ToolbarItemGroup {
                Button {
                    showAddPortForwardSheet.toggle()
                } label: {
                    Label("Add", systemImage: "plus")
                        .labelStyle(.iconOnly)
                }
            }
        }
        .sheet(isPresented: $showAddPortForwardSheet) {
            AddPortForward()
        }
    }
    
    func batchForGrid(n: Int) -> [[Int]] {
        let range = 0..<n
        return stride(from: 0, to: n, by: 2).map {
            Array(range[$0 ..< Swift.min($0 + 2, n)])
        }
    }
}

#Preview() {
    MainContent(viewModel: PreviewKubeDataProvider())
}
