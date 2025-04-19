# Remove the existing release directory and build the release
sudo rm -rf "_build/prod"

#!/usr/bin/env bash
# Initial setup
mix deps.get --only prod
MIX_ENV=prod mix compile

# Copy dependencies' assets
cd ../healthy_backend && mkdir -p priv/static/assets && rm mix.lock && mix deps.get && mix phx.copy default

# Change mode to assets deploy local
cd -
mkdir -p priv/static/assets

# Build assets for tailwind
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix ua_inspector.download --force
# Release
MIX_ENV=prod mix release
if [ $? -eq 0 ]; then
  build_date=$(date +%Y%m%d_%H%M)
  build_name=_build_healthy_backend_$build_date.tar.gz
  tar -czvf $build_name _build
  echo "Built & compressed into: $build_name"
fi
