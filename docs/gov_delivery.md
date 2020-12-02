# Challenge.Gov Portal and GovDelivery

## Setup

The Challenge.Gov Portal integration with GovDelivery is designed to work on
its own independent GovDelivery account or within a larger account. All topics created are within a root
category defined with an environment variable. See [Variables](./configuration_variables.md).

Within the GovDelivery Admin interface, Challenge.Gov requires the following:

1. Get the Account Code, easily found in the URL
1. An API username and password. When created, this user doesn't have admin permissions. Open a ticket with GovDelivery support to elevate the permission.
1. A category to group app topics under, its code should be set as the `GOV_DELIVERY_CATEGORY_CODE` variable
1. Topic subscribe URL, from a topic, the admin interface can provide a link to subscribe right to the topic. The link needed for the `GOV_DELIVERY_TOPIC_SUBSCRIBE_URL` is that URL without the specific topci cde.
1. A topic for general Challenge.Gov news must be created. The code for this topic should be set as `GOV_DELIVERY_TOPIC_CODE`

## General News Subscribe Flow

The topic created for general news, whose code is set to `GOV_DELIVERY_TOPIC_CODE`,
should also have a signup flow created for it. This signup flow is part of the Federalist pages,
similar to [here](https://github.com/GSA/challenges-and-prizes/blob/8f1017e951965d92353774c361d4a26b3eca15c7/_includes/help-section.html#L25)
