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
        NavigationStack {
            NavigationView {
                VStack {
                    PortForwardForm(portForwardResource: $portForwardResource)
                }
            }.navigationTitle(portForwardResource.resourceName.isEmpty ? "Add Port Forward" : portForwardResource.resourceName)
                .padding()
                    .toolbar {
                        ToolbarItem( placement: .confirmationAction ) {
                            Button( "Create" ) {
                                viewModel.addPortForward(portForwardResource)
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
    AddPortForward(viewModel: PreviewKubeDataProvider())
}
