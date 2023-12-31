//
//  ScheduleSet.swift
//  MoodJiTest
//
//  Created by ZZ on 2023/12/13.
//

import SwiftUI

struct ScheduleSet: View {
    @EnvironmentObject var coloState : MainColorModel
    @Binding var isPresented: Bool
    @State private var showingAlert = false
    
    @State var arrIdx: Int
    @State var mDic = ScheduleBean()
    let weekStrs = ["M", "T", "W", "T", "F", "S", "S"]
    
    @State private var timeStart = Date()
    @State private var timeEnd = Date()
    
    @State private var canStart = false
    @State private var canEnd = false
    
    
    func isDaySelected(idx: Int) -> Bool {
        let days = mDic.days
        if let t = days {
            return t.contains(idx)
        }
        return false
    }
    
    func dayTapDo(idx: Int) {
        var days = mDic.days
        if let t = days {
            if t.contains(idx) {
                let selectedIdx = t.firstIndex(of: idx)!
                print("ed \(selectedIdx)")
                days!.remove(at: selectedIdx)
            }else{
                days! += [idx]
            }
            mDic.days = days
        }else{
            mDic.days = [idx]
        }
    }
    
    func dataLoadDo() {
        if let t = __UserDefault.value(forKey: coloState.timeType == 0 ? sleepTimeArr : workTimeArr) as? [Any] {
            print("color 设置 \(t.count)")
            if arrIdx == t.count {//add
                
            }else{
                do{
                    mDic = try JSONDecoder().decode(ScheduleBean.self, from: t[arrIdx] as! Data)
                 }catch{
                 }
            }
        }
        
        timeStart = mDic.start ?? Date()
        timeEnd = mDic.end ?? Date()
    }
    
    func okDo() -> Bool {
        var days = mDic.days
        if let t = days {
            if t.count == 0 {
                print("请至少选择一天")
                return false
            }
        }else{
            print("请至少选择一天")
            return false
        }
        
        var curArr = [Data]()
        let encoder = JSONEncoder()
        do{
            let data = try encoder.encode(mDic)
            if let t = __UserDefault.value(forKey: coloState.timeType == 0 ? sleepTimeArr : workTimeArr) as? [Data] {
                print("color 设置 \(t)")
                curArr = t
                if arrIdx == t.count {//add
                    curArr += [data]
                }else{
                    curArr[arrIdx] = data
                }
            }else{
                curArr += [data]
            }
            __UserDefault.setValue(curArr, forKey: coloState.timeType == 0 ? sleepTimeArr : workTimeArr)
            __UserDefault.synchronize()
            
        } catch {
            print("转换失败: \(error.localizedDescription)")
        }
        
        listBlock?()
        return true
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Text("Cancel").font(TextStyles.body)
                    .onTapGesture {
                        isPresented.toggle()
                    }
                Spacer()
                Text("Schedule").font(TextStyles.bodySemibold).foregroundColor(Color(UIColor.label))
                Spacer()
                Text("Done").onTapGesture {
                    if okDo() {
                        isPresented.toggle()
                    }else{
                        showingAlert.toggle()
                    }
                }
                .alert(isPresented: $showingAlert) { // 3
                    Alert( // 4
                        title: Text("Warn"), // 标题
                        message: Text("请至少选择一天"), // 消息内容
                        dismissButton: .cancel() // 取消按钮
                    )
                }
            }
            .frame(height: 50)
            
            HStack {
                Spacer()
                VStack {
                    Image(coloState.timeType == 0 ? "schedule_sleep" : "schedule_work")
                    Text(coloState.timeType == 0 ? "SLEEP" : "WORK").font(TextStyles.headline).foregroundColor(Color(UIColor.label))
                        .padding(.top, SizeStylesPro().spacingXs.byScaleWidth())
                    
                }
                Spacer()
            }
            .padding(.top, SizeStylesPro().spacingS.byScaleWidth())
            
            Text("CHOOSE DAYS").font(TextStyles.subHeadline).foregroundColor(Color(UIColor.secondaryLabel))
                .padding(.top, 24)
                .padding(.bottom, SizeStylesPro().spacingS.byScaleWidth())
                .padding(.leading, SizeStylesPro().spacingXs.byScaleWidth())
            
            HStack(alignment: .center, spacing: 0) {
                ForEach(0..<weekStrs.count, id: \.self) { idx in
                    Text(weekStrs[idx]).font(TextStyles.headline).foregroundColor(Color(UIColor.label))
                        .frame(width: 36, height: 36, alignment: .center)
                        .background(isDaySelected(idx: idx) ? (coloState.timeType == 0 ? ColorStylesDark().accentSleep : ColorStylesDark().accentScreenTime) : Color.clear)
                        .clipShape(Circle())
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(UIColor.systemFill), lineWidth: 1))
                        .onTapGesture {
                            print(idx)
                            dayTapDo(idx: idx)
                        }
                    if idx != weekStrs.count-1 {
                        Spacer()
                    }
                }
            }
            .padding(SizeStylesPro().spacingM.byScaleWidth())
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(SizeStylesPro().spacingM.byScaleWidth())
            
            Text("TIME").font(TextStyles.subHeadline).foregroundColor(Color(UIColor.secondaryLabel))
                .padding(.top, 24)
                .padding(.bottom, SizeStylesPro().spacingS.byScaleWidth())
                .padding(.leading, SizeStylesPro().spacingXs.byScaleWidth())
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Start").font(TextStyles.body).foregroundColor(Color(UIColor.label))
                    Spacer()
                    Text(__dateSir.string(from: timeStart)).font(TextStyles.headline)
                        .foregroundColor(canStart ? ColorStylesDark().accentRunning : Color(UIColor.label))
                        .frame(width: 72, height: 36, alignment: .center)
                        .background(Color(UIColor.tertiarySystemFill))
                        .cornerRadius(12)
                        .onTapGesture {
                            canStart.toggle()
                            canEnd = false
                        }
                }
                .padding(SizeStylesPro().spacingS.byScaleWidth())
                .padding(.leading, SizeStylesPro().paddingXxs.byScaleWidth()).padding(.trailing, SizeStylesPro().paddingXxs.byScaleWidth())
                
                if canStart {
                    Rectangle().foregroundColor(Color(UIColor.systemFill)).frame(height: 1)
                    DatePicker("", selection: $timeStart, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                }
                
                Rectangle().foregroundColor(Color(UIColor.systemFill)).frame(height: 1)
                
                HStack {
                    Text("End").font(TextStyles.body).foregroundColor(Color(UIColor.label))
                    Spacer()
                    Text(__dateSir.string(from: timeEnd)).font(TextStyles.headline)
                        .foregroundColor(canEnd ? ColorStylesDark().accentRunning : Color(UIColor.label))
                        .frame(width: 72, height: 36, alignment: .center)
                        .background(Color(UIColor.tertiarySystemFill))
                        .cornerRadius(12)
                        .onTapGesture {
                            canEnd.toggle()
                            canStart = false
                        }
                }
                .padding(SizeStylesPro().spacingS.byScaleWidth())
                .padding(.leading, SizeStylesPro().paddingXxs.byScaleWidth()).padding(.trailing, SizeStylesPro().paddingXxs.byScaleWidth())
                
                if canEnd {
                    Rectangle().foregroundColor(Color(UIColor.systemFill)).frame(height: 1)
                    DatePicker("", selection: $timeEnd, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                }
            }
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(SizeStylesPro().spacingM.byScaleWidth())
            .animation(.easeIn)
            
            Spacer()
        }
        .padding(SizeStylesPro().spacingM.byScaleWidth())
        .background(Color(UIColor.systemGroupedBackground))
        .preferredColorScheme(coloState.colorOption == 0 ? .none : (coloState.colorOption == 1 ? .light : .dark))
        .foregroundColor(coloState.timeType == 0 ? ColorStylesDark().accentSleep : ColorStylesDark().accentScreenTime)
        .environmentObject(coloState)
//        .environment(\.locale, .init(identifier: "da"))
        .onAppear(perform: {
            dataLoadDo()
        })
        .onChange(of: timeStart, perform: { value in
            mDic.start = value
        })
        .onChange(of: timeEnd, perform: { value in
            mDic.end = value
        })
    }
    
}
