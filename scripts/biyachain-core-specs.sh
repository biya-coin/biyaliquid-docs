#!/usr/bin/env bash
biyachain_core_branch=master
cosmos_sdk_branch=v0.50.x-biya
BUILD_DIR=./temp
STUB_DIR=./scripts/stub
CORE_DIR=./.gitbook/developers-native/core
biyachain_DIR=./.gitbook/developers-native/biyachain

mkdir -p $BUILD_DIR
rm -rf $CORE_DIR
rm -rf $biyachain_DIR
mkdir -p $CORE_DIR
mkdir -p $biyachain_DIR

if [ "$GH_CORE_USER" ] && [ "$GH_CORE_TOKEN" ]; then
  echo "Using GitHub credentials for cloning biyachain-core"
  BIYA_CORE_GIT_URL="https://${GH_CORE_USER}:${GH_CORE_TOKEN}@github.com/biya-coin/biyachain-core.git"
else
  echo "Using org access to clone biyachain-core"
  BIYA_CORE_GIT_URL="org-44571224@github.com:biya-coin/biyachain-core.git"
fi
git clone "${BIYA_CORE_GIT_URL}" "${BUILD_DIR}/biyachain-core" \
  -b "${biyachain_core_branch}" \
  --depth 1 \
  --single-branch > /dev/null

echo "Cloning cosmos-sdk..."
git clone "https://github.com/biya-coin/cosmos-sdk.git" "${BUILD_DIR}/cosmos-sdk" \
  -b "${cosmos_sdk_branch}" \
  --depth 1 \
  --single-branch > /dev/null

## Generate errors docs
./$BUILD_DIR/biyachain-core/scripts/docs/generate_errors_docs.sh

for D in ./$BUILD_DIR/cosmos-sdk/x/*; do
  if [ -d "${D}" ]; then
    mkdir -p "$CORE_DIR/$(echo $D | awk -F/ '{print $NF}')" && cp -r $D/README.md "$_"
  fi
done

for D in ./$BUILD_DIR/biyachain-core/biyachain-chain/modules/*; do
  if [ -d "${D}" ]; then
    mkdir -p "$biyachain_DIR/$(echo $D | awk -F/ '{print $NF}')" && cp -r $D/spec/* "$_"
  fi
done

## txfees
cp $BUILD_DIR/biyachain-core/biyachain-chain/modules/txfees/README.md $biyachain_DIR/txfees/README.md
## lanes
mkdir -p $biyachain_DIR/lanes
cp $BUILD_DIR/biyachain-core/biyachain-chain/lanes/spec/README.md $biyachain_DIR/lanes/README.md

cp $STUB_DIR/core.modules.md.stub $CORE_DIR/README.md
cp $STUB_DIR/biyachain.modules.md.stub $biyachain_DIR/README.md

## 1. Manually replace wrong import paths
## authz
search1="(../modules/auth/)"
replace1="(../auth/)"

FILES=$( find $CORE_DIR/authz -type f )

for file in $FILES
do
	sed -ie "s/${search1//\//\\/}/${replace1//\//\\/}/g" $file
done

## auth
search2="(../modules/authz/)"
replace2="(../authz/)"

FILES=$( find $CORE_DIR/auth -type f )

for file in $FILES
do
	sed -ie "s/${search2//\//\\/}/${replace2//\//\\/}/g" $file
done

rm $CORE_DIR/authz/README.mde
rm $CORE_DIR/auth/README.mde
rm -rf $BUILD_DIR
