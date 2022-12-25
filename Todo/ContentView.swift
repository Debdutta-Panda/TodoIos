//
//  ContentView.swift
//  Todo
//
//  Created by Debdutta Panda on 25/12/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject
    var vm = ViewModel()
    var body: some View {
        NavigationStack(path: $vm.paths) {
            EmptyView()
            .navigationDestination(for: Paths.self) { path in
                switch path {
                    case .Splash: SplashScreen()
                        .onAppear{
                            vm.onSplash()
                        }
                    case .Home: HomeView()
                }
            }
        }
        .onAppear{
            vm.gotoSplash()
        }
    }
}

struct ContentView1: View {
    @State private var paths: [Paths] = []
    var body: some View {
        NavigationStack(path: $paths) {
            EmptyView()
            .navigationDestination(for: Paths.self) { path in
                switch path {
                    case .Splash: SplashScreen()
                        .onAppear{
                            DispatchQueue.main.asyncAfter(deadline: .now()+2.0){
                                paths.append(.Home)
                            }
                        }
                    case .Home: HomeView()
                }
            }
        }
        .onAppear{
            paths.append(.Splash)
        }
    }
}


extension ContentView {
    @MainActor class ViewModel: ObservableObject {
        @Published var paths: [Paths] = []
        
        func onSplash(){
            DispatchQueue.main.asyncAfter(deadline: .now()+2.0){
                self.paths.append(.Home)
            }
        }
        func gotoSplash(){
            self.paths.append(.Splash)
        }
    }
}
