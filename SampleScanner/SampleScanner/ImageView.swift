/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Displays the captured image with bounding boxes, settings, and navigation buttons.
*/

import SwiftUI

struct ImageView: View {
    @Binding var showCamera: Bool
    @Binding var imageData: Data?
    
    @State private var ocrDetection = OCR()
    @State private var barcodeDetection = Barcode()
    

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Spacer()
                    NavigationLink(destination: InitialView()) {
                        Text("Retake Photo")
                            .padding()
                            .font(.headline)
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                            .onTapGesture {
                                showCamera = true
                            }
                    }
                }

                /// Convert the image data to a `UIImage`, and display it in an `Image` view.
                if let uiImage = UIImage(data: imageData!) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .overlay {
                            ForEach(barcodeDetection.observations, id: \.uuid) { observation in
                                Box(observation: observation)
                                    .stroke(.red, lineWidth: 1)
                            }
                            ForEach(ocrDetection.observations, id: \.uuid) { observation in
                                Box(observation: observation)
                                    .stroke(.blue, style: StrokeStyle(lineWidth: 1))
                            }
                        }
                        .padding()
                }
            }
            /// Initially perform the request, and then perform the request when changes occur to the request settings.
            .onChange(of: showCamera, initial: true) {
                updateOCRRequestSettings()
                updateBarcodeRequestSettings()
                Task {
                    try await barcodeDetection.performBarcodeDetection(imageData: imageData!)
                    try await ocrDetection.performOCR(imageData: imageData!)
                }
            }
        }
    }

    /// Update the request settings based on the selected options on the `ImageView`.
    func updateOCRRequestSettings() {
        ocrDetection.request.usesLanguageCorrection = true

        ocrDetection.request.recognitionLevel = .accurate
        
    }
    
    func updateBarcodeRequestSettings() {
        barcodeDetection.request.symbologies = [.ean13,.dataMatrix,.qr]
    }
}
