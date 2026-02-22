import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami

Button {
	id: colorTextButton
	padding: Kirigami.Units.smallSpacing

	property alias label: colorTextLabel.text

	contentItem: Label {
		id: colorTextLabel
		color: Kirigami.Theme.buttonTextColor
	}
}
