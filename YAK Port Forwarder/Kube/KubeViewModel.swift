//
//  KubeViewModel.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import Foundation

class KubeViewModel: ObservableObject {
    @Published var portForwards: [KubePortForwardResource] = []
    @Published var cluster: String = "test"
    
    func addPortForward(_ portForward: KubePortForwardResource) {
        portForwards.append(portForward)
    }
}
