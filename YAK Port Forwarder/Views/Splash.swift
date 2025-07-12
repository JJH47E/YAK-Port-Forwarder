//
//  Splash.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 11/07/2025.
//

import SwiftUI

struct Splash: View {
    @ObservedObject var viewModel: KubeViewModel
    
    var body: some View {
        Group {
            if (viewModel.loaded) {
                MainContent(viewModel: viewModel)
            } else {
                VStack {
                    let appIcon = NSImage(named: "AppIcon")
                    
                    VStack {
                        if appIcon != nil {
                            Image(nsImage: NSImage(named: "AppIcon")!)
                                .resizable()
                                .frame(width: 100, height: 100)
                        } else {
                            Image(systemName: "plus.square.dashed")
                                .resizable()
                                .frame(width: 100, height: 100)
                        }
                    
                        Text("Yet Another Kubernetes Port Forwarder")
                            .font(.headline)
                        Text("You haven't created any port forwards")
                            .font(.subheadline)
                    }.padding()
                    Button {
                        viewModel.createNew()
                    } label: {
                        Label("Create Configuration File", systemImage: "plus")
                            .labelStyle(.titleAndIcon)
                            .padding(CGFloat(8))
                    }.buttonStyle(.borderedProminent)
                    Button {
                        viewModel.openFile()
                    } label: {
                        Label("Open Configuration File", systemImage: "document")
                            .labelStyle(.titleAndIcon)
                    }.buttonStyle(.borderless)
                }
            }
        }
    }
}

#Preview {
    Splash(viewModel: PreviewKubeDataProvider())
}
