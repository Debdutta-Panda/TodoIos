//
//  Db.swift
//  Todo
//
//  Created by Debdutta Panda on 26/12/22.
//

import Foundation
import SQLite

class Db{
    static let DIR_TASK_DB = "TaskDB"
    static let STORE_NAME = "task.sqlite3"
    
    private var db: Connection?
    private var tasks: Table = Table("tasks")
    private var id = Expression<Int64>("id")
    private var title = Expression<String>("name")
    private var hashId = Expression<String>("hashId")
    private var date = Expression<Date?>("date")
    private var created = Expression<Date?>("createdOn")
    private var done = Expression<Bool>("done")
    
    init(){
        do {
            try haveConnection()
            try migration()
            try createTable()
        }
        catch{
            db = nil
        }
    }
    
    private func migration(){
        //migration_0_to_1()
    }
    
    private func migration_0_to_1(){
        if db?.userVersion == 0{
            db?.userVersion = 1
        }
    }
    
    private func haveConnection() throws{
        if let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dirPath = docDir.appendingPathComponent(Self.DIR_TASK_DB)
            do {
                try FileManager.default.createDirectory(atPath: dirPath.path, withIntermediateDirectories: true, attributes: nil)
                let dbPath = dirPath.appendingPathComponent(Self.STORE_NAME).path
                db = try Connection(dbPath)
            }
        }
    }
    
    private func createTable() throws{
        try db?.run(tasks.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(hashId)
            t.column(title)
            t.column(created)
            t.column(date)
            t.column(done)
        })
    }
    
    func removeAll(){
        do{
            try db?.run(tasks.delete())
        }
        catch{
            
        }        
    }
    
    func create(task: Task)-> Bool{
        do{
            let count = try db?.run(
                tasks
                    .insert(
                        title <- task.title,
                        date <- task.date,
                        done <- task.done,
                        hashId <- UUID().uuidString,
                        created <- Date()
                    )
            )
            return true
        }
        catch {
            return false
        }
    }
    
    func getAll() -> [Task] {
        if db == nil{
            return []
        }
        do {
            let all = Array(
                try db!
                    .prepare(
                        tasks
                            .select(
                                id,
                                hashId,
                                title,
                                created,
                                date,
                                done
                            )
                            .order(date.desc, created.desc, title.asc)
                    )
            )
            let tasks: [Task?] = all.map { Row in
                var task: Task? = nil
                do {
                    task = try taskFromRow(row: Row)
                }
                catch let error{
                    print(error)
                }
                return task
            }
            var goodTasks: [Task] = []
            tasks.forEach { task in
                if task != nil {
                    goodTasks.append(task!)
                }
            }
            return goodTasks
        }
        catch{
            return []
        }
    }
    func update(task: Task)-> Bool{
        do{
            let dbTask = tasks.filter(id == task.id)
            try db?
            .run(
                dbTask.update(
                    title <- task.title,
                    date <- task.date,
                    done <- task.done
                )
            )
            return true
        }
        catch let error{
            return false
        }
    }
    func delete(task: Task)->Bool{
        do{
            let dbTask = tasks.filter(id == task.id)
            try db?
            .run(
                dbTask.delete()
            )
            return true
        }
        catch let error{
            return false
        }
    }
    private func taskFromRow(row: Row) throws-> Task{
        let id = try row.get(id)
        let title = try row.get(title)
        let date = try row.get(date)
        let done = try row.get(done)
        let hashId = try row.get(hashId)
        let created = try row.get(created)
        return Task(
            id: id,
            hashId: hashId,
            title: title,
            created: created,
            date: date,
            done: done
        )
    }
}
