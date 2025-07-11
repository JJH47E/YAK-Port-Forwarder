//
//  PreviewKubeDataProvider.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import Foundation

class PreviewKubeDataProvider : KubeViewModel {
    override init() {
        super.init()
        self.portForwards = [
            KubePortForwardResource(resourceName: "nginx-bf5d5cf98-hqz66", resourceType: .pod, namespace: "default", forwardedPorts: [
                PortMapping(localPort: 7701, remotePort: 80)]),
            KubePortForwardResource(resourceName: "another", resourceType: .service, namespace: "test-1", forwardedPorts: [
                PortMapping(localPort: 7702, remotePort: 80)]),
            KubePortForwardResource(resourceName: "third", resourceType: .service, namespace: "test-1", forwardedPorts: [
                PortMapping(localPort: 7703, remotePort: 80)])
        ]
        
        self.context = "Unknown"
        self.loaded = true
    }
    
    override func addPortForward(_ portForward: KubePortForwardResource) -> Void {
        portForwards.append(portForward)
    }
    
    override func load() {
        self.context = "test"
    }
}
