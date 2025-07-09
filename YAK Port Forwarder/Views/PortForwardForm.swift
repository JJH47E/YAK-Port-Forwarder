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
    
    @State private var type: KubeResourceType = .pod
    
    var body: some View {
        Form {
            TextField("Resource Name", text: $portForwardResource.resourceName)
            
            Picker("Resource Type", selection: $type) {
                ForEach(KubeResourceType.all) { option in
                    Text(option.description).tag(option)
                }
            }
            
            TextField("Namespace", text: $portForwardResource.namespace)
        }.onAppear {
            self.type = self.portForwardResource.resourceType
        }.onChange(of: type) { oldType, newType in
            self.portForwardResource.resourceType = newType
        }
    }
}

#Preview() {
    @Previewable @State var resource = KubePortForwardResource(resourceName: "nginx-1234", resourceType: .pod, namespace: "default", forwardedPorts: [])
    PortForwardForm(portForwardResource: $resource)
}
