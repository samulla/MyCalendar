//
//  CalendarWeekView.swift
//  SamiCalendar
//
//  Created by Hunasimarad, Samiulla on 06/12/21.
//

import SwiftUI

struct CalendarWeekView: View {
    
    private let calendar: Calendar
    private let monthlyDayFormatter: DateFormatter
    private let dayFormatter: DateFormatter
    private let weekDayFormatter: DateFormatter
    
    private static  var now = Date()
    
    @State var selectedDate: Date // = Self.now
    @State var showYearView : Bool = false
    
    init(calendar: Calendar, selectedDate: Date){

        self.calendar = calendar
        _selectedDate = State(initialValue:selectedDate)
        self.monthlyDayFormatter = DateFormatter(dateFormat: "EEEE MMMM d, yyyy", calendar: calendar)
        self.dayFormatter = DateFormatter(dateFormat: "d", calendar: calendar)
        self.weekDayFormatter = DateFormatter(dateFormat: "EEEEE", calendar: calendar)

    }
    
    var body: some View {
        
        if showYearView {
            withAnimation(.spring()){
                CalendarMonthView(calendar: Calendar(identifier: .gregorian), selectedDate: $selectedDate)
            }
            
        } else {
            
            WeeklyCalendarView(calendar: calendar, date: $selectedDate, showYearView: $showYearView){ date in
                
                Button {
                    selectedDate = date
                } label: {
                    Text("00")
                        .font(.system(size: 11))
                        .padding(.horizontal, 25)
                        .padding(.vertical, 10)
                        .foregroundColor(.clear)
                        .accessibilityHidden(true)
                        .overlay(
                            Text(dayFormatter.string(from: date))
                                .font(.system(size: 16))
                                .frame(width: 36, height: 36, alignment: .center)
                                .foregroundColor(
                                    calendar.isDate(date, inSameDayAs: selectedDate) ? .white :
                                        calendar.isDateInToday(date) ? .white
                                    : .gray
                                )
                                .background(calendar.isDate(date, inSameDayAs: selectedDate) ? Color.blue : calendar.isDateInToday(date) ? Color.red : Color.clear
                                           )
                                .clipShape(Circle())
                        )
                    
                }

            } header: { date in
                
                Text(weekDayFormatter.string(from: date))
                    .font(.system(size: 16))
                    .frame(width: 36, height: 36, alignment: .center)
                    .padding(10)

            } title: { date in
                
                HStack{
                    Text(monthlyDayFormatter.string(from: selectedDate))
                        .font(.subheadline)
                        .padding()
                }
                .padding(.bottom, 6)
            } switcher: { date in
                
                Button{
                    withAnimation {
                        guard let newDate = calendar.date(
                            byAdding: .weekOfMonth, value: -1, to: selectedDate
                        ) else {
                            return
                        }
                        selectedDate = newDate
                    }
                }label:{
                    Label(
                        title: {Text("Previous")},
                        icon: {Image(systemName: "chevron.left")}
                    )
                        .labelStyle(IconOnlyLabelStyle())
                        .padding()
                    
                }
                
                Button{
                    withAnimation {
                        guard let newDate = calendar.date(
                            byAdding: .weekOfMonth, value: 1, to: selectedDate
                        ) else {
                            return
                        }
                        selectedDate = newDate
                    }
                }label:{
                    Label(
                        title: {Text("Next")},
                        icon: {Image(systemName: "chevron.right")}
                    )
                        .labelStyle(IconOnlyLabelStyle())
                        .padding()

                    
                }

            }
            .padding()
        }
       
        
    }
}

public struct WeeklyCalendarView<Day: View, Header: View, Title: View, Switcher: View>: View{
    
    
    private var calendar: Calendar
    @Binding private var date: Date
    @Binding private var showYearView: Bool

    private let content: (Date) -> Day
    private let header: (Date) -> Header
    private let title:(Date) -> Title
    private let switcher:(Date) -> Switcher
    
    private let daysinWeek = 7
    private let monthFormatter: DateFormatter

    public init(
        calendar: Calendar,
        date: Binding<Date>,
        showYearView: Binding<Bool>,
        @ViewBuilder content: @escaping (Date) -> Day,
        @ViewBuilder header: @escaping (Date) -> Header,
        @ViewBuilder title: @escaping (Date) -> Title,
        @ViewBuilder switcher: @escaping (Date) -> Switcher
    ){
        self.calendar = calendar
        self._date = date
        self._showYearView = showYearView
        self.content = content
        self.header = header
        self.title = title
        self.switcher = switcher
        self.monthFormatter = DateFormatter(dateFormat: "MMMM", calendar: calendar)

        
    }
    
    public var body: some View{
        let month = date.startOfMonth(using: calendar)
        let days = makeDays()
        
        VStack{
            HStack(spacing:0){
                Button{
                    withAnimation {
                        self.showYearView = true
                    }
                }label:{
                    Label(
                        title: {
                            Text(monthFormatter.string(from: date))
                                .font(.subheadline)
                                .padding()

                        },
                        icon: {Image(systemName: "chevron.left")}
                    )
                        .padding()

                }
                
//                NavigationLink(destination: CalendarYearView(calendar: Calendar(identifier: .gregorian))
//                ) {
//                    Label(
//                        title: {Text("December")},
//                        icon: {Image(systemName: "chevron.left")}
//                    )
//                        .padding()
//
//                }

                
                Spacer()
                switcher(month)
            }
            
            VStack(spacing: 0){
                HStack(spacing:0){
                    ForEach(days.prefix(daysinWeek), id: \.self, content: header)
                }
                HStack(spacing: 0){
                    ForEach(days, id:\.self){ date in
                        content(date)
                    }
                }
                
                HStack(alignment: .center, spacing: 0){
                    Spacer()
                    title(month)
                    Spacer()

                }
                
                

            }
            .background(Color.gray.opacity(0.2))
            
            ScrollView{
                VStack(spacing: 20){
                 
                    ForEach(0..<24) { index in
                        HStack(spacing:0){
                            Text("\(index):00")
                                .font(.caption2)
                                .padding()
                                .foregroundColor(.gray)
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray)
                                .frame(height: 0.5)
                                .padding(.trailing, 10)
                        }
                      
                        
                    }
                }
                .foregroundColor(.white)
                .font(.largeTitle)
            }
           
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

private extension WeeklyCalendarView{
    func makeDays()->[Date]{
        guard let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: date),
              let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: firstWeek.end - 1)
        else{
            return []
        }
        
        let dateinterval = DateInterval(start: firstWeek.start, end: lastWeek.end)
        
        return calendar.generateDays(for: dateinterval)
    }
}
private extension Calendar{
    func generateDates(
        for dateInterval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates = [dateInterval.start]
        
        enumerateDates(startingAfter: dateInterval.start,
                       matching: components,
                       matchingPolicy: .nextTime
        ){ date, _, stop in
            guard let date = date else {return}
            
            guard  date < dateInterval.end else{
                stop = true
                return
            }
            dates.append(date)
            
        }
        
        return dates
        
    }
    
    func generateDays(for dateInterval: DateInterval) -> [Date]{
        
        generateDates(for: dateInterval, matching: dateComponents([.hour,.minute,.second], from: dateInterval.start))
    }
}

private extension Date{
    func startOfMonth(using calendar: Calendar) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: self)) ?? self
        
    }
    
}
private extension DateFormatter{
    
    convenience init(dateFormat: String, calendar: Calendar){
        self.init()
        self.dateFormat = dateFormat
        self.calendar = calendar
        self.locale = Locale(identifier: "en-US")
    }
}

struct CalendarWeekView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarWeekView(calendar: Calendar(identifier: .gregorian), selectedDate: Date())
    }
}
