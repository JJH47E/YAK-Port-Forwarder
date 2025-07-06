//
//  EditPortForward.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 06/07/2025.
//

import SwiftUI

struct EditPortForward: View {
    @Binding var portForwardResource: KubePortForwardResource
    
    var body: some View {
        NavigationStack {
            NavigationView {
                PortForwardForm(portForwardResource: $portForwardResource)
            }.navigationTitle(portForwardResource.resourceName)
        }
    }
}

#Preview {
    @Previewable @State var resource = KubePortForwardResource(resourceName: "nginx-1234", resourceType: .pod, namespace: "default", forwardedPorts: [])
    EditPortForward(portForwardResource: $resource)
}
