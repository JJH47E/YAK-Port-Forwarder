//
//  Settings.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 16/07/2025.
//

import SwiftUI

struct Settings: View {
    @Environment(\.dismiss) private var dismiss
    @State var newKubectlBinUrl: String = ""
    var viewModel: KubeViewModel
    
    var body: some View {
        VStack {
            Form {
                TextField("Kubectl Executable URL", text: $newKubectlBinUrl)
            }
        }
        .padding()
        .toolbar {
            ToolbarItem( placement: .confirmationAction) {
                Button("Update") {
                    let url = URL(string: newKubectlBinUrl)!
                    viewModel.updateBinUrl(url)
                    dismiss()
                }.disabled(!UrlHelper.isValidUrl(newKubectlBinUrl))
            }
            ToolbarItem( placement: .cancellationAction ) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .onAppear {
            let currentUrl = viewModel.getBinUrl()
            
            if let stringUrl = currentUrl?.absoluteString {
                newKubectlBinUrl = stringUrl
            }
        }
    }
}

#Preview {
    Settings(viewModel: PreviewKubeDataProvider())
}
