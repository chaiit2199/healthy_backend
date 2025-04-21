# Remove the existing release directory and build the release
rm -rf "_build"

#!/usr/bin/env bash
# Initial setup
mix deps.get --only prod
MIX_ENV=prod mix compile

# * change mode to assets deploy local
MIX_ENV=prod mix ua_inspector.download --force
MIX_ENV=prod mix assets.deploy

# Release
MIX_ENV=prod mix release
if [ $? -eq 0 ]; then
  # Only when mix release is successful
  build_date=$(date +%Y%m%d_%H%M)
  build_name=_build_healthy_backend_$build_date.tar.gz
  tar -czvf $build_name _build
  echo "Built & compressed into: $build_name"
fi
