//
//  UpdateNamespace.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 13/07/2025.
//

import SwiftUI

struct UpdateNamespace: View {
    @Environment(\.dismiss) private var dismiss
    @State private var namespace = ""
    var viewModel: KubeViewModel
    
    var body: some View {
        VStack {
            Form {
                TextField("Namespace", text: $namespace)
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Confirm") {
                    viewModel.updateNamespace(namespace)
                    dismiss()
                }.disabled(namespace.isEmpty)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    UpdateNamespace(viewModel: PreviewKubeDataProvider())
}
