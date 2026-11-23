import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            dayTitle: "Hoy",
            dateSubtitle: "23 nov.",
            countText: "3 pendientes",
            task1: "Revisar pendientes",
            task2: "Comprar suministros",
            task3: "",
            task4: "",
            moreText: "",
            isEmpty: false
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = getEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let entry = getEntry()
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func getEntry() -> SimpleEntry {
        let userDefaults = UserDefaults(suiteName: "group.com.wigt.app")
        let dayTitle = userDefaults?.string(forKey: "day_title") ?? "Hoy"
        let dateSubtitle = userDefaults?.string(forKey: "date_subtitle") ?? ""
        let countText = userDefaults?.string(forKey: "tasks_count") ?? "0 pendientes"
        let task1 = userDefaults?.string(forKey: "task_1") ?? ""
        let task2 = userDefaults?.string(forKey: "task_2") ?? ""
        let task3 = userDefaults?.string(forKey: "task_3") ?? ""
        let task4 = userDefaults?.string(forKey: "task_4") ?? ""
        let moreText = userDefaults?.string(forKey: "more_count") ?? ""
        let isEmpty = userDefaults?.bool(forKey: "is_empty") ?? (task1.isEmpty && task2.isEmpty)

        return SimpleEntry(
            date: Date(),
            dayTitle: dayTitle,
            dateSubtitle: dateSubtitle,
            countText: countText,
            task1: task1,
            task2: task2,
            task3: task3,
            task4: task4,
            moreText: moreText,
            isEmpty: isEmpty
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let dayTitle: String
    let dateSubtitle: String
    let countText: String
    let task1: String
    let task2: String
    let task3: String
    let task4: String
    let moreText: String
    let isEmpty: Bool
}

struct WigtWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(entry.dayTitle)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(red: 0.65, green: 0.55, blue: 0.98))
                    if !entry.dateSubtitle.isEmpty {
                        Text(entry.dateSubtitle)
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 0.62, green: 0.62, blue: 0.69))
                    }
                }
                Spacer()
                Text(entry.countText)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(red: 0.85, green: 0.71, blue: 0.99))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(red: 0.12, green: 0.11, blue: 0.22))
                    .cornerRadius(8)
            }

            Divider().background(Color(red: 0.15, green: 0.15, blue: 0.22))

            if entry.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Text("✓ Todo listo por hoy")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.62, green: 0.62, blue: 0.69))
                    Spacer()
                }
                Spacer()
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    if !entry.task1.isEmpty {
                        TaskItemRow(text: entry.task1)
                    }
                    if !entry.task2.isEmpty {
                        TaskItemRow(text: entry.task2)
                    }
                    if !entry.task3.isEmpty {
                        TaskItemRow(text: entry.task3)
                    }
                    if !entry.task4.isEmpty {
                        TaskItemRow(text: entry.task4)
                    }
                    if !entry.moreText.isEmpty {
                        Text(entry.moreText)
                            .font(.system(size: 10))
                            .foregroundColor(Color(red: 0.65, green: 0.55, blue: 0.98))
                    }
                }
            }
        }
        .padding(12)
        .background(Color(red: 0.04, green: 0.04, blue: 0.06))
    }
}

struct TaskItemRow: View {
    let text: String
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color(red: 0.55, green: 0.36, blue: 0.96))
                .frame(width: 5, height: 5)
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.white)
                .lineLimit(1)
        }
    }
}

@main
struct WigtWidget: Widget {
    let kind: String = "WigtWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WigtWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Wigt - Pendientes")
        .description("Consulta tus pendientes del día directamente en la pantalla de inicio.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
