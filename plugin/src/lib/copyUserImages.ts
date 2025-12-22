import * as fs from 'fs'
import * as path from 'path'

import { addImageToAssetsCatalog } from './generateAssetsCatalog'

const MAX_IMAGE_SIZE_BYTES = 4096 // 4KB limit for Live Activities

/**
 * Supported image extensions for widget assets
 */
const SUPPORTED_IMAGE_EXTENSIONS = /\.(png|jpg|jpeg)$/i

/**
 * Validates that an image file is within the size limit for Live Activities.
 *
 * @param imagePath - Path to the image file
 * @throws Error if the image exceeds the 4KB limit
 */
export function validateImageSize(imagePath: string): void {
  const stats = fs.statSync(imagePath)
  const imageSizeInBytes = stats.size

  if (imageSizeInBytes >= MAX_IMAGE_SIZE_BYTES) {
    const fileName = path.basename(imagePath)
    throw new Error(
      `Live Activity image size limit exceeded: ${fileName} is ${imageSizeInBytes} bytes ` +
        `(${(imageSizeInBytes / 1024).toFixed(2)}KB). ` +
        `Live Activity images must be less than 4KB (4096 bytes).`
    )
  }
}

/**
 * Checks if a file is a supported image type.
 */
export function isSupportedImage(filePath: string): boolean {
  return SUPPORTED_IMAGE_EXTENSIONS.test(path.extname(filePath))
}

/**
 * Default path for user-provided widget images
 */
export const DEFAULT_USER_IMAGES_PATH = './assets/voltra'

/**
 * Copies user images from the source directory to the widget's Assets.xcassets.
 *
 * Images are validated for size (must be < 4KB for Live Activities) and
 * added as imagesets to the asset catalog.
 *
 * @param userImagesPath - Path to directory containing user images (relative to project root)
 * @param targetAssetsPath - Path to the Assets.xcassets directory in the widget target
 * @returns Array of image filenames that were copied
 */
export function copyUserImages(userImagesPath: string, targetAssetsPath: string): string[] {
  const copiedImages: string[] = []

  if (!fs.existsSync(userImagesPath)) {
    console.warn(`[Voltra] Skipping user images: directory does not exist at ${userImagesPath}`)
    return copiedImages
  }

  if (!fs.lstatSync(userImagesPath).isDirectory()) {
    console.warn(`[Voltra] Skipping user images: ${userImagesPath} is not a directory`)
    return copiedImages
  }

  const files = fs.readdirSync(userImagesPath)

  for (const file of files) {
    const sourcePath = path.join(userImagesPath, file)

    // Skip directories and non-image files
    if (fs.lstatSync(sourcePath).isDirectory()) {
      continue
    }

    if (!isSupportedImage(file)) {
      continue
    }

    // Validate image size for Live Activity compatibility
    validateImageSize(sourcePath)

    // Add to asset catalog
    addImageToAssetsCatalog(targetAssetsPath, sourcePath)
    copiedImages.push(file)
  }

  if (copiedImages.length > 0) {
    console.log(`[Voltra] Copied ${copiedImages.length} user image(s) to widget assets`)
  }

  return copiedImages
}
