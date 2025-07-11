//
//  YAK_Port_ForwarderApp.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import SwiftUI

@main
struct YAK_Port_ForwarderApp: App {
    @StateObject private var viewModel = KubeViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }.commands {
            CommandGroup(after: CommandGroupPlacement.newItem) {
                Button("Save") {
                    viewModel.saveAs()
                }
                .disabled(!viewModel.loaded)
                .keyboardShortcut("S", modifiers: [.command])
                
                Button("Open") {
                    viewModel.openFile()
                }
                .keyboardShortcut("O", modifiers: [.command])
            }
        }
    }
}
