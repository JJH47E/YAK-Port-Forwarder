//
//  KubePortForwardResource.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import Foundation
import Combine

class KubePortForwardResource : ObservableObject {
    @Published var resourceName: String
    @Published var resourceType: KubeResourceType
    @Published var namespace: String
    @Published var forwardedPorts: [PortMapping]
    @Published var status: PortForwardStatus
    
    private var portForwardProcess: Process?
    
    init(resourceName: String, resourceType: KubeResourceType, namespace: String, forwardedPorts: [PortMapping]) {
        self.resourceName = resourceName
        self.resourceType = resourceType
        self.namespace = namespace
        self.forwardedPorts = forwardedPorts
        self.status = .idle
    }
    
    static func new() -> KubePortForwardResource {
        return KubePortForwardResource(resourceName: "", resourceType: .pod, namespace: "", forwardedPorts: [])
    }
    
    func addNewPortMapping() -> Void {
        self.forwardedPorts.append(PortMapping.new())
        objectWillChange.send()
    }
    
    func startStop() {
        if (self.status == .running) {
            stop()
        } else {
            start()
        }
    }
    
    func start() {
        guard self.portForwardProcess == nil else {
            print("Error: Port forward process is already running.")
            return
        }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            // Prep command to execute
            let portsToForward = self.forwardedPorts.map { "\($0.localPort!):\($0.remotePort!)" }
            let resourceIdentifier = "\(self.resourceType.resourceName.isEmpty ? self.resourceType.resourceName : "\(self.resourceType.resourceName)/")\(self.resourceName)"
            
            var arguments = ["port-forward", resourceIdentifier, "-n", self.namespace]
            arguments.append(contentsOf: portsToForward)
            
            // Spin up the process
            let task = Process()
            // TODO: Set up for other routes
            task.executableURL = URL(fileURLWithPath: "/usr/local/bin/kubectl")
            task.arguments = arguments
            
            task.terminationHandler = { process in
                DispatchQueue.main.async {
                    if process.terminationReason == .exit && process.terminationStatus == 0 {
                        self.status = .stopped
                    } else if process.terminationStatus == 15 { // SIGTERM is typically a status code of 15
                        self.status = .stopped
                    } else {
                        print("Process Terminated with error: \(process.terminationStatus)")
                        self.status = .error
                    }
                    self.portForwardProcess = nil
                }
            }
            
            // Run the process
            do {
                DispatchQueue.main.async {
                    self.status = .running
                }
                self.portForwardProcess = task
                try task.run()

                // Block thread until process ends
                task.waitUntilExit()
            } catch {
                DispatchQueue.main.async {
                    print("Error running process: \(error.localizedDescription)")
                    self.status = .error
                    self.portForwardProcess = nil
                }
            }
        }
    }
    
    func stop() {
        guard let process = self.portForwardProcess, process.isRunning else {
            if self.status == .running {
                self.status = .stopped
            }
            self.portForwardProcess = nil
            return
        }
        
        process.terminate()
        
        self.status = .stopped
    }
}

