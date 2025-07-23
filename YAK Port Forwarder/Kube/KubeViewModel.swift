//
//  KubeViewModel.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import Foundation
import SwiftUI

@Observable
class KubeViewModel: ObservableObject {
    var portForwards: [KubePortForwardResource] = []
    var context: String? = nil
    var loaded: Bool = false
    var runningAll: Bool = false
    var errorText: String? = nil
    var hasError: Bool = false
    var filePath: URL? = nil
    
    func resetError() -> Void {
        self.errorText = nil
        self.hasError = false
    }
    
    func updateNamespace(_ namesapce: String) -> Void {
        for portForward in portForwards {
            portForward.namespace = namesapce
        }
    }
    
    func startStopAll() {
        if self.runningAll {
            for portForward in self.portForwards {
                if portForward.status == .running {
                    portForward.stop()
                }
            }
            
            self.runningAll = false
        } else {
            for portForward in self.portForwards {
                if portForward.status != .running {
                    portForward.start()
                }
            }
            
            self.runningAll = true
        }
    }
    
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
            
            if ShellHelper.kubectlExecutable == nil {
                self.errorText = "Cannot find Kubectl in system PATH. Please install Kubectl and try again."
                self.hasError = true
                return
            }
            
            let task = ShellHelper.createProcess()

            task.executableURL = ShellHelper.kubectlExecutable
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
    
    func save() {
        if self.filePath == nil {
            // Save As
            self.saveAs()
        } else {
            // Save file
            let jsonEncoder = JSONEncoder()
            do {
                let jsonData = try jsonEncoder.encode(portForwards)
                try jsonData.write(to: self.filePath!)
            } catch {
                print("[Save] Save failed, error: \(error.localizedDescription)")
            }
        }
    }
    
    func saveAs() {
        let panel = NSSavePanel()
        panel.title = "Save Configuration"
        panel.canCreateDirectories = true
        panel.showsTagField = false
        panel.nameFieldStringValue = "kube-port-forward.yak"
        
        if panel.runModal() == .OK, let selectedURL = panel.url {
            let jsonEncoder = JSONEncoder()
            do {
                let jsonData = try jsonEncoder.encode(portForwards)
                try jsonData.write(to: selectedURL)
                self.filePath = selectedURL
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
            openFile(selectedURL: selectedURL)
        }
    }
    
    func openFile(selectedURL: URL) {
        let jsonDecoder = JSONDecoder()
        
        do {
            let jsonData = try Data(contentsOf: selectedURL)
            let config = try jsonDecoder.decode([KubePortForwardResource].self, from: jsonData)
            
            for forward in config {
                if (!forward.isValid) {
                    print("[Open] Open file failed. File may be corrupt")
                    self.errorText = "Opening file failed. The file may be corrupt."
                    self.hasError = true
                    return
                }
            }
            
            self.filePath = selectedURL
            self.portForwards = config
            load()
            self.loaded = true
        } catch {
            print("[Open] Failed to open configuration file: \(error.localizedDescription)")
        }
    }
}
