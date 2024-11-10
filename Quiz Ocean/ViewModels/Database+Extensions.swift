//
//  Database+Extensions.swift
//  Quiz Ocean
//
//  Created by Nanshine on 2024/10/31.
//

import FirebaseDatabase

extension Database {
    class var root: DatabaseReference {
        return database(url: "https://quizocean-b16fc-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
    }
}
