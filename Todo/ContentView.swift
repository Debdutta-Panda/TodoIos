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
