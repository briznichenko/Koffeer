import UIKit

protocol TextRecognitionService {
    func recognizeText(from image: UIImage?) async -> String
}

