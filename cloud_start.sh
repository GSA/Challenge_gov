#!/bin/bash
echo "------ Starting APP ------"
if [ $CF_INSTANCE_INDEX = "0" ]; then
  echo "----- Migrating Database -----"
  mix ecto.deploy
fi
mix phx.server
