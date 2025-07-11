//
//  KubeViewModel.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import Foundation
import SwiftUI

class KubeViewModel: ObservableObject {
    @Published var portForwards: [KubePortForwardResource] = []
    @Published var context: String? = nil
    @Published var loaded: Bool = false
    
    func addPortForward(_ portForward: KubePortForwardResource) {
        portForwards.append(portForward)
    }
    
    func createNew() {
        load()
        self.loaded = true
    }
    
    func load() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            let task = Process()
            // TODO: Set up for other routes
            task.executableURL = URL(fileURLWithPath: "/usr/local/bin/kubectl")
            task.arguments = ["config", "current-context"]
            
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe

            do {
                try task.run()
                task.waitUntilExit()

                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    DispatchQueue.main.async {
                        self.context = output
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.context = "Unknown context"
                }
            }
        }
    }
    
    func saveAs() {
        let panel = NSSavePanel()
        panel.title = "Save Configuration"
        panel.canCreateDirectories = true
        panel.showsTagField = false

        if panel.runModal() == .OK, let selectedURL = panel.url {
            let jsonEncoder = JSONEncoder()
            do {
                let jsonData = try jsonEncoder.encode(portForwards)
                try jsonData.write(to: selectedURL)
            } catch {
                print("[Save] Save failed, error: \(error.localizedDescription)")
            }
        }
    }
    
    func openFile() {
        let panel = NSOpenPanel()
        panel.title = "Open Configuration"
        panel.canCreateDirectories = true
        panel.showsTagField = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let selectedURL = panel.url {
            let jsonDecoder = JSONDecoder()
            
            do {
                let jsonData = try Data(contentsOf: selectedURL)
                let config = try jsonDecoder.decode([KubePortForwardResource].self, from: jsonData)
                
                self.portForwards = config
                load()
                self.loaded = true
            } catch {
                print("[Open] Failed to open configuration file: \(error.localizedDescription)")
            }
        }
    }
}
