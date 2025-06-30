#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
set -u
# Pipe failures should exit the script
set -o pipefail

# --- Configuration ---

# Flavors
PROD_FLAVOR="production"
DEV_FLAVOR="development"
STAGE_FLAVOR="staging" # Adjust if needed

# Dart Entry Points
MAIN_PROD="lib/main_production.dart"
MAIN_DEV="lib/main_development.dart"
MAIN_STAGE="lib/main_staging.dart"

# --- Android / Google Play ---
AAB_OUTPUT_DIR="build/app/outputs/bundle/${PROD_FLAVOR}Release"
AAB_OUTPUT_PATH="${AAB_OUTPUT_DIR}/app-${PROD_FLAVOR}-release.aab"
APK_BUILD_DIR_BASE="build/app/outputs/flutter-apk"
APK_DEV_OUTPUT_PATH="${APK_BUILD_DIR_BASE}/app-${DEV_FLAVOR}-release.apk"
APK_PROD_OUTPUT_PATH="${APK_BUILD_DIR_BASE}/app-${PROD_FLAVOR}-release.apk"

# --- iOS / TestFlight / Firebase App Distribution ---
# Assumes 'Runner' is your Xcode target name. Adjust if different.
IOS_ARCHIVE_PATH="build/ios/archive/Runner.xcarchive"
IOS_IPA_OUTPUT_DIR="build/ios/ipa" # Flutter build ipa default output dir
# !! MUST EXIST !! Update paths if needed
IOS_EXPORT_OPTIONS_PROD_PLIST="ios/ExportOptionsProd.plist"
IOS_EXPORT_OPTIONS_DEV_PLIST="ios/ExportOptionsDev.plist" # Or use Prod one if suitable
# App Store Connect API Key Details (!! REPLACE PLACEHOLDERS / OR USE ENV VARS !!)
ASC_API_KEY_ID="YOUR_ASC_KEY_ID"
ASC_API_ISSUER_ID="YOUR_ASC_ISSUER_ID"
ASC_API_PRIVATE_KEY_PATH="/path/to/your/AuthKey_XXXXXXXXXX.p8" # !! REPLACE PATH !!
# Firebase App Distribution iOS App IDs (!! REPLACE PLACEHOLDERS IF USING FIREBASE FOR IOS !!)
FIREBASE_DEV_APP_ID_IOS="1:648584474232:ios:1b67b9e8ced001f48d078d" # e.g., from Firebase Console
FIREBASE_PROD_APP_ID_IOS="1:141463328504:ios:74ece5763b9b1cd6c68d0d" # e.g., from Firebase Console
# Firebase App Distribution Tester Groups (Optional - comma-separated, no spaces)
FIREBASE_ANDROID_DEV_TESTER_GROUPS="internal-testers" # e.g., "android-qa,devs"
FIREBASE_ANDROID_PROD_TESTER_GROUPS="internal-testers" # e.g., "beta-android"
FIREBASE_IOS_TESTER_GROUPS="internal-testers" # Set your desired group(s)

# --- Firebase (General) ---
DEV_FB_ALIAS="dev"
PROD_FB_ALIAS="prod"
STAGE_FB_ALIAS="stage"
DEV_HOSTING_TARGET="dev"
PROD_HOSTING_TARGET="prod"
STAGE_HOSTING_TARGET="stage"
# Firebase App Distribution Android App IDs (!! REPLACE THESE PLACEHOLDERS !!)
FIREBASE_DEV_APP_ID_ANDROID="1:648584474232:android:ccee636d9e174e758d078d"
FIREBASE_PROD_APP_ID_ANDROID="1:141463328504:android:828ee3ab12dedb7cc68d0d"

# App Distribution Release Notes
RELEASE_NOTES="Automated build uploaded via script $(date)"

# Common Flutter Build Flags
FLUTTER_BUILD_FLAGS_COMMON="--no-tree-shake-icons"
FLUTTER_BUILD_FLAGS_APK_PROD="--no-tree-shake-icons" # Keep specific if needed

# Build Output Locations (Web)
WEB_BUILD_DIR_BASE="build/web"


# --- Helper Functions ---

# Function to attempt Firebase commands and handle auth errors
try_firebase_command() {
    echo "Attempting: $*"
    if ! "$@"; then
        echo "-----------------------------------------------------"
        echo "Firebase command failed. Authentication might be required."
        echo "Please run: "
        echo "  firebase login --reauth"
        echo "Then try the script again."
        echo "-----------------------------------------------------"
        exit 1
    fi
}

# Function to check if running on macOS
check_macos() {
  if [[ "$(uname)" != "Darwin" ]]; then
    echo "❌ Error: iOS builds and uploads require macOS."
    exit 1
  fi
}

# Function to check if ASC API details seem configured (basic check)
check_asc_api_config() {
    if [[ "$ASC_API_KEY_ID" == "YOUR_ASC_KEY_ID" ]] || \
       [[ "$ASC_API_ISSUER_ID" == "YOUR_ASC_ISSUER_ID" ]] || \
       [[ "$ASC_API_PRIVATE_KEY_PATH" == "/path/to/your/AuthKey_"* ]] || \
       [ ! -f "$ASC_API_PRIVATE_KEY_PATH" ]; then
        echo "⚠️ Warning: App Store Connect API Key details (ID, Issuer, or Path) seem unconfigured or invalid."
        echo "   TestFlight uploads will be skipped if needed."
        return 1 # Indicate config is likely missing
    fi
    return 0 # Indicate config looks present
}

# Function to check if Firebase iOS App ID is configured (basic check)
check_firebase_ios_id_config() {
    local app_id=$1
    if [[ "$app_id" == *"xxx"* ]] || [[ "$app_id" == *"yyy"* ]] || [[ -z "$app_id" ]]; then
        echo "⚠️ Warning: Firebase iOS App ID ('$app_id') seems unconfigured."
        echo "   Firebase App Distribution for iOS will be skipped if needed."
        return 1 # Indicate config is likely missing
    fi
    return 0 # Indicate config looks present
}

# Function to find the most recently built IPA in the output directory
find_latest_ipa() {
    local output_dir=$1
    local found_ipa
    found_ipa=$(ls -t "${output_dir}"/*.ipa 2>/dev/null | head -n 1 || true)
    if [[ -z "$found_ipa" ]] || [[ ! -f "$found_ipa" ]]; then
         echo "" # Return empty string if not found
    else
         echo "$found_ipa" # Return the found path
    fi
}


# --- Build Functions ---

# Build Production AAB
build_aab_prod() {
    echo "-------------------------------------"
    echo "Building Production AAB..."
    echo "-------------------------------------"
    mkdir -p "$AAB_OUTPUT_DIR"
    flutter build aab --flavor "$PROD_FLAVOR" -t "$MAIN_PROD" $FLUTTER_BUILD_FLAGS_COMMON
    echo "✅ Production AAB built: $AAB_OUTPUT_PATH"
}

# Build Web for a specific environment
build_web_env() {
    local env_lower=$1
    local main_dart=""
    local output_dir=""

    echo "-------------------------------------"
    echo "Building Web for ENV: $env_lower"
    echo "-------------------------------------"

    case "$env_lower" in
        dev) main_dart="$MAIN_DEV"; output_dir="$WEB_BUILD_DIR_BASE/development";;
        stage) main_dart="$MAIN_STAGE"; output_dir="$WEB_BUILD_DIR_BASE/staging";;
        prod) main_dart="$MAIN_PROD"; output_dir="$WEB_BUILD_DIR_BASE/production";;
        *) echo "❌ Invalid environment for web build: $env_lower"; exit 1 ;;
    esac

    flutter build web -t "$main_dart" -o "$output_dir" $FLUTTER_BUILD_FLAGS_COMMON
    echo "✅ Web ($env_lower) built to: $output_dir"
}

# Build APK for a specific environment
build_apk_env() {
    local env_lower=$1
    local flavor=""
    local main_dart=""
    local build_flags="$FLUTTER_BUILD_FLAGS_COMMON"
    local expected_apk_path=""

    echo "-------------------------------------"
    echo "Building APK for ENV: $env_lower"
    echo "-------------------------------------"

    case "$env_lower" in
        dev)
            flavor="$DEV_FLAVOR"; main_dart="$MAIN_DEV"
            expected_apk_path="$APK_DEV_OUTPUT_PATH"
            ;;
        prod)
            flavor="$PROD_FLAVOR"; main_dart="$MAIN_PROD"
            build_flags="$FLUTTER_BUILD_FLAGS_APK_PROD" # Use specific prod flags if different
            expected_apk_path="$APK_PROD_OUTPUT_PATH"
            ;;
        *) echo "❌ Invalid environment for apk build: $env_lower"; exit 1 ;;
    esac

    # Ensure output directory exists
    mkdir -p "$APK_BUILD_DIR_BASE"
    flutter build apk --flavor "$flavor" -t "$main_dart" $build_flags

    if [ ! -f "$expected_apk_path" ]; then
        echo "❌ Error: Expected APK not found at $expected_apk_path after build."
        exit 1
    fi
    echo "✅ APK ($env_lower) built: $expected_apk_path"
}

# Build iOS IPA for a specific environment
build_ipa_env() {
    check_macos
    local env_lower=$1
    local flavor=""
    local main_dart=""
    local export_plist=""
    local built_ipa_path=""

    echo "-------------------------------------"
    echo "Building iOS IPA for ENV: $env_lower"
    echo "-------------------------------------"
    echo "⚠️ Ensure code signing is correctly configured in Xcode!"

    case "$env_lower" in
        dev) flavor="$DEV_FLAVOR"; main_dart="$MAIN_DEV"; export_plist="$IOS_EXPORT_OPTIONS_DEV_PLIST";;
        prod) flavor="$PROD_FLAVOR"; main_dart="$MAIN_PROD"; export_plist="$IOS_EXPORT_OPTIONS_PROD_PLIST";;
        *) echo "❌ Invalid environment for ipa build: $env_lower"; exit 1 ;;
    esac

    if [ ! -f "$export_plist" ]; then echo "❌ Error: ExportOptions plist not found: $export_plist"; exit 1; fi

    # Clean previous IPA output dir for cleaner detection later
    rm -rf "$IOS_IPA_OUTPUT_DIR"
    mkdir -p "$IOS_IPA_OUTPUT_DIR"

    echo "Building IPA ($env_lower)..."
    flutter build ipa \
        --flavor "$flavor" \
        -t "$main_dart" \
        $FLUTTER_BUILD_FLAGS_COMMON \
        --export-options-plist "$export_plist"

    # Find the generated IPA
    built_ipa_path=$(find_latest_ipa "$IOS_IPA_OUTPUT_DIR")

    if [[ -z "$built_ipa_path" ]]; then
        echo "❌ Error: Could not find generated IPA file in $IOS_IPA_OUTPUT_DIR after build."
        exit 1
    fi

    echo "✅ iOS IPA ($env_lower) built: $built_ipa_path"
    # This function doesn't return the path anymore for 'all' command logic
    # The path will be re-calculated in the deploy step based on env
}


# --- Deploy/Upload Functions ---

# Deploy Web to Firebase Hosting
deploy_web_firebase() {
    local env_lower=$1
    local fb_alias=""
    local hosting_target=""

    echo "-------------------------------------"
    echo "Deploying Web to Firebase Hosting for ENV: $env_lower"
    echo "-------------------------------------"

    case "$env_lower" in
        dev) fb_alias="$DEV_FB_ALIAS"; hosting_target="$DEV_HOSTING_TARGET";;
        stage) fb_alias="$STAGE_FB_ALIAS"; hosting_target="$STAGE_HOSTING_TARGET";;
        prod) fb_alias="$PROD_FB_ALIAS"; hosting_target="$PROD_HOSTING_TARGET";;
        *) echo "❌ Invalid environment for web deploy: $env_lower"; exit 1 ;;
    esac

    try_firebase_command firebase deploy -P "$fb_alias" --only "hosting:$hosting_target"
    echo "✅ Web ($env_lower) deployed successfully!"
}

# Deploy APK to Firebase App Distribution
deploy_apk_firebase() {
    local env_lower=$1
    local apk_path=""
    local firebase_app_id=""
    local fb_alias=""
    local tester_groups=""

    echo "-------------------------------------"
    echo "Deploying APK to Firebase App Distribution for ENV: $env_lower"
    echo "-------------------------------------"

    case "$env_lower" in
        dev)
            apk_path="$APK_DEV_OUTPUT_PATH"; firebase_app_id="$FIREBASE_DEV_APP_ID_ANDROID"
            fb_alias="$DEV_FB_ALIAS"; tester_groups="$FIREBASE_ANDROID_DEV_TESTER_GROUPS"
            ;;
        prod)
            apk_path="$APK_PROD_OUTPUT_PATH"; firebase_app_id="$FIREBASE_PROD_APP_ID_ANDROID"
            fb_alias="$PROD_FB_ALIAS"; tester_groups="$FIREBASE_ANDROID_PROD_TESTER_GROUPS"
            ;;
        *) echo "❌ Invalid environment for apk deploy: $env_lower"; exit 1 ;;
    esac

    if [[ "$firebase_app_id" == *"xxx"* ]] || [[ -z "$firebase_app_id" ]]; then echo "❌ ERROR: Firebase Android App ID for '$env_lower' not set."; exit 1; fi
    if [ ! -f "$apk_path" ]; then echo "❌ Error: Built APK not found at $apk_path"; exit 1; fi

    local firebase_cmd=(firebase appdistribution:distribute "$apk_path")
    firebase_cmd+=("--app" "$firebase_app_id")
    firebase_cmd+=("-P" "$fb_alias")
    firebase_cmd+=("--release-notes" "$RELEASE_NOTES")
    if [[ -n "$tester_groups" ]]; then
        firebase_cmd+=("--groups" "$tester_groups")
    fi

    try_firebase_command "${firebase_cmd[@]}"
    echo "✅ APK ($env_lower) deployed successfully to Firebase App Distribution!"
}

# Upload iOS IPA to TestFlight
upload_ipa_to_testflight() {
    check_macos
    local ipa_path=$1
    local env_lower=$2 # Just for logging

    if ! check_asc_api_config; then # Checks if config looks okay
       echo "Skipping TestFlight upload due to missing/invalid API Key configuration."
       return # Don't exit, just skip
    fi
    if [[ -z "$ipa_path" ]] || [[ ! -f "$ipa_path" ]]; then echo "❌ Error: Invalid IPA path for TestFlight upload: '$ipa_path'"; exit 1; fi

    echo "-------------------------------------"
    echo "Uploading iOS IPA ($env_lower) to TestFlight..."
    echo "IPA: $ipa_path"
    echo "-------------------------------------"

    if ! xcrun altool --upload-app \
                 -f "$ipa_path" \
                 --type ios \
                 --apiKey "$ASC_API_KEY_ID" \
                 --apiIssuer "$ASC_API_ISSUER_ID" \
                 --private-key "file:$ASC_API_PRIVATE_KEY_PATH" --verbose ; then
        echo "❌ Error: Upload to App Store Connect (TestFlight) failed. Check logs."
        # Don't exit script here in 'all' flow, just report error, maybe Firebase upload will work
        return 1 # Indicate failure
    fi

    echo "✅ IPA ($env_lower) upload to TestFlight initiated successfully."
    return 0 # Indicate success
}

# Deploy iOS IPA to Firebase App Distribution
deploy_ipa_firebase() {
    check_macos
    local ipa_path=$1
    local env_lower=$2
    local firebase_app_id=""
    local fb_alias=""
    local tester_groups="$FIREBASE_IOS_TESTER_GROUPS" # Use common iOS group for now

    echo "-------------------------------------"
    echo "Deploying iOS IPA to Firebase App Distribution for ENV: $env_lower"
    echo "-------------------------------------"

    case "$env_lower" in
        dev) firebase_app_id="$FIREBASE_DEV_APP_ID_IOS"; fb_alias="$DEV_FB_ALIAS";;
        prod) firebase_app_id="$FIREBASE_PROD_APP_ID_IOS"; fb_alias="$PROD_FB_ALIAS";;
        *) echo "❌ Invalid environment for iOS Firebase deploy: $env_lower"; exit 1 ;;
    esac

    if ! check_firebase_ios_id_config "$firebase_app_id"; then
        echo "Skipping Firebase iOS Distribution due to missing App ID configuration."
        return # Don't exit, just skip
    fi
    if [[ -z "$ipa_path" ]] || [[ ! -f "$ipa_path" ]]; then echo "❌ Error: Invalid IPA path for Firebase upload: '$ipa_path'"; exit 1; fi

    local firebase_cmd=(firebase appdistribution:distribute "$ipa_path")
    firebase_cmd+=("--app" "$firebase_app_id")
    firebase_cmd+=("-P" "$fb_alias")
    firebase_cmd+=("--release-notes" "$RELEASE_NOTES")
     if [[ -n "$tester_groups" ]]; then
        firebase_cmd+=("--groups" "$tester_groups")
    fi

    try_firebase_command "${firebase_cmd[@]}"
    echo "✅ IPA ($env_lower) deployed successfully to Firebase App Distribution!"
}


# --- Main Script Logic ---

usage() {
    echo "Usage: $0 <action> [environment]"
    echo ""
    echo "Actions:"
    echo "  aab              Build Production AAB for Play Store (manual upload)"
    echo "  web              Build & Deploy Web (requires environment: dev|stage|prod)"
    echo "  apk              Build & Deploy APK to Firebase App Dist (requires environment: dev|prod)"
    echo "  ipa              Build & Upload iOS IPA to TestFlight AND Firebase App Dist (requires env: dev|prod) [macOS only]"
    echo "  build-all        Build all artifacts (AAB, Web x3, APK x2, IPA x2 [macOS])"
    echo "  deploy-all       Deploy/Upload all previously built artifacts (Web x3, APK x2, IPA x2 [macOS])"
    echo "  all              Build all, then Deploy/Upload all if builds succeed [macOS required for full run]"
    echo ""
    echo "Environments: dev | stage | prod (Required for web, apk, ipa)"
    echo ""
    echo "Examples:"
    echo "  $0 aab"
    echo "  $0 web dev"
    echo "  $0 apk prod"
    echo "  $0 ipa dev         # Builds, uploads Dev IPA to TestFlight & Firebase"
    echo "  $0 all             # Build everything, then upload/deploy everything"
    exit 1
}

# Check arguments
if [ -z "${1:-}" ]; then usage; fi
ACTION=$1
ENVIRONMENT="${2:-}" # Optional environment argument

# --- Action Handling ---

if [[ "$ACTION" != "all" && "$ACTION" != "build-all" && "$ACTION" != "deploy-all" ]]; then
    # Actions requiring environment
    if [[ "$ACTION" == "web" || "$ACTION" == "apk" || "$ACTION" == "ipa" ]]; then
        if [ -z "$ENVIRONMENT" ]; then echo "❌ Error: Action '$ACTION' requires an environment."; usage; fi
        # Validate environment based on action
        case "$ACTION" in
            web) if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "stage" && "$ENVIRONMENT" != "prod" ]]; then echo "❌ Invalid env for web"; usage; fi ;;
            apk|ipa) if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "prod" ]]; then echo "❌ Invalid env for apk/ipa"; usage; fi ;;
        esac
    fi
    # Actions requiring macOS
    if [[ "$ACTION" == "ipa" ]]; then
        check_macos
    fi
fi

echo "Starting action: $ACTION ${ENVIRONMENT:-}"
echo "Cleaning previous builds..."
flutter clean
echo "-------------------------------------"

case "$ACTION" in
    aab)
        build_aab_prod
        echo "=> Manual Upload Required: Upload '$AAB_OUTPUT_PATH' to Google Play."
        ;;
    web)
        build_web_env "$ENVIRONMENT"
        # deploy_web_firebase "$ENVIRONMENT" # Commented out for testing build only
        ;;
    apk)
        build_apk_env "$ENVIRONMENT"
        # deploy_apk_firebase "$ENVIRONMENT" # Commented out for testing build only
        ;;
    ipa)
        check_macos # Redundant check, but safe
        build_ipa_env "$ENVIRONMENT"
        # Find the IPA path again (build_ipa_env doesn't return it now)
        IPA_PATH=$(find_latest_ipa "$IOS_IPA_OUTPUT_DIR")
        if [[ -n "$IPA_PATH" ]]; then
            # upload_ipa_to_testflight "$IPA_PATH" "$ENVIRONMENT" # Commented out for testing build only
            # deploy_ipa_firebase "$IPA_PATH" "$ENVIRONMENT"      # Commented out for testing build only
            echo "-> Build only: Skipping TestFlight and Firebase uploads for $ENVIRONMENT IPA."
        else
            echo "❌ Error: Could not find IPA to upload/deploy for $ENVIRONMENT."
            exit 1
        fi
        ;;
    build-all)
        echo "=== Building ALL Artifacts ==="
        build_aab_prod
        build_web_env "dev"
        build_web_env "stage"
        build_web_env "prod"
        build_apk_env "dev"
        build_apk_env "prod"
        if [[ "$(uname)" == "Darwin" ]]; then
            echo "--- Building iOS IPAs (macOS detected) ---"
            build_ipa_env "dev"
            build_ipa_env "prod"
        else
             echo "⚠️ Skipping iOS IPA builds: Not on macOS."
        fi
        echo "=== ALL Builds Completed ==="
        ;;
    deploy-all)
         echo "=== Deploying/Uploading ALL Previously Built Artifacts ==="
         echo "-> Build only: Skipping all deployments/uploads."
         # Deploy Web
         # deploy_web_firebase "dev"
         # deploy_web_firebase "stage"
         # deploy_web_firebase "prod"
         # Deploy APKs
         # deploy_apk_firebase "dev"
         # deploy_apk_firebase "prod"
         # Upload IPAs (macOS only)
         # if [[ "$(uname)" == "Darwin" ]]; then
         #    echo "--- Uploading/Deploying iOS IPAs (macOS detected) ---"
            # Find paths again
            # DEV_IPA_PATH=$(find_latest_ipa "$IOS_IPA_OUTPUT_DIR") # Assumes dev was built last if both were built
            # PROD_IPA_PATH=$(find_latest_ipa "$IOS_IPA_OUTPUT_DIR") # Simple approach: find newest; might need refinement if builds output differently
                                                                    # A better way would be to store paths during build-all, e.g. in temp files

            # Crude way to find based on common naming convention if both exist
            # This is fragile - relies on Flutter naming them like YourApp-development.ipa / YourApp-production.ipa
            # app_name=$(grep 'PRODUCT_NAME' ios/Runner.xcodeproj/project.pbxproj | head -n 1 | awk -F'= ' '{print $2}' | tr -d '";')
            # POSSIBLE_DEV_IPA="${IOS_IPA_OUTPUT_DIR}/${app_name}-${DEV_FLAVOR}.ipa" # Check if build ipa names it this way
            # POSSIBLE_PROD_IPA="${IOS_IPA_OUTPUT_DIR}/${app_name}-${PROD_FLAVOR}.ipa" # Check if build ipa names it this way

            # DEV_IPA_TO_UPLOAD=""
            # PROD_IPA_TO_UPLOAD=""

            # if [[ -f "$POSSIBLE_DEV_IPA" ]]; then DEV_IPA_TO_UPLOAD="$POSSIBLE_DEV_IPA"; fi
            # if [[ -f "$POSSIBLE_PROD_IPA" ]]; then PROD_IPA_TO_UPLOAD="$POSSIBLE_PROD_IPA"; fi

            # Fallback if named differently (e.g., just AppName.ipa) - use latest
            # if [[ -z "$DEV_IPA_TO_UPLOAD" && -z "$PROD_IPA_TO_UPLOAD" ]]; then
            #      LATEST_IPA=$(find_latest_ipa "$IOS_IPA_OUTPUT_DIR")
            #      echo "⚠️ Warning: Could not find flavor-specific IPAs. Assuming latest IPA '$LATEST_IPA' is for PROD. Uploading Dev might fail or upload wrong IPA."
                 # Decide which one it likely is based on common 'all' order? Risky.
                 # Let's just try uploading the latest for both, user needs to be aware.
                 # Better: Have build-all write paths to files. For now, use latest found.
            #      if [[ -n "$LATEST_IPA" ]]; then
                     # Try uploading latest for both envs - one might be wrong!
            #          DEV_IPA_TO_UPLOAD="$LATEST_IPA"
            #          PROD_IPA_TO_UPLOAD="$LATEST_IPA"
            #          echo "Attempting to upload $LATEST_IPA for BOTH dev and prod."
            #      fi
            # elif [[ -z "$DEV_IPA_TO_UPLOAD" && -n "$PROD_IPA_TO_UPLOAD" ]]; then
            #      echo "Warning: Only Prod IPA found. Dev IPA might not have built or path is wrong."
            # elif [[ -n "$DEV_IPA_TO_UPLOAD" && -z "$PROD_IPA_TO_UPLOAD" ]]; then
            #      echo "Warning: Only Dev IPA found. Prod IPA might not have built or path is wrong."
            # fi

            # Deploy Dev IPA
            # if [[ -n "$DEV_IPA_TO_UPLOAD" ]]; then
            #     echo "--- Deploying/Uploading Dev IPA ($DEV_IPA_TO_UPLOAD) ---"
            #     upload_ipa_to_testflight "$DEV_IPA_TO_UPLOAD" "dev"
            #     deploy_ipa_firebase "$DEV_IPA_TO_UPLOAD" "dev"
            # else
            #     echo "⚠️ Skipping Dev IPA upload/deploy: Path not found."
            # fi
             # Deploy Prod IPA
            # if [[ -n "$PROD_IPA_TO_UPLOAD" ]]; then
            #     echo "--- Deploying/Uploading Prod IPA ($PROD_IPA_TO_UPLOAD) ---"
            #     upload_ipa_to_testflight "$PROD_IPA_TO_UPLOAD" "prod"
            #     deploy_ipa_firebase "$PROD_IPA_TO_UPLOAD" "prod"
            # else
            #     echo "⚠️ Skipping Prod IPA upload/deploy: Path not found."
            # fi
        # else
        #      echo "⚠️ Skipping iOS upload/deploy: Not on macOS."
        # fi
        # echo "=== ALL Deploys/Uploads Completed ===" # Actually skipped
        ;;
    all)
        echo "=== Running ALL Tasks: Build First, Then Deploy/Upload ==="
        # 1. Build All
        "$0" build-all # Execute this script again with build-all action
                      # set -e ensures if build-all fails, we stop here.

        # 2. Deploy/Upload All (only runs if build-all succeeded)
        echo "--- All builds successful, proceeding with deploys/uploads ---"
        echo "-> Build only: Skipping deploy-all step."
        # "$0" deploy-all # Execute this script again with deploy-all action # Commented out for testing build only

        echo "=== ALL Build Tasks Completed (Deploys/Uploads Skipped) ==="
        ;;
    *)
        echo "❌ Error: Invalid action '$ACTION'."
        usage
        ;;
esac

echo "✅ Script finished action: $ACTION ${ENVIRONMENT:-}"