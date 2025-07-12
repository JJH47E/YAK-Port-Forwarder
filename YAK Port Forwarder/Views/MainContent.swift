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
            
            if viewModel.portForwards.isEmpty {
                Spacer()
                VStack {
                    Image(systemName: "plus.square.dashed")
                        .resizable()
                        .frame(width: 100, height: 100)
                    Text("You haven't created any port forwards")
                        .fontDesign(.rounded)
                        .padding()
                }
            } else {
                ScrollView {
                    PortForwardList(portForwards: $viewModel.portForwards)
                }
            }
            
            Spacer()
            
            VStack {
                Text("Current Context:")
                    .font(.callout)
                if (viewModel.context != nil) {
                    Text(viewModel.context!)
                        .font(.subheadline)
                } else {
                    ProgressView()
                }
            }.padding()
        }
        .toolbar {
            ToolbarItemGroup {
                Button("Add", systemImage: "plus") {
                    showAddPortForwardSheet.toggle()
                }
                
                if viewModel.runningAll {
                    Button("Stop", systemImage: "stop.fill") {
                        viewModel.startStopAll()
                    }.disabled(viewModel.portForwards.isEmpty)
                } else {
                    Button("Start", systemImage: "play.fill") {
                        viewModel.startStopAll()
                    }.disabled(viewModel.portForwards.isEmpty)
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
