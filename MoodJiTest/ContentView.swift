//
//  ContentView.swift
//  MoodJiTest
//
//  Created by ZZ on 2023/12/12.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var curMode

    var body: some View {
        TabView {
            NavigationView {
                Text("Main")
            }
            .navigationTitle("Main")
                .tabItem {
                    Image(uiImage: UIImage(named: "tab1")!.withRenderingMode(.alwaysTemplate))
                }
            
            Text("第二页")
                .tabItem {
                    Image(uiImage: UIImage(named: "tab2")!.withRenderingMode(.alwaysTemplate))
                }
            
            Setting()
                .tabItem {
                    Image(uiImage: UIImage(named: "tab3")!.withRenderingMode(.alwaysTemplate))
                }
        }
        .accentColor(curMode == .dark ? ColorStylesDark().tabitemSelected : ColorStylesLight().tabitemSelected)
        .onAppear(perform: {
            __UserDefault.setValue(1, forKey: firstOpen)
        })
        
    }
}

