//
//  EditPortForward.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import Foundation
import SwiftUI

struct PortForwardForm: View {
    @Binding var portForwardResource: KubePortForwardResource
    
    var body: some View {
        Form {
            TextField("Resource Name", text: $portForwardResource.resourceName)
            
            Picker("Resource Type", selection: $portForwardResource.resourceType) {
                ForEach(KubeResourceType.all) { option in
                    Text(option.description)
                }
            }
        }
    }
}

#Preview() {
    @Previewable @State var resource = KubePortForwardResource(resourceName: "nginx-1234", resourceType: .pod, namespace: "default", forwardedPorts: [])
    PortForwardForm(portForwardResource: $resource)
}
