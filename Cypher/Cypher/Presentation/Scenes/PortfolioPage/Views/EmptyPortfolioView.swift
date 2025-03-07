//
//  EmptyPortfolioView.swift
//  Cypher
//
//  Created by Nkhorbaladze on 16.01.25.
//

import SwiftUI

struct EmptyPortfolioView: View {
    var body: some View {
        ZStack {
            Color(AppColors.backgroundColor.rawValue)
                .ignoresSafeArea(edges: .all)
            
            VStack {
                
                Spacer()
                
                Image(Icons.emptyPortfolio.rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 340, height: 340)
                
                Text("There is nothing here!")
                    .font(Fonts.semiBold.size(30))
                    .foregroundStyle(Color(AppColors.white.rawValue))
                
                Text("You can start buying coins.")
                    .font(Fonts.regular.size(15))
                    .foregroundStyle(Color(AppColors.lightGrey.rawValue))
                
                Spacer()
            }
        }
    }
}
