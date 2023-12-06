/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import fs from '@ohos.file.fs';
import image from '@ohos.multimedia.image';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import { Logger } from '@ohos/common';
import { CommonConstants } from '../common/constant/CommonConstants';

const TAG: string = 'imageEdit_Encode';

/**
 * Pack the image.
 *
 * @param pixelMap.
 */
export async function encode(component: Object, pixelMap: PixelMap): Promise<Resource> {
  const newPixelMap = pixelMap;
  // Packing image.
  const imagePackerApi = image.createImagePacker();
  const packOptions: image.PackingOption = {
    format: CommonConstants.ENCODE_FORMAT,
    quality: CommonConstants.ENCODE_QUALITY
  };
  const imageData = await imagePackerApi.packing(newPixelMap, packOptions);
  Logger.info(TAG, `imageData's length is ${imageData.byteLength}`);
  // Get album's path.
  const context = getContext(component);
  let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
  let photoType: photoAccessHelper.PhotoType = photoAccessHelper.PhotoType.IMAGE;
  let fileName: string = `${CommonConstants.IMAGE_PREFIX}_${new Date().getTime()}`;
  try {
    // Create image asset.
    const uri = await phAccessHelper.createAsset(photoType, 'jpg', {
      title: fileName
    });
    let file = await fs.open(uri, fs.OpenMode.READ_WRITE);
    await fs.write(file.fd, imageData);
    await fs.close(file.fd);
  } catch (err) {
    Logger.error(TAG, `createAsset failed, message ${JSON.stringify(err)}`);
    return $r('app.string.save_failed');
  }
  imagePackerApi.release();
  await phAccessHelper.release();
  return $r('app.string.saved_successfully');
}


