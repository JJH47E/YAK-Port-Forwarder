//
//  EditPortForward.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import Foundation
import SwiftUI

struct EditPortForward: View {
    @Binding var portForwardResource: KubePortForwardResource
    
    var body: some View {
        NavigationStack {
            NavigationView {
                
            }.navigationTitle("New Port Forward")
        }
    }
}

#Preview() {
    @Previewable @State var resource = KubePortForwardResource(resourceName: "nginx-1234", resourceType: .pod, namespace: "default", forwardedPorts: [])
    EditPortForward(portForwardResource: $resource)
}
