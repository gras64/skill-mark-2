/*
 * Copyright 2018 by Aditya Mehra <aix.m@outlook.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.2
import QtQuick.Layouts 1.2
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.kirigami 2.5 as Kirigami
import Mycroft 1.0 as Mycroft

Kirigami.AbstractListItem {
    id: connectionItem

    property bool activating: model.ConnectionState == PlasmaNM.Enums.Activating
    property bool deactivating: model.ConnectionState == PlasmaNM.Enums.Deactivating
    property bool predictableWirelessPassword: !model.Uuid && model.Type == PlasmaNM.Enums.Wireless &&
                                               (model.SecurityType == PlasmaNM.Enums.StaticWep || model.SecurityType == PlasmaNM.Enums.WpaPsk ||
                                                model.SecurityType == PlasmaNM.Enums.Wpa2Psk)
    
    contentItem: Item {
            implicitWidth: delegateLayout.implicitWidth;
            implicitHeight: delegateLayout.implicitHeight;
    
    ColumnLayout {
        id: delegateLayout
        anchors {
            left: parent.left;
            top: parent.top;
            right: parent.right;
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Math.round(units.gridUnit / 2)

            Kirigami.Icon {
                id: connectionSvgIcon
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                Layout.preferredHeight: units.iconSizes.medium
                Layout.preferredWidth: units.iconSizes.medium
                //elementId: model.ConnectionIcon
                source: "network-wireless-connected-100"
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft

                Kirigami.Heading {
                    id: connectionNameLabel
                    Layout.alignment: Qt.AlignLeft
                    level: 2
                    elide: Text.ElideRight
                    font.weight: model.ConnectionState == PlasmaNM.Enums.Activated ? Font.DemiBold : Font.Normal
                    font.italic: model.ConnectionState == PlasmaNM.Enums.Activating ? true : false
                    text: model.ItemUniqueName
                    textFormat: Text.PlainText
                }

                Kirigami.Heading {
                    id: connectionStatusLabel
                    Layout.alignment: Qt.AlignLeft
                    level: 3
                    elide: Text.ElideRight
                    opacity: 0.6
                    text: itemText()
                }
            }
        }
    }
}

    function itemText() {
        if (model.ConnectionState == PlasmaNM.Enums.Activating) {
            if (model.Type == PlasmaNM.Enums.Vpn)
                return model.VpnState
            else
                return model.DeviceState
        } else if (model.ConnectionState == PlasmaNM.Enums.Deactivating) {
            if (model.Type == PlasmaNM.Enums.Vpn)
                return model.VpnState
            else
                return model.DeviceState
        } else if (model.ConnectionState == PlasmaNM.Enums.Deactivated) {
            var result = model.LastUsed
            if (model.SecurityType > PlasmaNM.Enums.NoneSecurity)
                result += ", " + model.SecurityTypeString
            return result
        } else if (model.ConnectionState == PlasmaNM.Enums.Activated) {
                return i18n("Connected")
        }
    }

    onClicked: {
        console.log(model.ConnectionPath, model.DevicePath, model.SpecificPath)
        if(!model.ConnectionPath){
            triggerEvent("networkConnect.wifi", {"DevicePath": model.DevicePath, "SpecificPath": model.SpecificPath, "ConnectionName": connectionNameLabel.text, "SecurityType": model.SecurityType});
        }
        else if (model.ConnectionState == PlasmaNM.Enums.Deactivated) {
            triggerEvent("networkConnect.connecting", {})
            handler.activateConnection(model.ConnectionPath, model.DevicePath, model.SpecificPath)
        }
        else {
            handler.deactivateConnection(model.ConnectionPath, model.DevicePath)
        }
    }
    
    onPressAndHold: {
        pathToRemove = model.ConnectionPath
        networkActions.open()
    }
}
