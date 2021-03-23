//
//  myWidget.swift
//  myWidget
//
//  Created by Stepan Ostapenko on 20.03.2021.
//

import WidgetKit
import SwiftUI
import Intents
import CoreDataFramework

struct Provider: IntentTimelineProvider {
    private let container = CoreDataStack.shared.managedObjectContext
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(item: nil, date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(item: nil, date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        let request = ToDoListItem.getFetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(ToDoListItem.createdAt), ascending: true)
        request.sortDescriptors = [sort]
        let tasks = try? container.fetch(request)
        print("Nuumber of tasks: \(tasks?.count)")
        let notCompletedTasks = tasks?.filter{ $0.status != ToDoListItem.St.done}
        let currentDate = Date()
        
        if let correctTasks = notCompletedTasks {
            if correctTasks.count == 0 {
                entries.append(SimpleEntry(item: nil, date: Date(), configuration: configuration))
                let timeline = Timeline(entries: entries, policy: .never)
                completion(timeline)
                print("none")
                return
            }
            
            for task in correctTasks {
                _ = Calendar.current.date(byAdding: .hour, value: 20, to: currentDate)!
                let entry = SimpleEntry(item: task, date:task.createdAt!, configuration: configuration)
                entries.append(entry)
                print("true")
            }
            
        } else {
            entries.append(SimpleEntry(item: nil, date: Date(), configuration: configuration))
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    var item: ToDoListItem?
    let date: Date
    let configuration: ConfigurationIntent
}

struct myWidgetEntryView : View {
    var entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let item = entry.item {
                HStack {
                    Text(item.name!)
                        .font(.title)
                        //.foregroundColor(Color("Color1"))
                    Spacer()
                    Text(Date(), style: .date)
                        .fontWeight(.light)
                        .font(.caption)
                        //.foregroundColor(Color("Color1"))
                }
                
                Text("\(item.createdAt!)")
                    .font(.body)
                    //.foregroundColor(Color("Color1"))
                
                HStack(spacing: 10) {
                    Rectangle()
                        .fill(Color("Color1"))
                        .frame(width: 20, height: 20)
                        .cornerRadius(10)
                    Text(item.getStatusInfo())
                        //.foregroundColor(Color("Color1"))
                }
                
                Spacer()
            } else {
                Text("Нет ближайших активных задач")
                    .font(.title)
                    //.foregroundColor(Color("Color1"))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 15)
    }
}
@main
struct myWidget: Widget {
    let kind: String = "myWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            myWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct myWidget_Previews: PreviewProvider {
    static var previews: some View {
        myWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
