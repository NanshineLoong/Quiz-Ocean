//
//  TestFromCategoryView.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/31.
//

import SwiftUI

struct TestsFromSubjectView: View {
    let subject: Subject
    @EnvironmentObject var testStore: TestStore
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                ForEach(testStore.filterTestsFromSubject(from: subject), id: \.self) { test in
                    withAnimation(.spring()) {
                        TestBoard(test: test, userTest: testStore.bindingForUserTest(from: test))
                    }
                }
            }
        }
    }
}
    

struct TestFromCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        TestsFromSubjectView(subject: Subject(firstName: "Number", lastName: "Sense", img: "numbersense"))
            .environmentObject(TestStore.sample)
    }
}
