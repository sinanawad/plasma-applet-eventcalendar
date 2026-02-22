// Version 6

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCMUtils

KCMUtils.SimpleKCM {
	id: page
	default property alias _contentChildren: content.data

	ColumnLayout {
		id: content
		width: parent.width
	}

	property alias showAppletVersion: appletVersionLoader.active
	Loader {
		id: appletVersionLoader
		active: false
		visible: active
		source: "AppletVersion.qml"
	}
}
