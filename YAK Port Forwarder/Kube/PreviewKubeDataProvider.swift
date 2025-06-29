//
//  PreviewKubeDataProvider.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import Foundation

class PreviewKubeDataProvider : KubeDataProvider {
    @Published var portForwards: [KubePortForwardResource] = [
        KubePortForwardResource(resourceName: "test", resourceType: .service, namespace: "test-1", forwardedPorts: [
            PortMapping(localPort: 7701, remotePort: 80)]),
        KubePortForwardResource(resourceName: "another", resourceType: .service, namespace: "test-1", forwardedPorts: [
            PortMapping(localPort: 7702, remotePort: 80)]),
        KubePortForwardResource(resourceName: "third", resourceType: .service, namespace: "test-1", forwardedPorts: [
            PortMapping(localPort: 7703, remotePort: 80)])
    ]
    
    @Published var cluster: String = "Staging"
}
