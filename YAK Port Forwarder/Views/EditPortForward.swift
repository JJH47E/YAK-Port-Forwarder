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
    
    var body: some View {
        NavigationStack {
            NavigationView {
                PortForwardForm(portForwardResource: portForwardResource)
            }.navigationTitle(portForwardResource.resourceName.isEmpty ? "Edit Port Forward" : portForwardResource.resourceName)
                .padding()
                    .toolbar {
                        ToolbarItem( placement: .confirmationAction ) {
                            Button( "Confirm" ) {
                                dismiss()
                            }
                        }
                        ToolbarItem( placement: .cancellationAction ) {
                            Button( "Cancel" ) {
                                dismiss()
                            }
                        }
                    }.navigationSplitViewStyle(.prominentDetail)
        }
    }
}

#Preview {
    @Previewable @State var resource = KubePortForwardResource(resourceName: "nginx-1234", resourceType: .pod, namespace: "default", forwardedPorts: [])
    EditPortForward(portForwardResource: $resource)
}
