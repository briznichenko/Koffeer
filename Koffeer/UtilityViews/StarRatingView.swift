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
        HStack(spacing: 6) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .resizable()
                    .scaledToFit()
                    .frame(width: starSize, height: starSize)
                    .foregroundStyle(index <= rating ? filledColor : emptyColor)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        rating = index
                    }
                    .accessibilityLabel("Set rating to \(index)")
            }
        }
        .accessibilityElement(children: .contain)
    }
}

