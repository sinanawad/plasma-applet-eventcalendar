import QtQuick
import org.kde.plasma.networkmanagement as PlasmaNM

PlasmaNM.NetworkStatus {
	id: plasmaNMStatus
	Component.onCompleted: {
		logger.debug('NetworkStatus.networkStatus', networkStatus)
	}
}
