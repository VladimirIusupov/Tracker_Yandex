import Foundation

enum L10n {
    enum General {
        static let cancel = NSLocalizedString("general.cancel", comment: "")
        static let create = NSLocalizedString("general.create", comment: "")
        static let update = NSLocalizedString("general.update", comment: "")
        static let done = NSLocalizedString("general.done", comment: "")
        static let pin = NSLocalizedString("general.pin", comment: "")
        static let unpin = NSLocalizedString("general.unpin", comment: "")
        static let save = NSLocalizedString("general.save", comment: "")
        static let delete = NSLocalizedString("general.delete", comment: "")
    }

    enum Onboarding {
        static let blueTitle = NSLocalizedString("onboarding.blueTitle", comment: "")
        static let redTitle = NSLocalizedString("onboarding.redTitle", comment: "")
        static let button = NSLocalizedString("onboarding.button", comment: "")
    }

    enum Trackers {
        static let title = NSLocalizedString("trackers.title", comment: "")
        static let emptyState = NSLocalizedString("trackers.emptyState", comment: "")
        static let emptySearch = NSLocalizedString("trackers.emptySearch", comment: "")
        static let search = NSLocalizedString("trackers.search", comment: "")
        static let filters = NSLocalizedString("trackers.filters", comment: "")
        static let pinned = NSLocalizedString("trackers.pinned", comment: "")
    }

    enum Statistics {
        static let title = NSLocalizedString("statistics.title", comment: "")
        static let emptyState = NSLocalizedString("statistics.emptyState", comment: "")
        static let bestPeriod = NSLocalizedString("statistics.bestPeriod", comment: "")
        static let idealDays = NSLocalizedString("statistics.idealDays", comment: "")
        static let trackersCompleted = NSLocalizedString("statistics.trackersCompleted", comment: "")
        static let average = NSLocalizedString("statistics.avg", comment: "")
    }

    enum Tabbar {
        static let trackers = NSLocalizedString("tabbar.trackers", comment: "")
        static let statistics = NSLocalizedString("tabbar.statistics", comment: "")
    }

    enum TypeChoice {
        static let title = NSLocalizedString("typeChoice.title", comment: "")
        static let habit = NSLocalizedString("typeChoice.habit", comment: "")
        static let irregular = NSLocalizedString("typeChoice.irregular", comment: "")
    }

    enum Creation {
        static let habitTitle = NSLocalizedString("creation.habitTitle", comment: "")
        static let irregularTitle = NSLocalizedString("creation.irregularTitle", comment: "")
        static let category = NSLocalizedString("creation.category", comment: "")
        static let schedule = NSLocalizedString("creation.schedule", comment: "")
        static let placeholder = NSLocalizedString("creation.placeholder", comment: "")
        static let emoji = NSLocalizedString("creation.emoji", comment: "")
        static let color = NSLocalizedString("creation.color", comment: "")
        static let everyDay = NSLocalizedString("creation.everyDay", comment: "")
        static let error = NSLocalizedString("creation.error", comment: "")
    }

    enum Categories {
        static let title = NSLocalizedString("categories.title", comment: "")
        static let create = NSLocalizedString("categories.create", comment: "")
        static let placeholder = NSLocalizedString("categories.placeholder", comment: "")
        static let new = NSLocalizedString("categories.new", comment: "")
        static let emptyState = NSLocalizedString("categories.emptyState", comment: "")
    }

    enum WeekdayFull {
        static let monday = NSLocalizedString("weekdayFull.monday", comment: "")
        static let tuesday = NSLocalizedString("weekdayFull.tuesday", comment: "")
        static let wednesday = NSLocalizedString("weekdayFull.wednesday", comment: "")
        static let thursday = NSLocalizedString("weekdayFull.thursday", comment: "")
        static let friday = NSLocalizedString("weekdayFull.friday", comment: "")
        static let saturday = NSLocalizedString("weekdayFull.saturday", comment: "")
        static let sunday = NSLocalizedString("weekdayFull.sunday", comment: "")
    }

    enum WeekdayShort {
        static let monday = NSLocalizedString("weekdayShort.monday", comment: "")
        static let tuesday = NSLocalizedString("weekdayShort.tuesday", comment: "")
        static let wednesday = NSLocalizedString("weekdayShort.wednesday", comment: "")
        static let thursday = NSLocalizedString("weekdayShort.thursday", comment: "")
        static let friday = NSLocalizedString("weekdayShort.friday", comment: "")
        static let saturday = NSLocalizedString("weekdayShort.saturday", comment: "")
        static let sunday = NSLocalizedString("weekdayShort.sunday", comment: "")
    }

    enum TrackerActions {
        static let warning = NSLocalizedString("trackerActions.warning", comment: "")
        static let updatingTitle = NSLocalizedString("trackerActions.updatingTitle", comment: "")
    }

    enum Filters {
        static let all = NSLocalizedString("filters.all", comment: "")
        static let today = NSLocalizedString("filters.today", comment: "")
        static let completed = NSLocalizedString("filters.completed", comment: "")
        static let uncompleted = NSLocalizedString("filters.uncompleted", comment: "")
    }
}

