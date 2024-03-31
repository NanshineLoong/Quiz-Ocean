//
//  TestRow.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/3/31.
//

import SwiftUI

struct TestRow: View {
    let test: Test
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .foregroundColor(.black)
                .opacity(0.6)
            
            testInfo
        }
        .cornerRadius(8)
        .padding([.leading, .trailing], 16)
        .padding([.top, .bottom], 8)
        .shadow(color: .black, radius: 5, x: 0, y: 0)
    }
    
    private var testInfo: some View {
        VStack {
            Text(verbatim: test.level)
                .foregroundColor(.white)
                .font(.subheadline)
                .padding([.leading, .trailing])
            
            Text(test.category)
                .foregroundColor(.white)
                .font(.headline)
                .padding([.leading, .bottom, .trailing])
            
            Text(test.year)
                .foregroundColor(.white)
                .font(.subheadline)
                .padding([.leading, .trailing])
        }
    }
}

struct TestRow_Previews: PreviewProvider {
    static var previews: some View {
        TestRow(test: Test(category: "Number Sense", level: "Middle School", year: "2024"))
    }
}
