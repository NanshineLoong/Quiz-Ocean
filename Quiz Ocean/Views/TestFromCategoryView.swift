//
//  TestFromCategoryView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/31.
//

import SwiftUI

struct TestFromCategoryView: View {
    let category: String
    @State var tests: [Test] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                ForEach(tests, id: \.self) { test in
                    withAnimation(.spring()) {
                        TestRow(test: test)
                    }
                }
            }
        }
        .onAppear {
            getMockTests(from: category)
        }
    }
    
    private func getMockTests(from category: String) {
        let years = ["2024", "2023", "2022", "2021", "2020", "2019"]
        let level = "Middle School"
        
        let mockTests = years.map { year in
            Test(category: category, level: level, year: year)
        }
        
        self.tests = mockTests
    }
}

struct TestFromCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        TestFromCategoryView(category: "Number Sense")
    }
}
