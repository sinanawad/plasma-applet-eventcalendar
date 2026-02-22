import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels

import ".."
import "../lib"
import "../lib/Requests.js" as Requests

Window {
	id: chooseCityDialog
	title: i18n("Select city")

	width: 500
	height: 600
	property bool loadingCityList: false

	signal accepted()
	signal rejected()

	function open() {
		show()
	}

	Logger {
		id: logger
		showDebug: plasmoid.configuration.debugging
	}

	ListModel { id: cityListModel }
	KItemModels.KSortFilterProxyModel {
		id: filteredCityListModel
		// sourceModel: cityListModel // Link after populating cityListModel so the UI doesn't freeze.
		filterRoleName: 'name'
		sortRoleName: 'name'
		sortCaseSensitivity: Qt.CaseInsensitive
	}

	property string selectedCityId: ''

	Timer {
		id: debouceApplyFilter
		interval: 1000
		onTriggered: chooseCityDialog.applyCityListSearch()
	}

	ColumnLayout {
		anchors.fill: parent
		anchors.margins: Kirigami.Units.largeSpacing

		LinkText {
			text: i18n("Fetched from <a href=\"%1\">%1</a>", "https://openweathermap.org/find")
		}
		TextField {
			id: cityNameInput
			Layout.fillWidth: true
			text: ''
			placeholderText: i18n("Search")
			onTextChanged: debouceApplyFilter.restart()
		}
		ScrollView {
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.minimumHeight: 200

			ListView {
				id: listView
				clip: true
				model: filteredCityListModel

				header: RowLayout {
					width: listView.width
					spacing: Kirigami.Units.smallSpacing
					Label {
						text: i18n("Name")
						font.bold: true
						Layout.fillWidth: true
						Layout.preferredWidth: 240
					}
					Label {
						text: i18n("Id")
						font.bold: true
						Layout.preferredWidth: 100
					}
					Label {
						text: i18n("City Webpage")
						font.bold: true
						Layout.preferredWidth: 100
					}
				}

				delegate: ItemDelegate {
					width: listView.width
					highlighted: chooseCityDialog.selectedCityId === model.id
					onClicked: chooseCityDialog.selectedCityId = model.id

					contentItem: RowLayout {
						spacing: Kirigami.Units.smallSpacing
						Label {
							text: model.name
							Layout.fillWidth: true
							Layout.preferredWidth: 240
							elide: Text.ElideRight
						}
						Label {
							text: model.id
							Layout.preferredWidth: 100
						}
						LinkText {
							Layout.preferredWidth: 100
							text: '<a href="https://openweathermap.org/city/' + model.id + '">' + i18n("Open Link") + '</a>'
						}
					}
				}

				BusyIndicator {
					anchors.centerIn: parent
					running: visible
					visible: chooseCityDialog.loadingCityList
				}
			}
		}

		DialogButtonBox {
			Layout.fillWidth: true
			standardButtons: DialogButtonBox.Ok | DialogButtonBox.Cancel
			onAccepted: {
				chooseCityDialog.accepted()
				chooseCityDialog.close()
			}
			onRejected: {
				chooseCityDialog.selectedCityId = ''
				chooseCityDialog.rejected()
				chooseCityDialog.close()
			}
		}
	}

	function clearCityList() {
		// clear list so that each append() doesn't rebuild the UI
		filteredCityListModel.sourceModel = null
		cityListModel.clear()
	}

	function parseCityList(data) {
		for (var i = 0; i < data.list.length; i++) {
			var item = data.list[i]
			var city = {
				id: item.id,
				name: item.name + ', ' + item.sys.country,
			}
			cityListModel.append(city)
		}
	}

	function applyCityListSearch() {
		searchCityList(cityNameInput.text)
	}

	function searchCityList(q) {
		logger.debug('searchCityList', q)
		clearCityList()
		if (q) {
			chooseCityDialog.loadingCityList = true
			fetchCityList({
				appId: plasmoid.configuration.openWeatherMapAppId,
				q: q,
			}, function(err, data, xhr) {
				if (err) return console.log('searchCityList.err', err, xhr && xhr.status, data)
				logger.debug('searchCityList.response')
				logger.debugJSON('searchCityList.response', data)

				parseCityList(data)

				// link after populating so that each append() doesn't attempt to rebuild the UI.
				filteredCityListModel.sourceModel = cityListModel

				chooseCityDialog.loadingCityList = false
			})
		}
	}

	function fetchCityList(args, callback) {
		if (!args.appId) return callback('OpenWeatherMap AppId not set')

		var url = 'https://api.openweathermap.org/data/2.5/'
		url += 'find?q=' + encodeURIComponent(args.q)
		url += '&type=like'
		url += '&sort=population'
		url += '&cnt=30'
		url += '&appid=' + args.appId
		Requests.getJSON(url, callback)
	}
}
