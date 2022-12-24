//
//  ContentView.swift
//  Todo
//
//  Created by Debdutta Panda on 24/12/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        LottieView(name: "lottie", loopMode: .loop)
                    .frame(width: 250, height: 250)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
