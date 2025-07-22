//
//  MainContent.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import Foundation
import SwiftUI

struct MainContent: View {
    @Environment(\.openURL) var openURL
    @ObservedObject var viewModel: KubeViewModel
    @State private var showAddPortForwardSheet: Bool = false
    @State private var showUpdateNamespaceSheet: Bool = false
    
    var body: some View {
        VStack {
            
            if viewModel.portForwards.isEmpty {
                Spacer()
                VStack {
                    Button {
                        showAddPortForwardSheet.toggle()
                    } label: {
                        Image(systemName: "plus.square.dashed")
                            .resizable()
                    }
                        .buttonStyle(.borderless)
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
            ToolbarItem(placement: .navigation) {
                Button {
                    openURL(URL(string: "https://github.com/JJH47E/YAK-Port-Forwarder")!)
                } label: {
                    Label("GitHub", image: "GitHubSymbol")
                        .labelStyle(.iconOnly)
                }
            }
            
            ToolbarItemGroup {
                Menu {
                    Button {
                        showUpdateNamespaceSheet.toggle()
                    } label: {
                        Label("Change Namespace", systemImage: "arrow.trianglehead.2.clockwise")
                            .labelStyle(.titleAndIcon)
                    }
                } label: {
                    Label("Actions", systemImage: "wand.and.sparkles")
                        .labelStyle(.titleAndIcon)
                        .padding()
                }

                
                Button {
                    viewModel.save()
                } label: {
                    Label("Save", image: "FloppyDisk")
                        .labelStyle(.titleAndIcon)
                        .padding()
                }.disabled(!viewModel.loaded)
                
                if viewModel.runningAll {
                    Button("Stop", systemImage: "stop.fill") {
                        viewModel.startStopAll()
                    }.disabled(viewModel.portForwards.isEmpty)
                } else {
                    Button("Start", systemImage: "play.fill") {
                        viewModel.startStopAll()
                    }.disabled(viewModel.portForwards.isEmpty)
                }
                
                Button("Add", systemImage: "plus") {
                    showAddPortForwardSheet.toggle()
                }
            }
        }
        .sheet(isPresented: $showAddPortForwardSheet) {
            AddPortForward(viewModel: viewModel)
        }
        .sheet(isPresented: $showUpdateNamespaceSheet) {
            UpdateNamespace(viewModel: viewModel)
        }
    }
}

#Preview() {
    MainContent(viewModel: PreviewKubeDataProvider())
}
