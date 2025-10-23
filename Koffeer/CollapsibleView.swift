//
//  CollapsableView.swift
//  Koffeer
//
//  Created by Andrii Bryzhnychenko on 10/23/25.
//

import SwiftUI

struct CollapsibleView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    @State var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .imageScale(.small)
                        .rotationEffect(.degrees(isExpanded ? 0 : 0))
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [.gray.opacity(0.25), .black.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            
            // Collapsible content
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    content
                }
                .padding()
                .background(Color.black.opacity(0.6))
                .cornerRadius(12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal)
    }
}
