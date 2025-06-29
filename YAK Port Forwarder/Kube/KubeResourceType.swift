//
//  KubeResourceType.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import Foundation

enum KubeResourceType : CustomStringConvertible {
    case deployment
    case pod
    case service
    
    var description : String {
        switch self {
        case .deployment: return "Deployment"
        case .pod: return "Pod"
        case .service: return "Service"
        }
    }
}
