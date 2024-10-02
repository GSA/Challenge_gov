echo "Updating Caddy config"
./proxy/envsubst < ./proxy/Caddyfile.local.tmpl > ./proxy/Caddyfile.local

echo "Starting Caddy"
exec ./proxy/caddy run --config ./proxy/Caddyfile.local
