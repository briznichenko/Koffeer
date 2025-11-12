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
        guard let image, let cgImage = image.cgImage else {
            completion("")
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else {
                completion("")
                return
            }

            let recognizedStrings = request.results?
                .compactMap { $0 as? VNRecognizedTextObservation }
                .compactMap { $0.topCandidates(1).first?.string } ?? []

            completion(recognizedStrings.joined(separator: "\n"))
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en", "uk"]

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
