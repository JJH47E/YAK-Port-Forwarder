//
//  PortMapping.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import Foundation

class PortMapping : ObservableObject, Identifiable {
    @Published var localPort: Int?
    @Published var remotePort: Int?
    
    init(localPort: Int, remotePort: Int) {
        self.localPort = localPort
        self.remotePort = remotePort
    }
    
    init() {}
    
    static func new() -> PortMapping {
        return PortMapping()
    }
}
