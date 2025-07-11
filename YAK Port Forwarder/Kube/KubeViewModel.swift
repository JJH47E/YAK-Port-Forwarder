//
//  KubeViewModel.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import Foundation

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
}
