//
//  HomeView.swift
//  Todo
//
//  Created by Debdutta Panda on 25/12/22.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        HomeContent()
        .navigationBarBackButtonHidden(true)
    }
}

struct HomeContent: View {
    @StateObject private var vm = ViewModel()
    var body: some View {
        VStack{
            TabView(selection: $vm.selectedTab){
                Text("Home")
                    .tabItem{
                        Label("Home",systemImage: "house")
                    }
                    .tag(0)
                AddTask(vm: vm)
                    .tabItem{
                        Label("Add",systemImage: "plus.square.fill")
                    }
                    .tag(1)
                    .onAppear{
                        vm.clearForm()
                    }
                AllTasks(vm: vm)
                    .tabItem{
                        Label("All Tasks",systemImage: "checklist")
                    }
                    .tag(2)
            }
            .background(Color.red)
        }
    }
}

struct AllTasks: View {
    @State var editingTask: Task? = nil
    @StateObject var vm: HomeContent.ViewModel
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Text("All tasks")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding()
                if vm.tasks.isEmpty{
                    Spacer()
                    HStack{
                        Text("No task yet.")
                        Spacer()
                            .frame(width: 10)
                        Button("Create one"){
                            vm.selectedTab = 1
                        }
                    }
                    Spacer()
                }
                else{
                    List(vm.tasks){ task in
                        TaskUI(
                            task: task,
                            onDelete: {
                                vm.onDelete(task: task)
                            },
                            onEdit: {
                                editingTask = task
                            }
                        ){p in
                            var newTask = task
                            newTask.done = p
                            vm.onChange(task: newTask)
                        }
                    }
                }
            }
            .padding(.bottom)
            .blur(radius: editingTask == nil ? 0 : 5)
            .disabled(editingTask != nil)
            if(editingTask != nil){
                EditTaskUI(
                    task: editingTask!,
                    onDiscard: {
                        editingTask = nil
                    }
                ){ editedTask in
                    vm.onChange(task: editedTask)
                    editingTask = nil
                }
            }
        }
    }
}

struct EditTaskUI: View {
    var task: Task
    var onDiscard: ()->Void
    var onDone: (Task)->Void
    @State var isDate = true
    @State var date = Date()
    @State var title = ""
    var body: some View {
        VStack {
            HStack {
                if(isDate){
                    DatePicker(
                        "Date",
                        selection: $date,
                        displayedComponents: .date
                    )
                    Button(action: {
                        isDate = false
                    }){
                        Image(systemName: "trash")
                    }
                    .padding(20)
                }
                else{
                    Button("Set Date"){
                        isDate = true
                    }
                }
            }
            .padding()
            .frame(height: 50)
            TextField(
              "Enter your todo item",
              text: $title
            )
            .font(.largeTitle)
                .padding()
            Button(action: {
                var editedTask = task
                editedTask.title = title
                editedTask.date = isDate ? date : nil
                onDone(editedTask)
                title = ""
                date = Date()
                isDate = true
            }){
                Text("Done")
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .foregroundColor(Color.white)
            .background(title.isEmpty ? Color.gray : Color.blue)
            .cornerRadius(10)
            .padding()
            .disabled(title.isEmpty)
            
            Button(action: {
                onDiscard()
            }){
                Text("Discard")
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
            }
            .foregroundColor(Color.red)
        }
        .padding(20)
        .onAppear{
            title = task.title
            date = task.date ?? Date()
            isDate = task.date != nil
        }
    }
}

struct TaskUI: View{
    
    var task: Task
    var onDelete: ()->Void
    var onEdit: ()->Void
    var onChange: (Bool)->Void
    var body: some View {
        VStack{
            HStack{
                Text(task.date.toFormattedString())
                                .foregroundColor(Color.gray)
                                .font(.footnote)
                                .frame(width: 70)
                Spacer()
            }
            
            HStack{
                Text(task.title)
                    .font(.largeTitle)
                    .strikethrough(task.done)
                Spacer()
                Toggle(
                    task.title,
                    isOn: Binding<Bool>(
                        get: {
                            return task.done
                        },
                        set: {p in
                            onChange(p)
                        }
                    )
                )
                .labelsHidden()
            }
        }
        .contextMenu {
                Button {
                    onEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }

                Button {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
    }
}

extension Date?{
    func toFormattedString()-> String{
        if self == nil {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY"
        return dateFormatter.string(from: self!)
    }
}

extension HomeContent {
    @MainActor class ViewModel: ObservableObject {
        private var db = Db()
        @Published var selectedTab = 0
        @Published var canNotProceed = true
        @Published var date = Date()
        @Published var isDate = true
        @Published var buttonColor = Color.gray
        @Published var title = ""{
            didSet{
                canNotProceed = title.isEmpty
                buttonColor = canNotProceed ? Color.gray : Color.blue
            }
        }
        @Published var tasks: [Task] = []
        
        init(){
            tasks = db.getAll()
        }
        
        func onDiscard(){
            selectedTab = 0
        }
        
        func onDone(){
            selectedTab = 0
            db.create(task: Task(title: title, date: isDate ? date : nil))
            clearForm()
            tasks.removeAll()
            tasks.append(contentsOf: db.getAll())
        }
        
        func clearForm(){
            title = ""
            date = Date()
            isDate = true
            canNotProceed = true
        }
        
        func onChange(task: Task){
            if db.update(task: task){
                let index: Int = tasks.firstIndex{item in
                    item.id == task.id
                } ?? -1
                if index > -1 {
                    tasks[index] = task
                }
            }
        }
        
        func onDelete(task: Task){
            if db.delete(task: task){
                let index: Int = tasks.firstIndex{item in
                    item.id == task.id
                } ?? -1
                if index > -1 {
                    tasks.remove(at: index)
                }
            }
        }
    }
}

struct AddTask: View {
    @StateObject var vm: HomeContent.ViewModel
    
    var body: some View {
        VStack {
            HStack {
                if(vm.isDate){
                    DatePicker(
                        "Date",
                        selection: $vm.date,
                        displayedComponents: .date
                    )
                    Button(action: {
                        vm.isDate = false
                    }){
                        Image(systemName: "trash")
                    }
                    .padding(20)
                }
                else{
                    Button("Set Date"){
                        vm.isDate = true
                    }
                }
            }
            .padding()
            .frame(height: 50)
            TextField(
              "Enter your todo item",
              text: $vm.title
            )
            .font(.largeTitle)
                .padding()
            Button(action: {
                vm.onDone()
            }){
                Text("Done")
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .foregroundColor(Color.white)
            .background(vm.buttonColor)
            .cornerRadius(10)
            .padding()
            .disabled(vm.canNotProceed)
            
            Button(action: {
                vm.onDiscard()
            }){
                Text("Discard")
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
            }
            .foregroundColor(Color.red)
        }
        
        .padding(20)
    }
}
