//
//  MainContent.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import Foundation
import SwiftUI

struct MainContent: View {
    @ObservedObject var viewModel: KubeViewModel
    @State private var showAddPortForwardSheet: Bool = false
    
    var body: some View {
        VStack {
            PortForwardList(portForwards: $viewModel.portForwards)
            
            VStack {
                Text("Current Cluster:")
                    .font(.callout)
                Text(viewModel.cluster)
                    .font(.subheadline)
            }.padding()
        }
        .toolbar {
            ToolbarItemGroup {
                Button("Add", systemImage: "plus") {
                    showAddPortForwardSheet.toggle()
                }
            }
        }
        .sheet(isPresented: $showAddPortForwardSheet) {
            AddPortForward(viewModel: viewModel)
        }
    }
}

#Preview() {
    MainContent(viewModel: PreviewKubeDataProvider())
}
