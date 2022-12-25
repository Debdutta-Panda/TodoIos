//
//  SplashScreen.swift
//  Todo
//
//  Created by Debdutta Panda on 25/12/22.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        VStack{
            Spacer()
            LottieView(name: "lottie", loopMode: .loop)
                .frame(width: 250, height: 250)
            Spacer()
            Text("Todo")
                .font(.system(size: 32))
                .padding([.bottom],20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
}



