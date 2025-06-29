//
//  KubeDataProvider.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import Foundation

protocol KubeDataProvider : ObservableObject {
    var portForwards: [KubePortForwardResource] { get set }
    var cluster: String { get set }
}
