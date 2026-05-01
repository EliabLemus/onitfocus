#!/bin/bash

# Script to add color sets to Xcode project
PROJECT_FILE="/Users/openjaime/.openclaw/workspace/projects/focally/Focally.xcodeproj/project.pbxproj"
COLORSETS_DIR="/Users/openjaime/.openclaw/workspace/projects/focally/Focally/Assets.xcassets/Colors"

# List of color sets to add
COLORS=(
    "focallyPrimary"
    "focallyOnPrimary"
    "focallyPrimaryContainer"
    "focallySurface"
    "focallySurfaceContainerLowest"
    "focallySurfaceContainerLow"
    "focallySurfaceContainer"
    "focallyOnSurface"
    "focallyOnSurfaceVariant"
    "focallySecondary"
    "focallySecondaryContainer"
    "focallyTertiary"
    "focallyTertiaryContainer"
    "focallyOutline"
    "focallyOutlineVariant"
    "focallyBackground"
    "focallyError"
    "focallyErrorContainer"
    "focallyInverseSurface"
    "focallyInverseOnSurface"
    "focallyCardBorder"
)

# Generate UUIDs for each color set
generate_uuid() {
    python3 -c "import uuid; print(uuid.uuid4().hex.lower())"
}

# Create a temporary file with new entries
temp_file=$(mktemp)

# Read the project file
cat "$PROJECT_FILE" > "$temp_file"

# Generate color set entries
color_set_entries=()
for color in "${COLORS[@]}"; do
    colorset_id=$(generate_uuid)
    asset_path="Focally/Assets.xcassets/Colors/$color.colorset"
    build_file_id=$(generate_uuid)
    file_ref_id=$(generate_uuid)

    color_set_entries+=("PBXBuildFile:${build_file_id}")
    color_set_entries+=("PBXFileReference:${file_ref_id}")
    color_set_entries+=("PBXVariantGroup:${colorset_id}")
    color_set_entries+=("XCRemoteSwiftPackageReferenceDependency:")
    color_set_entries+=("XCSwiftPackageProductDependency:")
done

echo "Color set entries generated:"
echo "${color_set_entries[@]}"
echo "Need to add these to project.pbxproj"

# Clean up
rm "$temp_file"
