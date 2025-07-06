//
//  KubeResourceType.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import Foundation

enum KubeResourceType : CustomStringConvertible, Identifiable {
    var id: Self {
        return self
    }
    
    case deployment
    case pod
    case service
    
    static let all : [KubeResourceType] = [.deployment, .pod, .service]
    
    var description : String {
        switch self {
        case .deployment: return "Deployment"
        case .pod: return "Pod"
        case .service: return "Service"
        }
    }
    
    var resourceName : String {
        switch self {
        case .deployment: return "deployment"
        case .pod: return ""
        case .service: return "service"
        }
    }
}
