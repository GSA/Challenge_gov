#!/bin/bash
echo "------ Starting APP ------ Instance $CF_INSTANCE_INDEX -----"
echo "------ Booting Instance ------ Instance $CF_INSTANCE_INDEX -----"
if [ "$CF_INSTANCE_INDEX" == "0" ]; then
  echo "----- Migrating Database ----- Instance $CF_INSTANCE_INDEX -----"
  mix ecto.deploy
  echo "----- Migrated Database ----- Instance $CF_INSTANCE_INDEX -----"
fi
echo "------ Booting Web Process ------ Instance $CF_INSTANCE_INDEX -----"
mix phx.server

