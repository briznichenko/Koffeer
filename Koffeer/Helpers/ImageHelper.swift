import UIKit

func avatarUIImage(from data: Data?) -> UIImage {
    if let data, let image = UIImage(data: data) {
        return image
    }
    let dynamicColor = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? .white : .black
    }
    return UIImage(color: dynamicColor) ?? UIImage()
}

