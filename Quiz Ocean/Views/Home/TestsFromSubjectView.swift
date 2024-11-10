//
//  TestFromCategoryView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/31.
//

import SwiftUI

struct TestsFromSubjectView: View {
    let subject: String
    @EnvironmentObject var testStore: TestStore
    @Binding var path: [String]
    
    let columns = [
        GridItem(.flexible()),
//        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
//            HStack {
//                Button(action: {
//                    path.removeLast()
//                }) {
//                    Image(systemName: "xmark")
//                        .padding()
//                }
//                
//                Spacer()
//                
//                Text("\(subject)")
//                    .font(.headline)
//                
//                Spacer()
//            }
//            .padding(.horizontal)
            
            // Filter buttons
            HStack {
                FilterButton(label: "year")
                FilterButton(label: "complexity")
                FilterButton(label: "finish")
            }
            .padding(.horizontal)
            
            ScrollView {
                TestsGridView(tests: testStore.filterTestsFromSubject(from: subject), columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], path: $path)
            }
        }
        .navigationTitle("\(subject)")
    }
}


struct TestsGridView: View {
    var tests: [TestViewModel]
    var columns: [GridItem]
    @EnvironmentObject var testStore: TestStore
    @Binding var path: [String]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(tests) { test in
                withAnimation(.spring()) {
                    TestBoard(test: test, path: $path)
                }
            }
        }
    }
}
    
struct FilterButton: View {
    var label: String
    var body: some View {
        Button(action: {
            // Filter action
        }) {
            Text(label)
                .font(.subheadline)
                .padding(8)
                .background(Color.black.opacity(0.1))
                .cornerRadius(15)
        }
    }
}

//struct TestsFromSubjectView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestsFromSubjectView(subject: Subject(firstName: "Number", lastName: "Sense", img: "numbersense"))
//            .environmentObject(TestStore.sample)
//    }
//}
