//
//  DocumentPicker.swift
//  DataMapper
//
//  Created by János Kukoda on 2023. 02. 07..
//

import Foundation
import SwiftUI
import UIKit
import UniformTypeIdentifiers
import SwiftUI
import UIKit

struct DocumentPickerViewController: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var documentData: Data?
    @Binding var filename: String?

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.text, UTType.xml, UTType.json], asCopy: false)
        documentPicker.delegate = context.coordinator
        return documentPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(isPresented: $isPresented, documentData: $documentData, filename: $filename)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        @Binding var isPresented: Bool
        @Binding var documentData: Data?
        @Binding var filename: String?

        init(isPresented: Binding<Bool>, documentData: Binding<Data?>, filename: Binding<String?>) {
            _isPresented = isPresented
            _documentData = documentData
            _filename = filename
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            do {
                guard let url = urls.first else {
                    return
                }
                
                CFURLStartAccessingSecurityScopedResource(url as CFURL)
                let data = try Data(contentsOf: url)
                CFURLStopAccessingSecurityScopedResource(url as CFURL)
                
                documentData = data
                filename = String(url.lastPathComponent.split(separator: ".")[0])
                isPresented = false
            } catch {
                /*sendLog(dictionary: [
                    "text": error.localizedDescription,
                ])*/
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            isPresented = false
        }
    }
}
