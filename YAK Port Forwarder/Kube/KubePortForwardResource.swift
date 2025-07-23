//
//  KubePortForwardResource.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import Foundation
import Combine

@Observable
class KubePortForwardResource : ObservableObject, Codable, Cloneable {
    var resourceName: String
    var resourceType: KubeResourceType
    var namespace: String
    var forwardedPorts: [PortMapping]
    var status: PortForwardStatus
    var errorDescription: String? = nil
    
    var isValid: Bool {
        return !self.resourceName.isEmpty && !self.namespace.isEmpty && !self.forwardedPorts.isEmpty && self.forwardedPorts.allSatisfy { mapping in
            mapping.localPort != nil && mapping.remotePort != nil
        }
    }
    
    enum CodingKeys: CodingKey {
        case resourceName, resourceType, namespace, forwardedPorts
    }
    
    func clone() -> KubePortForwardResource {
        return KubePortForwardResource(resourceName: self.resourceName, resourceType: self.resourceType, namespace: self.namespace, forwardedPorts: self.forwardedPorts.map { $0.clone() })
    }
    
    func applyChanges(from resource: KubePortForwardResource) -> Void {
        self.resourceName = resource.resourceName
        self.resourceType = resource.resourceType
        self.namespace = resource.namespace
        self.forwardedPorts = resource.forwardedPorts
        self.status = .idle
    }
    
    private var portForwardProcess: Process?
    
    init(resourceName: String, resourceType: KubeResourceType, namespace: String, forwardedPorts: [PortMapping]) {
        self.resourceName = resourceName
        self.resourceType = resourceType
        self.namespace = namespace
        self.forwardedPorts = forwardedPorts
        self.status = .idle
    }
    
    static func new() -> KubePortForwardResource {
        return KubePortForwardResource(resourceName: "", resourceType: .pod, namespace: "", forwardedPorts: [PortMapping.new()])
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
            let task = ShellHelper.createProcess()

            task.executableURL = ShellHelper.kubectlExecutable
            task.arguments = arguments
            
            task.terminationHandler = { process in
                DispatchQueue.main.async {
                    if process.terminationReason == .exit && process.terminationStatus == 0 {
                        self.status = .stopped
                    } else if process.terminationStatus == 15 { // SIGTERM is typically a status code of 15
                        self.status = .stopped
                    } else {
                        self.errorDescription = "Process Terminated with Error: \(KubectlExitReasonHelper.getExitReason(from: process.terminationStatus))"
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
                    self.status = .error
                    self.errorDescription = "Error running process. Try again"
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.resourceName, forKey: .resourceName)
        try container.encode(self.resourceType, forKey: .resourceType)
        try container.encode(self.namespace, forKey: .namespace)
        try container.encode(self.forwardedPorts, forKey: .forwardedPorts)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.resourceName = try container.decode(String.self, forKey: .resourceName)
        self.resourceType = try container.decode(KubeResourceType.self, forKey: .resourceType)
        self.namespace = try container.decode(String.self, forKey: .namespace)
        self.forwardedPorts = try container.decode([PortMapping].self, forKey: .forwardedPorts)
        self.status = .idle
    }
}

