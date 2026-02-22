import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami

Label {
	linkColor: Kirigami.Theme.highlightColor
	onLinkActivated: Qt.openUrlExternally(link)
	MouseArea {
		anchors.fill: parent
		acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
		cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
	}
}
