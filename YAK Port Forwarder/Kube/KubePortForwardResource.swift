//
//  KubePortForwardResource.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import Foundation

class KubePortForwardResource : ObservableObject {
    @Published var resourceName: String
    @Published var resourceType: KubeResourceType
    @Published var namespace: String
    @Published var forwardedPorts: [PortMapping]
    @Published var status: PortForwardStatus
    
    init(resourceName: String, resourceType: KubeResourceType, namespace: String, forwardedPorts: [PortMapping]) {
        self.resourceName = resourceName
        self.resourceType = resourceType
        self.namespace = namespace
        self.forwardedPorts = forwardedPorts
        self.status = .idle
    }
    
    func startStop() {
        if (self.status == .running) {
            stop()
        } else if (self.status == .stopped || self.status == .idle) {
            start()
        }
    }
    
    func start() {
        self.status = .running
    }
    
    func stop() {
        self.status = .stopped
    }
}
