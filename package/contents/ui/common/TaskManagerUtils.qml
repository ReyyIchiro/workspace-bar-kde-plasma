pragma Singleton
import QtQuick
import org.kde.taskmanager as TaskManager
import "../common" as Common

QtObject {
    id: root

    property TaskManager.TasksModel tasksModel: TaskManager.TasksModel {
        id: tasksModel
        filterByVirtualDesktop: true
        filterByActivity: true
        filterByScreen: false
        screenGeometry: Qt.rect(0, 0, 0, 0)
    }

    property var activeWindowCache: ({})

    // WinIdList may be a QStringList ("{uuid1, uuid2}") or an already-joined string.
    // Return every contained window id instead of just the first match.
    function extractWinIds(rawWinId) {
        if (rawWinId === undefined || rawWinId === null) {
            return [];
        }

        const ids = [];
        if (Array.isArray(rawWinId)) {
            for (let i = 0; i < rawWinId.length; i++) {
                ids.push(String(rawWinId[i]));
            }
        } else {
            const str = String(rawWinId).replace(/[{}]/g, "");
            const parts = str.split(",");
            for (let j = 0; j < parts.length; j++) {
                const id = parts[j].trim();
                if (id.length > 0) {
                    ids.push(id);
                }
            }
        }

        return ids;
    }

    // True when the task row contains any of the requested window ids
    function rowMatchesWinIds(rawWinId, winIds) {
        const rowIds = extractWinIds(rawWinId);
        if (rowIds.length === 0) {
            return false;
        }
        for (let k = 0; k < winIds.length; k++) {
            if (rowIds.indexOf(String(winIds[k])) !== -1) {
                return true;
            }
        }
        return false;
    }

    signal screenFilteringChanged()

    function setScreenFiltering(enabled, geometry) {
        tasksModel.filterByScreen = enabled;
        if (enabled && geometry) {
            tasksModel.screenGeometry = geometry;
        }
        screenFilteringChanged();
    }

    function getActiveWindowName(desktopUuid, activityId) {
        if (!desktopUuid) return "";

        tasksModel.virtualDesktop = desktopUuid;
        tasksModel.activity = activityId || "";

        for (let i = 0; i < tasksModel.count; i++) {
            const taskIndex = tasksModel.index(i, 0);
            const isActive = tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.IsActive);

            if (isActive) {
                const displayName = tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.DisplayRole) || "";
                activeWindowCache[desktopUuid] = displayName;
                return displayName;
            }
        }

        activeWindowCache[desktopUuid] = "";
        return "";
    }

    function hasWindows(desktopUuid, activityId) {
        if (!desktopUuid) return false;

        tasksModel.virtualDesktop = desktopUuid;
        tasksModel.activity = activityId || "";

        return tasksModel.count > 0;
    }

    function getWindowsForDesktop(desktopUuid, activityId) {
        const windows = [];
        if (!desktopUuid) return windows;

        tasksModel.virtualDesktop = desktopUuid;
        tasksModel.activity = activityId || "";

        for (let i = 0; i < tasksModel.count; i++) {
            const taskIndex = tasksModel.index(i, 0);
            const appId = tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.AppId) || "application-x-executable";
            const appName = tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.AppName) || "Unknown Application";
            const isActive = tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.IsActive) || false;
            const genericName = tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.GenericName) || "";
            const isDemandingAttention = tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.IsDemandingAttention) || false;
            const rawWinId = tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.WinIdList) || []
            const rawActivities = tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.Activities || []);
            // const skipTaskBar = taskModel.data(taskIndex, TaskManager.AbstractTasksModel.SkipTaskBar) || false;
            // TODO: TaskManager.AbstractTaskModel.SkipTaskBar is returning window title for some reason.  Remove
            // when viable
            const desktopList = tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.VirtualDesktops);
            const skipPager = tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.SkipPager) || false;
            const skipTaskBar = false;


            if (skipPager || skipTaskBar) {
                continue;
            }

            // This is here to filter out windows with isDemandingAttention set.  I don't want them on every list
            if (!String(desktopList).includes(desktopUuid)) { continue; }

            // WinIdList holds every window of this task row (same app, several windows).
            // Extract *all* ids, otherwise grouping by app would always yield a count of 1.
            const winIds = extractWinIds(rawWinId);

            // Activities come as a QStringList too; keep the first one as before
            const str = String(rawActivities);
            const matches = str.match(/{([^}]+)}/);
            const taskActivities = matches && matches[1] ? matches[1] : str;

            for (let w = 0; w < winIds.length; w++) {
                windows.push({
                    appId: appId,
                    appName: appName,
                    // a row can hold several windows but only one active one; flag it on the first entry
                    isActive: isActive && w === 0,
                    genericName: genericName,
                    isDemandingAttention: isDemandingAttention,
                    winId: winIds[w],
                    activityId: taskActivities,
                    skipTaskBar: skipTaskBar,
                    skipPager: skipPager,
                });
            }
        }

        return windows;
    }

    function desktopNeedsAttention(desktopUuid, activityId) {
        if (!desktopUuid) return false;

        tasksModel.virtualDesktop = desktopUuid;
        tasksModel.activity = activityId || "";

        for (let i = 0; i < tasksModel.count; i++) {
            const taskIndex = tasksModel.index(i, 0);
            const isDemandingAttention = tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.IsDemandingAttention);
            let rawActivities = tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.Activities || []);

            // const str = String(rawActivities);
            // const matches = str.match(/{([^}]+)}/);
            // const taskActivities = matches && matches[1] ? matches[1] : str;
            //
            // if (activityId !== taskActivities) { continue; }

            const desktopList = tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.VirtualDesktops);
            if ((desktopList && String(desktopList).includes(desktopUuid)) && isDemandingAttention) {
                return true;
            }
        }

        return false;
    }

    function activateWindow(winId, desktopId, activityId) {
        if (!winId || !desktopId || !activityId) return false;

        tasksModel.virtualDesktop = desktopId;
        tasksModel.activity = activityId || "";

        for (let i = 0; i < tasksModel.count; i++) {
            const taskIndex = tasksModel.index(i, 0);
            let rawWinId = tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.WinIdList) || [];

            const rowIds = extractWinIds(rawWinId);

            if (rowIds.indexOf(String(winId)) !== -1) {
                tasksModel.requestActivate(taskIndex);
            }
        }
    }

    function requestCloseWindows(winIds, sourceDesktopId, activityId) {
        if (!winIds || winIds.length === 0 || !sourceDesktopId) return false;
        if (activityId === undefined || activityId === null) { activityId = ""; }
        tasksModel.virtualDesktop = sourceDesktopId;
        tasksModel.activity = activityId;
        var closed = 0;
        for (var i = 0; i < tasksModel.count; i++) {
            var taskIndex = tasksModel.index(i, 0);
            var rawWinId = tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.WinIdList) || [];
            if (rowMatchesWinIds(rawWinId, winIds)) {
                var closable = tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.IsClosable);
                if (closable === undefined || closable === true) {
                    tasksModel.requestClose(taskIndex);
                    closed++;
                }
            }
        }
        return closed > 0;
    }

    // Request entering the window at the given index on the specified virtual desktops.
    // On Wayland, virtual desktop ids are QStrings. On X11, they are uint >0.
    // An empty list has a special meaning: The window is entered on all virtual desktops in the session.
    // On X11, a window can only be on one or all virtual desktops. Therefore, only the first list entry is actually used.
    // On X11, the id 0 has a special meaning: The window is entered on all virtual desktops in the session.
    function requestVirtualDesktops(winId, sourceDesktopId, destDesktopIdList, activityId) {
        if (!winId || !sourceDesktopId || !activityId) return false;

        tasksModel.virtualDesktop = sourceDesktopId;
        tasksModel.activity = activityId || "";

        for (let i = 0; i < tasksModel.count; i++) {
            const taskIndex = tasksModel.index(i, 0);
            let rawWinId = tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.WinIdList) || [];

            const rowIds = extractWinIds(rawWinId);

            if (rowIds.indexOf(String(winId)) !== -1) {
                tasksModel.requestVirtualDesktops(taskIndex, destDesktopIdList);
            }
        }
    }
}
