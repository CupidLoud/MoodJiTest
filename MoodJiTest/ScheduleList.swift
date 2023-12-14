//
//  ScheduleSet.swift
//  MoodJiTest
//
//  Created by ZZ on 2023/12/13.
//

import SwiftUI

struct ScheduleList: View {
    @EnvironmentObject var coloState : MainColorModel
    
    @State var curArr = []

    var body: some View {
            
        VStack(alignment: .center, spacing: 0) {
            Spacer().frame(height: 24)
            Text("Set your sleep schedule")
                .font(TextStyles.title3Bold)
                .foregroundColor(Color(UIColor.label))
            Text("Tell Moodji your schedule to know you better.\nDon't worry, an approximate time is enough")
                .padding(.top, 8)
                .font(TextStyles.body)
                .lineSpacing(3)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(UIColor.tertiaryLabel))
            
            Spacer().frame(height: 30)
            ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom), content: {
                HStack {
                    HStack(alignment: .center, spacing: SizeStylesPro().padding4, content: {
                        Spacer()
                        Image(systemName: "bed.double.fill")
                        Text("SLEEP")
                            .font(TextStyles.subHeadlineSemibold)
                        Spacer()
                    })
                    .foregroundColor(coloState.timeType == 0 ? ColorStylesDark().accentSleep : Color(UIColor.tertiaryLabel))
                    .onTapGesture {
                        coloState.timeType = 0
                        dataLoadDo()
                    }
                    
                    HStack {
                        Spacer()
                        Image(systemName: "building.2.fill")
                        Text("WORK")
                            .font(TextStyles.subHeadlineSemibold)
                        Spacer()
                    }
                    .foregroundColor(coloState.timeType == 1 ? ColorStylesDark().accentScreenTime : Color(UIColor.tertiaryLabel))
                    .onTapGesture {
                        coloState.timeType = 1
                        dataLoadDo()
                    }
                }
                .frame(height: 50)

                Image(uiImage: UIImage(named: "schedule_taped")!.withRenderingMode(.alwaysTemplate))
                    .offset(x: coloState.timeType == 0 ? -90 : 90, y: 0).animation(.easeIn)
                    .foregroundColor(coloState.timeType == 0 ? ColorStylesDark().accentSleep : ColorStylesDark().accentScreenTime)
            })

            Spacer().frame(height: SizeStylesPro().spacing16)
            
//            List {
//                ForEach(0..<curArr.count, id: \.self) { idx in
//                    SchedulListCell(dic: curArr[idx] as! [String : Any])
//                }
//                .onDelete(perform: { indexSet in
//                    curArr.remove(atOffsets: indexSet)
//                    __UserDefault.setValue(curArr, forKey: curTapIdx == 0 ? sleepTimeArr : workTimeArr)
//                    __UserDefault.synchronize()
//                })
//            }
            
            ScrollView(.vertical, showsIndicators: false, content: {
                VStack(alignment: .center, spacing: SizeStylesPro().spacing12, content: {
                    ForEach(0..<curArr.count, id: \.self) { idx in
                        SchedulListCell(coloState: coloState, dic: curArr[idx] as! [String : Any])
                    }
                    
                    HStack(alignment: .center, spacing: 4, content: {
                        Spacer()
                        Image(systemName: "plus")
                        Text("Add Schedule")
                        Spacer()
                    })
                    .font(TextStyles.subHeadlineSemibold)
                    .frame(height: 42)
                    .onTapGesture {
                        dataAddDo()
                    }
                })
                .padding(.top, SizeStylesPro().padding8)
                .foregroundColor(coloState.timeType == 0 ? ColorStylesDark().accentSleep : ColorStylesDark().accentScreenTime)
            })

        }
        .padding(.leading, SizeStylesPro().spacing16)
        .padding(.trailing, SizeStylesPro().spacing16)
        .padding(.top, SizeStylesPro().spacing16)
        .background(Color(UIColor.systemGroupedBackground))
        .preferredColorScheme(coloState.colorOption == 0 ? .none : (coloState.colorOption == 1 ? .light : .dark))
        .ignoresSafeArea()
        .onAppear(perform: {
            dataLoadDo()
        })
    }
    
    func dataAddDo() {
        let dic = ["days": [0, 1, 3], "start": "09:30", "end": "16:00"] as [String : Any]
        if let t = __UserDefault.value(forKey: coloState.timeType == 0 ? sleepTimeArr : workTimeArr) as? [Any] {
            print("color 设置 \(t)")
            curArr = t
        }
        curArr += [dic]
        __UserDefault.setValue(curArr, forKey: coloState.timeType == 0 ? sleepTimeArr : workTimeArr)
        __UserDefault.synchronize()
    }
    
    func dataLoadDo() {
        if let t = __UserDefault.value(forKey: coloState.timeType == 0 ? sleepTimeArr : workTimeArr) as? [Any] {
            print("color 设置 \(t.count)")
            curArr = t
        }
    }
    
}


struct SchedulListCell: View {
    @State var coloState : MainColorModel

    @State private var isPopoverVisible = false
    @State var dic : [String : Any]
    let weekStrs = [0: "Mon", 1: "Tue", 2: "Wed", 3: "Thu", 4: "Fri", 5: "Sta", 6: "Sun"]
    
    func weekStrGet(arr: [Int]) -> String {
        if arr == [5, 6] {
            return "Weekend"
        }
        if arr == [0, 1, 2, 3, 4] {
            return "Weekdays"
        }
        if arr.count == 1 {
            return weekStrs[arr.first!]!
        }
        if arr.count > 1 {
            var str = ""
            for idx in 0..<arr.count {
                if idx == arr.count-1 {
                    str += "\(weekStrs[arr[idx]]!)"
                }else if idx == arr.count-2 {
                    str += "\(weekStrs[arr[idx]]!) and "
                }else{
                    str += "\(weekStrs[arr[idx]]!), "
                }
            }
            return str
        }
        return "Unkown"
    }
    
    
    var body: some View {
        VStack(alignment:.leading, spacing: SizeStylesPro().padding8) {
            Text(weekStrGet(arr: dic["days"] as! [Int]))
                .font(TextStyles.subHeadlineSemibold)
            HStack {
                Text("\(dic["start"] as! String) - \(dic["end"] as! String) ")
                    .font(TextStyles.title3Bold)
                    .foregroundColor(Color(UIColor.label))
                Spacer()
                Button(action: {
                    isPopoverVisible.toggle()
                }, label: {
                    Text("Edit")
                        .font(TextStyles.subHeadlineSemibold)
                })
                .popover(isPresented: $isPopoverVisible) {
                    ScheduleSet(isPresented: $isPopoverVisible, mDic: $dic).environmentObject(self.coloState)
                }
            }
        }
        .padding(SizeStylesPro().spacing16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(SizeStylesPro().spacing16)
    }
}