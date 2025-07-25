//
//  EditPortForward.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import Foundation
import SwiftUI

struct PortForwardForm: View {
    @ObservedObject var portForwardResource: KubePortForwardResource
    
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
            
            Section("Ports") {
                ScrollView {
                    portMappingForm
                }.frame(width: 300.0, height: 80.0)
                Button {
                    portForwardResource.addNewPortMapping()
                } label: {
                    Label("Add New", systemImage: "plus")
                }
            }
        }.scrollContentBackground(.hidden)
        .onAppear {
            self.type = self.portForwardResource.resourceType
        }.onChange(of: type) { oldType, newType in
            self.portForwardResource.resourceType = newType
        }
    }
    
    @ViewBuilder var portMappingForm: some View {
        VStack {
            ForEach($portForwardResource.forwardedPorts) { mapping in
                HStack {
                    Button {
                        let idx = portForwardResource.forwardedPorts.firstIndex {
                            $0.id == mapping.id
                        }
                        
                        if (idx == nil) {
                            return
                        }
                        
                        portForwardResource.forwardedPorts.remove(at: idx!)
                    } label: {
                        Label("Delete", systemImage: "minus.circle")
                            .labelStyle(.iconOnly)
                    }.buttonStyle(.borderless)
                    TextField(value: mapping.localPort, formatter: NumberFormatter(), prompt: Text("Local")) {}
                    TextField(value: mapping.remotePort, formatter: NumberFormatter(), prompt: Text("Remote")) {}
                }
            }
        }
    }
}

#Preview() {
    @Previewable @State var resource = KubePortForwardResource(resourceName: "nginx-1234", resourceType: .pod, namespace: "default", forwardedPorts: [])
    PortForwardForm(portForwardResource: resource)
}
