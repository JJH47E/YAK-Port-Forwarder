//
//  ShellHelper.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 21/07/2025.
//

import Foundation

struct ShellHelper {
    private static let userPath: String? = {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-ilc", "echo $PATH"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let pathString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                return pathString.isEmpty ? nil : pathString
            }
        } catch {
            print("Error fetching shell PATH: \(error.localizedDescription)")
            return nil
        }
        return nil
    }()
    
    static let kubectlExecutable: URL? = {
        let process = createProcess()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = ["kubectl"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let urlString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                return urlString.isEmpty ? nil : URL(fileURLWithPath: urlString)
            }
        } catch {
            print("Error fetching Kubectl exec: \(error.localizedDescription)")
            return nil
        }
        return nil
    }()
    
    static func createProcess() -> Process {
        let process = Process()
        
        var environment = ProcessInfo.processInfo.environment
        
        if let path = userPath {
            environment["PATH"] = path
        }
        
        process.environment = environment
        
        return process
    }
}
