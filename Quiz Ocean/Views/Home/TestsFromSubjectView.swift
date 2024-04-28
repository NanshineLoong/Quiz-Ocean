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
    
    let columns = [
        GridItem(.flexible()),
//        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            TestsGridView(tests: testStore.filterTestsFromSubject(from: subject), columns: columns)
        }
        .navigationBarTitle(subject.fullName, displayMode: .inline)
    }
}
    

struct TestsFromSubjectView_Previews: PreviewProvider {
    static var previews: some View {
        TestsFromSubjectView(subject: Subject(firstName: "Number", lastName: "Sense", img: "numbersense"))
            .environmentObject(TestStore.sample)
    }
}
