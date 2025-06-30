dart run build_runner build --delete-conflicting-outputs
dart run flutter_iconpicker:generate_packs --packs material,cupertino

# Build APKs
flutter build apk --flavor production -t lib/main_production.dart  --no-tree-shake-icons &
flutter build apk --flavor development -t lib/main_development.dart  --no-tree-shake-icons &
flutter build aab --flavor production -t lib/main_production.dart  --no-tree-shake-icons &
wait

# Build AABs

flutter build web -t lib/main_production.dart -o 'build/web/production' --no-tree-shake-icons &
flutter build web -t lib/main_development.dart -o 'build/web/development' --no-tree-shake-icons &
flutter build web -t lib/main_staging.dart -o 'build/web/staging' --no-tree-shake-icons &
wait

rm -rf build/web/development/assets/assets/exe &
rm -rf build/web/staging/assets/assets/exe &
rm -rf build/web/production/assets/assets/exe &
wait

firebase deploy -P dev --only hosting:dev &
firebase deploy -P stage --only hosting:stage &
firebase deploy -P prod --only hosting:prod &
wait
