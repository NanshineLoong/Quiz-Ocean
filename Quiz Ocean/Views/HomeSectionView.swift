//
//  MainView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/29.
//

import SwiftUI

struct HomeSectionView: View {
    private var categories: [String] = ["Number Sense", "Mathematics", "Calculator", "Science"]
    var body: some View {
        NavigationView {
            List {
                Image("ocean")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .cornerRadius(20)
                        .clipped()
                        
                Section(header: Text("Categories")) {
                    ForEach(categories, id: \.self) { category in
                        NavigationLink(
                            destination: TestFromCategoryView(category: category)
                                .navigationBarTitle(Text(category), displayMode: .large)
                        ) {
                            Text(category)
                        }
                    }
                        
                }
            }
            .navigationTitle(Text("Quiz Ocean"))
//            .listStyle(GroupedListStyle())
//            .environment(\.horizontalSizeClass, .regular)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        HomeSectionView()
    }
}
