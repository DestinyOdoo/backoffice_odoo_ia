/** @odoo-module **/

import { Component, onWillStart, useState } from "@odoo/owl";
import { registry } from "@web/core/registry";
import { useService } from "@web/core/utils/hooks";

export class BoSubscriptionBanner extends Component {
    static template = "bo_license_client.BoSubscriptionBanner";
    static props = {};

    setup() {
        this.orm = useService("orm");
        this.action = useService("action");
        this.state = useState({
            visible: false,
            portalUrl:
                "https://rbac-portal-15.preview.emergentagent.com/connect",
            errorHint: "",
        });
        onWillStart(async () => {
            try {
                const res = await this.orm.call(
                    "license.config",
                    "get_subscription_banner_state",
                    []
                );
                this.state.visible = Boolean(res.show_warning);
                if (res.portal_url) {
                    this.state.portalUrl = res.portal_url;
                }
                this.state.errorHint = res.error_hint || "";
            } catch {
                this.state.visible = false;
            }
        });
    }

    async onClickUpdate() {
        const action = await this.orm.call(
            "license.config",
            "action_open_subscription_wizard",
            []
        );
        if (action) {
            await this.action.doAction(action);
        }
    }
}

registry.category("main_components").add(
    "bo_license_client.SubscriptionBanner",
    {
        Component: BoSubscriptionBanner,
        props: {},
    },
    { sequence: 5 }
);
