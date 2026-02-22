import QtQuick
import QtQuick.Controls as QQC2

QQC2.Menu {
	id: contextMenu

	signal populate(var contextMenu)

	// Force loading of MenuItem.qml so dynamic creation *should* be synchronous.
	// It's a property since the default content property of QQC2.Menu doesn't like it.
	property var menuItemComponent: Component {
		MenuItem {}
	}

	property var separatorComponent: Component {
		QQC2.MenuSeparator {}
	}

	function newSeperator(parentMenu) {
		return separatorComponent.createObject(contextMenu)
	}

	function newMenuItem(parentMenu, properties) {
		if (properties && properties.separator) {
			return newSeperator(parentMenu)
		}
		return menuItemComponent.createObject(contextMenu, properties || {})
	}

	function newSubMenu(parentMenu, properties) {
		var subMenuItem = newMenuItem(parentMenu || contextMenu, properties)
		var subMenu = Qt.createComponent("ContextMenu.qml").createObject(parentMenu || contextMenu)
		subMenuItem.subMenu = subMenu
		return subMenuItem
	}

	function clearMenuItems() {
		for (var i = count - 1; i >= 0; i--) {
			var item = itemAt(i)
			removeItem(item)
			if (item) item.destroy()
		}
	}

	function loadMenu() {
		clearMenuItems()
		populate(contextMenu)
	}

	function show(x, y) {
		loadMenu()
		if (count > 0) {
			popup(x, y)
		}
	}
}
