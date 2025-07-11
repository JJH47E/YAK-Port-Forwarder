//
//  Splash.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 11/07/2025.
//

import SwiftUI

struct Splash: View {
    @StateObject var viewModel = KubeViewModel()
    
    var body: some View {
        Group {
            if (viewModel.loaded) {
                MainContent(viewModel: viewModel)
            } else {
                VStack {
                    Image(systemName: "plus.square.dashed")
                        .resizable()
                        .frame(width: 100, height: 100)
                    Text("You haven't created any port forwards")
                        .fontDesign(.rounded)
                        .padding()
                    Button {
                        viewModel.createNew()
                    } label: {
                        Label("Create Configuration File", systemImage: "plus")
                            .labelStyle(.titleAndIcon)
                            .padding(CGFloat(8))
                    }.buttonStyle(.borderedProminent)
                    Button {
                        print("Loading")
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
