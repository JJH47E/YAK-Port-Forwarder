//
//  PortMapping.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import Foundation

class PortMapping : ObservableObject, Identifiable, Codable {
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
    
    enum CodingKeys: CodingKey {
        case localPort, remotePort
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(self.localPort, forKey: .localPort)
        try container.encode(self.remotePort, forKey: .remotePort)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.localPort = try container.decode(Int?.self, forKey: .localPort)
        self.remotePort = try container.decode(Int?.self, forKey: .remotePort)
    }
}
