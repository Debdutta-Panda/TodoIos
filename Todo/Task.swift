//
//  Task.swift
//  Todo
//
//  Created by Debdutta Panda on 26/12/22.
//

import Foundation

struct Task: Identifiable{
    var id: Int64 = 0
    var hashId: String = ""
    var title: String
    var created: Date? = Date()
    var date: Date? = nil
    var done: Bool = false
}
