//
//  TextRecognition.swift
//  Koffeer
//
//  Created by Andrii Bryzhnychenko on 10/25/25.
//

import SwiftUI
import Vision
import UIKit

struct TextRecognition {
    static func recognizeText(from image: UIImage?, completion: @escaping (String) -> Void) {
        // Convert to CGImage
        guard let image, let cgImage = image.cgImage else {
            completion("")
            return
        }

        // Create a text recognition request
        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else {
                completion("")
                return
            }

            // Extract recognized text
            let recognizedStrings = request.results?
                .compactMap { $0 as? VNRecognizedTextObservation }
                .compactMap { $0.topCandidates(1).first?.string } ?? []

            completion(recognizedStrings.joined(separator: "\n"))
        }

        // Configure request
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en", "uk"] // Add any you need

        // Perform request in background
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                completion("")
            }
        }
    }
}
