//
//  StarRatingView.swift
//  Koffeer
//
//  Created by Andrii Bryzhnychenko on 10/24/25.
//

import SwiftUI

struct StarRatingView: View {
    @Binding var rating: Int  // current rating (0...maxRating)
    var maxRating: Int = 5
    var starSize: CGFloat = 30
    var filledColor: Color = .yellow
    var emptyColor: Color = .gray

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .resizable()
                    .frame(width: starSize, height: starSize)
                    .foregroundColor(index <= rating ? filledColor : emptyColor)
                    .onTapGesture {
                        rating = index
                    }
            }
        }
    }
}
