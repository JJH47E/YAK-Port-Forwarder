//
//  AddPortForward.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 06/07/2025.
//

import SwiftUI

struct AddPortForward: View {
    @Environment(\.dismiss) private var dismiss
    @State var portForwardResource = KubePortForwardResource.new()
    var viewModel: KubeViewModel

    var body: some View {
        VStack {
            PortForwardForm(portForwardResource: portForwardResource, availableContexts: viewModel.availableContexts)
        }
        .padding()
        .onAppear {
            portForwardResource.context = viewModel.context
        }
        .toolbar {
            ToolbarItem( placement: .confirmationAction ) {
                Button("Create") {
                    viewModel.addPortForward(portForwardResource)
                    dismiss()
                }.disabled(!portForwardResource.isValid)
            }
            ToolbarItem( placement: .cancellationAction ) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    AddPortForward(viewModel: PreviewKubeDataProvider())
}
