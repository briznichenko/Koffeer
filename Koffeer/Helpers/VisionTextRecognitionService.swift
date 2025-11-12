import UIKit
@preconcurrency import Vision

final class VisionTextRecognitionService: TextRecognitionService {
    func recognizeText(from image: UIImage?) async -> String {
        guard let image, let cgImage = image.cgImage else { return "" }

        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                guard error == nil else {
                    continuation.resume(returning: "")
                    return
                }

                let recognizedStrings = request.results?
                    .compactMap { $0 as? VNRecognizedTextObservation }
                    .compactMap { $0.topCandidates(1).first?.string } ?? []

                continuation.resume(returning: recognizedStrings.joined(separator: "\n"))
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["en", "uk"]

            DispatchQueue.global(qos: .userInitiated).async {
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(returning: "")
                }
            }
        }
    }
}

