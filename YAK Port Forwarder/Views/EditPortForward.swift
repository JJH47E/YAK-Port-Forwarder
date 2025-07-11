//
//  EditPortForward.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 06/07/2025.
//

import SwiftUI

// TODO: Dismiss should discard your changes

struct EditPortForward: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var portForwardResource: KubePortForwardResource
    
    @State private var editableResource: KubePortForwardResource?
    
    var body: some View {
        NavigationStack {
            NavigationView {
                Group {
                    if editableResource == nil {
                        ProgressView()
                    } else {
                        PortForwardForm(portForwardResource: editableResource!)
                            .navigationTitle("Edit Port Forward")
                            .padding()
                    }
                }.navigationSplitViewStyle(.prominentDetail)
            }.toolbar {
                ToolbarItem( placement: .confirmationAction ) {
                    Button( "Confirm" ) {
                        portForwardResource.applyChanges(from: editableResource!)
                        dismiss()
                    }
                }
                ToolbarItem( placement: .cancellationAction ) {
                    Button( "Cancel" ) {
                        dismiss()
                    }
                }
            }
                .onAppear {
                    editableResource = portForwardResource.clone()
                }
        }
    }
}

#Preview {
    @Previewable @State var resource = KubePortForwardResource(resourceName: "nginx-1234", resourceType: .pod, namespace: "default", forwardedPorts: [])
    EditPortForward(portForwardResource: $resource)
}
