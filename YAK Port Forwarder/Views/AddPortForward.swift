//
//  AddPortForward.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 06/07/2025.
//

import SwiftUI

struct AddPortForward: View {
    @State private var portForwardResource = KubePortForwardResource.new()
    
    var body: some View {
        NavigationStack {
            NavigationView {
                PortForwardForm(portForwardResource: $portForwardResource)
            }.navigationTitle(portForwardResource.resourceName.isEmpty ? "Add Port Forward" : portForwardResource.resourceName)
        }
    }
}

#Preview {
    AddPortForward()
}
