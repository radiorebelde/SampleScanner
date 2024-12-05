/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Provides the class for the text recognition and the structure to create the bounding boxes.
*/

import SwiftUI
import Vision

@Observable
class Barcode {
    /// The array of `RecognizedTextObservation` objects to hold the request's results.
    var observations = [BarcodeObservation]()

    /// The Vision request.
    var request = DetectBarcodesRequest()

    func performBarcodeDetection(imageData: Data) async throws {
        /// Clear the `observations` array for photo recapture.
        observations.removeAll()

        /// Perform the request on the image data and return the results.
        let results = try await request.perform(on: imageData)

        /// Add each observation to the `observations` array.
        for observation in results {
            observations.append(observation)
        }
    }
}

/// Create and dynamically size a bounding box.
struct Box: Shape {
    private let topLeft: NormalizedPoint
    private let topRight: NormalizedPoint
    private let bottomRight: NormalizedPoint
    private let bottomLeft: NormalizedPoint

    init(observation: any QuadrilateralProviding) {
        topLeft = observation.topLeft
        topRight = observation.topRight
        bottomRight = observation.bottomRight
        bottomLeft = observation.bottomLeft
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: topLeft.toImageCoordinates(rect.size,origin: .upperLeft))
        path.addLine(to: topRight.toImageCoordinates(rect.size,origin: .upperLeft))
        path.addLine(to: bottomRight.toImageCoordinates(rect.size,origin: .upperLeft))
        path.addLine(to: bottomLeft.toImageCoordinates(rect.size,origin: .upperLeft))
        path.closeSubpath()
        let x = topRight.toImageCoordinates(rect.size,origin: .upperLeft).x
        let y = topRight.toImageCoordinates(rect.size,origin: .upperLeft).y
        path.addArc(center: CGPoint(x: x, y: y), radius: 5, startAngle: .zero, endAngle: .degrees(360), clockwise: true)
        return path
    }
}

///// Create and dynamically size a bounding box.
//struct topLeftPoint: Shape {
//    private let topLeft: NormalizedPoint
//   
//
//    init(observation: any QuadrilateralProviding) {
//        topLeft = observation.topLeft
//       
//    }
//
//    func path(in rect: CGRect) -> Path {
//        //Draw a circle
//        var path = Path()
//        
//        return path
//    }
//}
